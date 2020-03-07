import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'dart:math';
import 'dart:ui';
import 'package:audio_service/audio_service.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';
import 'package:voc_amp/background/exceptions.dart';
import 'package:voc_amp/background/utils/stream-utils.dart';
import 'package:voc_amp/models/audio/repeat-mode.dart';
import 'package:voc_amp/models/isolates/audio-player-event.dart';
import 'package:voc_amp/models/media/queue-track.dart';
import 'package:voc_amp/providers/audio-player.provider.dart';
import 'package:voc_amp/utils/debounced-action.dart';
import 'package:voc_amp/utils/logger.dart';
import 'package:rxdart/transformers.dart';

import 'audio-player-queue.dart';
import 'media-controls.dart';

void audioPlayerBackgroundTask() async {
  AudioServiceBackground.run(() => VocAmpAudioPlayer());
}

class VocAmpAudioPlayer extends BackgroundAudioTask {
  AudioPlayerQueue queue;
  Completer serviceStopCompleter;
  SendPort sendPort;
  AudioPlayer player;
  Logger log = Logger('VocAmpAudioPlayer');
  DebouncedAction debouncedPlay;
  String currentAudioTrackId;
  Random random = Random();

  // Flags
  RepeatMode repeatMode = RepeatMode.NONE;
  bool taskReady = false;

  //
  // PLAYER EVENTS
  //

  @override
  onStart() async {
    log.debug('onStart()');
    try {
      // Fetch send port
      refreshSendPort();
      // Setup audio player
      player = AudioPlayer();
      var playbackEventSubscription =
      player.playbackEventStream.listen((e) => updateState());
      var playbackStateSubscription = player.playbackStateStream
          .startWith(null)
          .pairwise()
          .map((e) => e.toList())
          .listen((e) => onPlayerStateChange(e[0], e[1]));
      // Setup queue
      queue = AudioPlayerQueue();
      var queueSubscription =
      queue.updated.listen((_) => this.sendQueueUpdate());
      // Set up debounced actions
      debouncedPlay = DebouncedAction(
        duration: Duration(milliseconds: 1000),
        action: onPlay,
      );
      // Mark background task ready
      taskReady = true;
      // Send player flags
      sendPlayerFlags();
      // Setup completer and wait for service stop
      serviceStopCompleter = Completer();
      await serviceStopCompleter.future;
      // Clean up service before stop
      await stopPlayback();
      sendPort.send(AudioPlayerEvent.build('serviceStop'));
      debouncedPlay.dispose();
      queueSubscription.cancel();
      playbackEventSubscription.cancel();
      playbackStateSubscription.cancel();
      queue.dispose();
      player.dispose();
    } catch (e) {
      log.severe(['onStart', e]);
      rethrow;
    }
  }

  @override
  void onPause() async {
    log.debug('onPause()');
    if (player.playbackState == AudioPlaybackState.playing)
      await player.pause();
  }

  @override
  Future<void> onSkipToNext() async {
    log.debug('onSkipToNext()');
    if (!queue.hasNext()) return;
    await stopPlayback();
    queue.next();
    await debouncedPlay.next();
  }

  @override
  Future<void> onSkipToPrevious() async {
    log.debug('onSkipToPrevious()');
    if (!queue.hasPrevious()) return;
    await stopPlayback();
    queue.previous();
    await debouncedPlay.next();
  }

  @override
  void onSkipToQueueItem(String mediaId) async {
    log.debug('onSkipToQueueItem()');
    QueueTrack track =
    queue.tracks.singleWhere((t) => t.id == mediaId, orElse: () => null);
    if (track == null) return;
    await stopPlayback();
    queue.setCursor(track);
    await debouncedPlay.next();
  }

  @override
  Future<void> onStop() async {
    log.debug('onStop()');
    try {
      // Release completer
      serviceStopCompleter.complete();
    } catch (e) {
      log.severe(['onStop', e]);
      rethrow;
    }
  }

