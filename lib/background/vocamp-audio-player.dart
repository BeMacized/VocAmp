import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'dart:ui';
import 'package:audio_service/audio_service.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';
import 'package:voc_amp/background/utils/stream-utils.dart';
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

  //
  // PLAYER EVENTS
  //

  @override
  onStart() async {
    try {
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
      // Fetch send port
      refreshSendPort();
      // Setup completer and wait for service stop
      serviceStopCompleter = Completer();
      await serviceStopCompleter.future;
      // Clean up service before stop
      await stopPlayer();
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
    if (player.playbackState == AudioPlaybackState.playing)
      await player.pause();
  }

  @override
  Future<void> onSkipToNext() async {
    if (!queue.hasNext()) return;
    await stopPlayer();
    queue.next();
    await debouncedPlay.next();
  }

  @override
  Future<void> onSkipToPrevious() async {
    if (!queue.hasPrevious()) return;
    await stopPlayer();
    queue.previous();
    await debouncedPlay.next();
  }

  @override
  void onSkipToQueueItem(String mediaId) async {
    QueueTrack track =
        queue.tracks.singleWhere((t) => t.id == mediaId, orElse: () => null);
    if (track == null) return;
    await stopPlayer();
    queue.setCursor(track);
    await debouncedPlay.next();
  }

  @override
  Future<void> onStop() async {
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
    try {
      switch (player.playbackState) {
        case AudioPlaybackState.paused:
          await player.play();
          break;
        case AudioPlaybackState.completed:
        case AudioPlaybackState.none:
        case AudioPlaybackState.stopped:
          if (queue.currentTrack == null ||
              queue.currentTrack.track.sources.isEmpty) return;

          // Obtain audio url
          String audioUrl;
          try {
            audioUrl = await StreamUtils.getAudioStreamForQueueTrack(
                queue.currentTrack);
          } catch (e) {
            if (e is NoConnectionException) {
              Fluttertoast.showToast(
                msg:
                    'Playback is stopping as the music service could not be reached.',
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.BOTTOM,
              );
              await stopPlayer();
              return;
            }
            if (e is ExtractionException) {
              Fluttertoast.showToast(
                msg:
                    'An extraction error was encountered. The app will likely have to be updated.',
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.BOTTOM,
              );
              await stopPlayer();
              return;
            }
            rethrow;
          }
          // If no audio url can be obtained, skip to the next track.
          if (audioUrl == null) {
            QueueTrack nextTrack = queue.next();
            if (nextTrack != null) onPlay();
            return;
          }
          // Play audio url
          await stopPlayer();
          Duration duration = await player.setUrl(audioUrl);
          queue.currentTrack.cachedDuration = duration;
          sendQueueUpdate();
          AudioServiceBackground.setMediaItem(
            queue.currentTrack.buildMediaItem(),
          );
          await player.play();
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
    if (player.playbackState != AudioPlaybackState.none &&
        player.playbackState != AudioPlaybackState.connecting)
      player.seek(Duration(milliseconds: position));
  }

  void onPlayerStateChange(
      AudioPlaybackState oldState, AudioPlaybackState newState) {
    // When end of song is reached
    if (oldState == AudioPlaybackState.playing &&
        newState == AudioPlaybackState.completed) {
      if (queue.next() != null)
        onPlay();
      else {
        // TODO: Implement repeat modes
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
          return handleGetQueueState();
        case 'getPlaybackState':
          return handleGetPlaybackState();
      }
    } catch (e) {
      log.severe(['onCustomAction', name, e]);
      rethrow;
    }
  }

  //
  // CUSTOM ACTION HANDLERS
  //

  Future<void> handleSetQueue(Map<String, dynamic> arguments) async {
    List<QueueTrack> tracks = (arguments['tracks'] as List<dynamic>)
        .map((t) => QueueTrack.fromJson(t))
        .toList();
    QueueTrack cursor = arguments['cursor'] == null
        ? (tracks.isEmpty ? null : tracks[0])
        : QueueTrack.fromJson(arguments['cursor']);
    bool shuffled = (arguments['shuffled'] as bool) ?? false;
    await stopPlayer();
    queue.setShuffled(shuffled);
    queue.setTracks(tracks);
    if (cursor != null) queue.setCursor(cursor);
  }

  void handleRefreshSendPort() {
    refreshSendPort();
  }

  void handleGetQueueState() {
    return sendQueueUpdate();
  }

  void handleGetPlaybackState() {
    this.updateState();
  }

  //
  // UTILITIES
  //

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
  stopPlayer() async {
    if (player != null && player.playbackState == AudioPlaybackState.playing ||
        player.playbackState == AudioPlaybackState.paused) await player.stop();
  }
}
