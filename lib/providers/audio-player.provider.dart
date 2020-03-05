import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'dart:ui';

import 'package:audio_service/audio_service.dart';
import 'package:rxdart/rxdart.dart';
import 'package:voc_amp/background/vocamp-audio-player.dart';
import 'package:voc_amp/models/audio/repeat-mode.dart';
import 'package:voc_amp/models/isolates/audio-player-event.dart';
import 'package:voc_amp/models/media/queue-track.dart';

class AudioPlayerProvider {
  static const PORT_NAME = 'FRONT_PORT';

  StreamSubscription _playbackStateSubscription;

  ReceivePort _receivePort;
  Subject<List<QueueTrack>> _queue = ReplaySubject(maxSize: 1);
  Subject<QueueTrack> _currentTrack = ReplaySubject(maxSize: 1);
  Subject<bool> _shuffled = ReplaySubject(maxSize: 1);
  Subject<PlaybackState> _playbackState = ReplaySubject(maxSize: 1);
  Subject<RepeatMode> _repeatMode = ReplaySubject(maxSize: 1);
  Subject<bool> _taskReady = BehaviorSubject.seeded(false);
  Subject<bool> _taskStarted = BehaviorSubject.seeded(false);

  Stream<List<QueueTrack>> get tracks => _queue.asBroadcastStream();

  Stream<QueueTrack> get currentTrack => _currentTrack.asBroadcastStream();

  Stream<bool> get shuffled => _shuffled.asBroadcastStream();

  Stream<PlaybackState> get playbackState => _playbackState.asBroadcastStream();

  Stream<RepeatMode> get repeatMode => _repeatMode.asBroadcastStream();

  // Started & ready
  Stream<bool> get taskReady => _taskReady.asBroadcastStream();

  // Only started (Not necessarily ready)
  Stream<bool> get taskStarted => _taskStarted.asBroadcastStream();

  AudioPlayerProvider() {
    // Create receive port
    _receivePort = ReceivePort();
    // If previous send port already register, unregister it
    if (IsolateNameServer.lookupPortByName(PORT_NAME) != null)
      IsolateNameServer.removePortNameMapping(PORT_NAME);
    // Register new send port
    IsolateNameServer.registerPortWithName(_receivePort.sendPort, PORT_NAME);
    // Handle events coming over port
    _receivePort.listen((e) => _handleEvent(e));
    // Initialize if audio server is already running
    AudioService.running.then((running) async {
      _taskReady.add(false);
      _taskStarted.add(false);
      if (!running) return;
      // Make service fetch new send port
      await AudioService.customAction('refreshSendPort');
      // Request playerFlags update
      await AudioService.customAction('getPlayerFlags');
      // Request queue update
      AudioService.customAction('getQueueState');
      // Request playbackState update
      AudioService.customAction('getPlaybackState');
    });
    // Subscribe to events
    _playbackStateSubscription = AudioService.playbackStateStream.listen(
      (state) => _playbackState.add(state),
    );
  }

  MediaItem get currentMediaItem => AudioService.currentMediaItem;

  dispose() {
    _playbackStateSubscription?.cancel();
    _receivePort?.close();
    _queue?.close();
    _currentTrack?.close();
    _shuffled?.close();
    _playbackState?.close();
    _repeatMode?.close();
    _taskReady?.close();
    _taskStarted?.close();
  }

  Future<void> setQueue(List<QueueTrack> tracks,
      {QueueTrack cursor, bool shuffled = false}) async {
    await _startService();
    await AudioService.customAction(
      'setQueue',
      jsonEncode({
        'tracks': tracks,
        'cursor': cursor ?? (tracks.isEmpty ? null : tracks[0]),
        'shuffled': shuffled
      }),
    );
  }

  Future<void> play() async {
    await (taskReady.firstWhere((ready) => ready));
    await AudioService.play();
  }

  Future<void> pause() async {
    await (taskReady.firstWhere((ready) => ready));
    await AudioService.pause();
  }

  Future<void> skipNext() async {
    await (taskReady.firstWhere((ready) => ready));
    await AudioService.skipToNext();
  }

  Future<void> skipPrevious() async {
    await (taskReady.firstWhere((ready) => ready));
    await AudioService.skipToPrevious();
  }

  Future<void> skipToTrack(QueueTrack track) async {
    await (taskReady.firstWhere((ready) => ready));
    await AudioService.skipToQueueItem(track.id);
  }

  Future<void> seek(Duration position) async {
    await (taskReady.firstWhere((ready) => ready));
    await AudioService.seekTo(position.inSeconds);
  }

  Future<void> shuffle(bool value) async {
    await (taskReady.firstWhere((ready) => ready));
    await AudioService.customAction('setShuffle', value);
  }

  Future<void> repeat(RepeatMode mode) async {
    await (taskReady.firstWhere((ready) => ready));
    await AudioService.customAction('setRepeat', jsonEncode({'mode': mode}));
  }

  Future<void> _startService() async {
    if (!(await _taskStarted.first)) {
      _taskStarted.add(true);
      AudioService.start(
        androidStopForegroundOnPause: true,
        backgroundTaskEntrypoint: audioPlayerBackgroundTask,
        androidNotificationIcon: 'mipmap/ic_launcher',
      );
    }
    await _taskReady.firstWhere((ready) => ready);
    return;
  }

  _handleEvent(AudioPlayerEvent event) async {
    switch (event.action) {
      case 'serviceStop':
        {
          _queue.add([]);
          _currentTrack.add(null);
          _shuffled.add(false);
          _taskReady.add(false);
          _taskStarted.add(false);
          break;
        }
      case 'queueUpdate':
        {
          _queue.add(event.payload['queue']);
          _currentTrack.add(event.payload['currentTrack']);
          _shuffled.add(event.payload['shuffled']);
          break;
        }
      case 'playerFlags':
        {
          _repeatMode.add(event.payload['repeatMode']);
          _taskReady.add(event.payload['ready']);
          break;
        }
    }
  }
}