  @override
  Future<void> onPlay() async {
    log.debug('onPlay()');
    try {
      switch (player.playbackState) {
        case AudioPlaybackState.paused:
          await player.play();
          break;
        case AudioPlaybackState.completed:
        case AudioPlaybackState.none:
        case AudioPlaybackState.stopped:
        // Stop if there is nothing to play
          if (queue.currentTrack == null ||
              queue.currentTrack.track.sources.isEmpty) return;
          // Load track & start audio player
          try {
            if (await attemptTrackLoad(queue.currentTrack)) await player.play();
          } on NoConnectionException catch (e) {
            errorToast(
                'Playback is stopping as the music service could not be reached.');
            return await stopPlayback();
          } on ExtractionException catch (e) {
            errorToast(
                'An extraction error was encountered. The app will likely have to be updated.');
            return await stopPlayback();
          } on NoAudioStreamFoundException catch (e) {
            String err =
                'No audio stream found for ${queue.currentTrack.track.title}.';
            QueueTrack nextTrack = queue.next();
            if (nextTrack != null) {
              err += ' Skipping to the next track...';
              onPlay();
            }
            errorToast(err);
            return;
          }
          break;
        case AudioPlaybackState.connecting:
        case AudioPlaybackState.playing:
          break;
        default:
          throw 'Unknown playback state: ${player.playbackState}';
      }
    } catch (e) {
      log.severe(['onPlay', e]);
      rethrow;
    }
  }

  @override
  void onSeekTo(int position) {
    log.debug('onSeekTo()');
    if (player.playbackState != AudioPlaybackState.none &&
        player.playbackState != AudioPlaybackState.connecting)
      player.seek(Duration(milliseconds: position));
  }

  void onPlayerStateChange(AudioPlaybackState oldState,
      AudioPlaybackState newState) {
    // When end of song is reached
    if (oldState == AudioPlaybackState.playing &&
        newState == AudioPlaybackState.completed) {
      if (repeatMode == RepeatMode.SINGLE) {
        if (queue.currentTrack != null) onPlay();
      } else if (queue.next() != null) {
        onPlay();
      } else if (repeatMode == RepeatMode.ALL && queue.length > 0) {
        queue.setCursor(queue.tracks.first);
        onPlay();
      }
    }
  }

  @override
  Future<void> onCustomAction(String name, dynamic arguments) async {
    try {
      switch (name) {
        case 'setQueue':
          return await handleSetQueue(jsonDecode(arguments));
        case 'refreshSendPort':
          return refreshSendPort();
        case 'getQueueState':
          return sendQueueUpdate();
        case 'getPlaybackState':
          return updateState();
        case 'setShuffle':
          return await handleSetShuffle(arguments);
        case 'getPlayerFlags':
          return sendPlayerFlags();
        case 'setRepeat':
          return await handleSetRepeat(jsonDecode(arguments));
      }
    } catch (e) {
      log.severe(['onCustomAction', name, e]);
      rethrow;
    }
  }

  //
  // CUSTOM ACTION HANDLERS
  //

  Future<void> handleSetRepeat(Map<String, dynamic> arguments) async {
    repeatMode = RepeatMode.fromJson(arguments['mode']);
    this.sendPlayerFlags();
  }

  Future<void> handleSetShuffle(bool value) async {
    queue.setShuffled(value);
  }

  Future<void> handleSetQueue(Map<String, dynamic> arguments) async {
    log.debug('handleSetQueue()');
    List<QueueTrack> tracks = (arguments['tracks'] as List<dynamic>)
        .map((t) => QueueTrack.fromJson(t))
        .toList();
    bool shuffled = (arguments['shuffled'] as bool) ?? false;
    QueueTrack cursor = arguments['cursor'] == null
        ? (tracks.isEmpty
        ? null
        : tracks[shuffled ? random.nextInt(tracks.length) : 0])
        : QueueTrack.fromJson(arguments['cursor']);
    // Stop playing if the new cursor is different
    if (cursor?.id == null || cursor.id != queue.currentTrack?.id) await stopPlayback();
    // Update queue
    queue.setTracks(tracks);
    queue.setShuffled(shuffled);
    queue.setCursor(cursor);
  }

