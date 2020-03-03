import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'dart:ui';

import 'package:audio_service/audio_service.dart';
import 'package:rxdart/rxdart.dart';
import 'package:voc_amp/background/vocamp-audio-player.dart';
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

  Stream<List<QueueTrack>> get tracks => _queue.asBroadcastStream();

  Stream<QueueTrack> get currentTrack => _currentTrack.asBroadcastStream();

  Stream<bool> get shuffled => _shuffled.asBroadcastStream();

  Stream<PlaybackState> get playbackState => _playbackState.asBroadcastStream();

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
      print('RUNNING $running');
      if (!running) return;
      // Make service fetch new send port
      await AudioService.customAction('refreshSendPort');
      // Request queue update
      await AudioService.customAction('getQueueState');
      // Request playbackState update
      await AudioService.customAction('getPlaybackState');
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
    if (!(await AudioService.running)) return;
    await AudioService.play();
  }

  Future<void> pause() async {
    if (!(await AudioService.running)) return;
    await AudioService.pause();
  }

  Future<void> skipNext() async {
    if (!(await AudioService.running)) return;
    await AudioService.skipToNext();
  }

  Future<void> skipPrevious() async {
    if (!(await AudioService.running)) return;
    await AudioService.skipToPrevious();
  }

  Future<void> skipToTrack(QueueTrack track) async {
    if (!(await AudioService.running)) return;
    await AudioService.skipToQueueItem(track.id);
  }

  Future<void> seek(Duration position) async {
    if (!(await AudioService.running)) return;
    await AudioService.seekTo(position.inSeconds);
  }

  Future<void> shuffle(bool value) async {
    if (!(await AudioService.running)) return;
    await AudioService.customAction('setShuffle', value);
  }

  _startService() async {
    if (await AudioService.running) return;
    await AudioService.start(
      androidStopForegroundOnPause: true,
      backgroundTaskEntrypoint: audioPlayerBackgroundTask,
      androidNotificationIcon: 'mipmap/ic_launcher',
    );
  }

  _handleEvent(AudioPlayerEvent event) async {
    switch (event.action) {
      case 'serviceStop':
        {
          _queue.add([]);
          _currentTrack.add(null);
          _shuffled.add(false);
          break;
        }
      case 'queueUpdate':
        {
          _queue.add(event.payload['queue']);
          _currentTrack.add(event.payload['currentTrack']);
          _shuffled.add(event.payload['shuffled']);
          break;
        }
    }
  }
}
