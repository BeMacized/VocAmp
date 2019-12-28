import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'dart:ui';
import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';
import 'package:voc_amp/models/isolates/audio-player-event.dart';
import 'package:voc_amp/models/media/queue-track.dart';
import 'package:voc_amp/models/media/track-source.dart';
import 'package:voc_amp/providers/audio-player.provider.dart';
import 'package:youtube_extractor/youtube_extractor.dart';

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

  @override
  onStart() async {
    try {
      // Setup queue
      queue = AudioPlayerQueue();
      StreamSubscription queueSubscription =
          queue.updated.listen((_) => this.onQueueUpdate());
      // Setup audio player
      player = AudioPlayer();
      StreamSubscription playerSubscription = Rx.combineLatest3(
        player.playbackStateStream,
        player.durationStream,
        player.getPositionStream(),
        (AudioPlaybackState state, Duration duration, Duration position) {
          return {
            'state': state ?? player.playbackState,
            'duration': duration ?? Duration(seconds: 0),
            'position': position ?? Duration(seconds: 0)
          };
        },
      ).listen((m) => onPlayerUpdate(m['state'], m['duration'], m['position']));
      // Fetch send port
      onRefreshSendPort();
      // Setup completer and wait for service stop
      serviceStopCompleter = Completer();
      await serviceStopCompleter.future;
      // Clean up service before stop
      await stopPlayer();
      queueSubscription.cancel();
      playerSubscription.cancel();
      queue.dispose();
    } catch (e) {
      print('[AudioService] onStart: $e');
      rethrow;
    }
  }

  @override
  void onPause() async {
    if (player.playbackState == AudioPlaybackState.playing ||
        player.playbackState == AudioPlaybackState.buffering ||
        player.playbackState == AudioPlaybackState.connecting)
      await player.pause();
  }

  @override
  Future<void> onSkipToNext() async {
    if (!queue.hasNext()) return;
    queue.next();
    await stopPlayer();
    await onPlay();
  }

  @override
  Future<void> onSkipToPrevious() async {
    if (!queue.hasPrevious()) return;
    queue.previous();
    await stopPlayer();
    await onPlay();
  }

  @override
  Future<void> onStop() async {
    try {
      // Release completer
      serviceStopCompleter.complete();
    } catch (e) {
      print('[AudioService] onStop: $e');
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
        case AudioPlaybackState.none:
        case AudioPlaybackState.stopped:
          if (queue.currentTrack == null ||
              queue.currentTrack.track.sources.isEmpty) return;
          // Obtain audio url
          String audioUrl = await getAudioUrl(queue.currentTrack);
          // If no audio url can be obtained, skip to the next track.
          if (audioUrl == null) {
            queue.next();
            onPlay();
            return;
          }
          // Play audio url
          Duration duration = await player.setUrl(audioUrl);
          AudioServiceBackground.setMediaItem(
            queue.currentTrack.buildMediaItem(duration: duration),
          );
          await player.play();
          break;
        case AudioPlaybackState.buffering:
        case AudioPlaybackState.connecting:
        case AudioPlaybackState.playing:
          break;
        default:
          throw 'Unknown playback state';
      }
    } catch (e) {
      print('[AudioService] onPlay: $e');
      rethrow;
    }
  }

  @override
  void onSeekTo(int position) {
    if (player.playbackState == AudioPlaybackState.playing ||
        player.playbackState == AudioPlaybackState.paused)
      player.seek(Duration(milliseconds: position));
  }

  @override
  Future<void> onCustomAction(String name, dynamic arguments) async {
    try {
      switch (name) {
        case 'setQueue':
          return await handleSetQueue(jsonDecode(arguments));
        case 'refreshSendPort':
          return onRefreshSendPort();
        case 'getQueueState':
          return onQueueUpdate();
      }
    } catch (e) {
      print('[AudioService] onCustomAction: $e');
      rethrow;
    }
  }

  void onRefreshSendPort() {
    sendPort =
        IsolateNameServer.lookupPortByName(AudioPlayerProvider.PORT_NAME);
  }

  void onQueueUpdate() async {
    await AudioServiceBackground.setQueue(
      queue.tracks.map((t) => t.buildMediaItem()).toList(),
    );
    if (queue.currentTrack != null) {
      await AudioServiceBackground.setMediaItem(
        queue.currentTrack.buildMediaItem(),
      );
    }
    if (sendPort != null) {
      sendPort.send(AudioPlayerEvent.build('queueUpdate', {
        'queue': queue.tracks,
        'currentTrack': queue.currentTrack,
        'shuffled': queue.shuffled,
      }));
    }
  }

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

  Future<String> getAudioUrl(QueueTrack track) async {
    if (track.track.sources.isEmpty)
      throw 'Cannot obtain audio url for track without sources.';
    // Dependencies
    YouTubeExtractor extractor;
    // Try getting audio stream for each source until one works
    SOURCE_LOOP:
    for (TrackSource source in track.track.sources) {
      switch (source.type) {
        case 'Youtube':
          if (extractor == null) extractor = YouTubeExtractor();
          String videoId = source.data['id'];
          try {
            var streamInfo = (await extractor.getMediaStreamsAsync(videoId));
            String audioUrl = streamInfo.audio
                .map((stream) => stream.url)
                .firstWhere((url) => url != null, orElse: () => null);
            if (audioUrl != null) {
              return audioUrl;
            } else {
              print('No audio stream available for YouTube video "$videoId"');
              continue SOURCE_LOOP;
            }
          } catch (e) {
            print(
                'Could not obtain audio stream for YouTube video "$videoId": $e');
            continue SOURCE_LOOP;
          }
          break;
        default:
          throw 'UNSUPPORTED TRACK SOURCE: ${source.type}';
      }
    }
    return null;
  }

  onPlayerUpdate(
      AudioPlaybackState apState, Duration duration, Duration position) {
    // Determine playback state
    BasicPlaybackState bpState = {
      AudioPlaybackState.none: BasicPlaybackState.none,
      AudioPlaybackState.stopped: BasicPlaybackState.stopped,
      AudioPlaybackState.paused: BasicPlaybackState.paused,
      AudioPlaybackState.playing: BasicPlaybackState.playing,
      AudioPlaybackState.buffering: BasicPlaybackState.buffering,
      AudioPlaybackState.connecting: BasicPlaybackState.connecting,
      //TODO: CHECK LATER
      AudioPlaybackState.completed: BasicPlaybackState.paused,
    }[apState];
    // Determine controls
    bool playing = bpState == BasicPlaybackState.playing ||
        bpState == BasicPlaybackState.buffering ||
        bpState == BasicPlaybackState.connecting;
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
      updateTime: DateTime.now().millisecondsSinceEpoch,
      position: position.inMilliseconds,
    );
  }

  stopPlayer() async {
    if (player.playbackState == AudioPlaybackState.playing ||
        player.playbackState == AudioPlaybackState.buffering ||
        player.playbackState == AudioPlaybackState.paused) await player.stop();
  }
}