  //
  // UTILITIES
  //

  errorToast(String msg) {
    Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
    );
  }

  // Return value, whether the load was successful
  Future<bool> attemptTrackLoad(QueueTrack track) async {
    // If the track is the currently loaded track, we don't have to load anything
    if (currentAudioTrackId == track.id) {
      player.seek(Duration(milliseconds: 0));
      return true;
    }

    // Get the audio stream. Any exceptions are handled outside of this method.
    String audioUrl = await StreamUtils.getAudioStreamForQueueTrack(track);

    // If no audio url can be obtained, skip to the next track.
    if (audioUrl == null) throw NoAudioStreamFoundException();

    // Stop current playback
    stopPlayback();

    // Set audio url and obtain duration
    Duration duration = await player.setUrl(audioUrl);
    currentAudioTrackId = track.id;

    // Update media item with new duration
    track.cachedDuration = duration;
    sendQueueUpdate();
    AudioServiceBackground.setMediaItem(
      track.buildMediaItem(),
    );

    // Wait for player to finish connecting
    await player.playbackStateStream
        .firstWhere((state) => state != AudioPlaybackState.connecting);

    return true;
  }

  // Update the front with the current player flags
  Future<void> sendPlayerFlags() async {
    sendPort.send(AudioPlayerEvent.build('playerFlags', {
      'repeatMode': repeatMode,
      'ready': taskReady,
    }));
  }

// Fetch the current send port
  void refreshSendPort() {
    sendPort =
        IsolateNameServer.lookupPortByName(AudioPlayerProvider.PORT_NAME);
  }

// Update the front with the current queue state
  void sendQueueUpdate() async {
    if (sendPort != null) {
      sendPort.send(AudioPlayerEvent.build('queueUpdate', {
        'queue': queue.tracks,
        'currentTrack': queue.currentTrack,
        'shuffled': queue.shuffled,
      }));
    }
    await AudioServiceBackground.setQueue(
      queue.tracks.map((t) => t.buildMediaItem()).toList(),
    );
    if (queue.currentTrack != null) {
      await AudioServiceBackground.setMediaItem(
        queue.currentTrack.buildMediaItem(),
      );
    }
  }

// Update the service state to reflect the current state
  updateState() {
    // Determine playback state
    BasicPlaybackState bpState = {
      AudioPlaybackState.none: BasicPlaybackState.none,
      AudioPlaybackState.stopped: BasicPlaybackState.stopped,
      AudioPlaybackState.paused: BasicPlaybackState.paused,
      AudioPlaybackState.playing: BasicPlaybackState.playing,
      AudioPlaybackState.connecting: BasicPlaybackState.connecting,
      AudioPlaybackState.completed: BasicPlaybackState.stopped,
    }[player.playbackState];
    // Determine controls
    bool playing = bpState == BasicPlaybackState.playing ||
        bpState == BasicPlaybackState.buffering;
    List<MediaControl> controls = [
      if (queue.hasPrevious()) MediaControls.previous,
      if (playing) MediaControls.pause,
      if (!playing) MediaControls.play,
      if (queue.hasNext()) MediaControls.next,
    ];
    // Determine actions
    List<MediaAction> actions = [
      if (playing || bpState == BasicPlaybackState.paused) MediaAction.seekTo,
      MediaAction.stop,
    ];
    // Set state
    AudioServiceBackground.setState(
      controls: controls,
      systemActions: actions,
      basicState: bpState,
      updateTime: player.playbackEvent?.updateTime?.inMilliseconds,
      position: (bpState == BasicPlaybackState.paused ||
          bpState == BasicPlaybackState.playing)
          ? player.playbackEvent?.position?.inMilliseconds ?? 0
          : 0,
    );
  }

// Stop the audio player
  stopPlayback() async {
    if (player != null &&
        (player.playbackState == AudioPlaybackState.playing ||
            player.playbackState == AudioPlaybackState.paused))
      await player.stop();
  }
}
