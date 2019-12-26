import 'dart:convert';
import 'dart:isolate';
import 'dart:ui';

import 'package:audio_service/audio_service.dart';
import 'package:rxdart/rxdart.dart';
import 'package:voc_amp/audio/vocamp-audio-player.dart';
import 'package:voc_amp/models/isolates/audio-player-event.dart';
import 'package:voc_amp/models/media/queued-track.dart';
import 'package:voc_amp/models/media/track.dart';

class AudioPlayerProvider {
  static const PORT_NAME = 'FRONT_PORT';

  ReceivePort _receivePort;
  Subject<List<QueuedTrack>> _queue = ReplaySubject(maxSize: 1);
  Subject<QueuedTrack> _currentTrack = ReplaySubject(maxSize: 1);
  Subject<bool> _shuffled = ReplaySubject(maxSize: 1);

  Stream<List<QueuedTrack>> get tracks => _queue.asBroadcastStream();

  Stream<QueuedTrack> get currentTrack => _currentTrack.asBroadcastStream();

  Stream<bool> get shuffled => _shuffled.asBroadcastStream();

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
      if (!running) return;
      // Make service fetch new send port
      await AudioService.customAction('refreshSendPort');
      // Request queue update
      await AudioService.customAction('getQueueState');
    });
  }

  dispose() {
    _receivePort.close();
    _queue.close();
    _currentTrack.close();
  }

  setQueue(List<Track> tracks) async {
    await _startService(); // Make sure service is started
    AudioService.customAction(
      'setQueue',
      jsonEncode(tracks.map((t) => QueuedTrack.fromTrack(t)).toList()),
    );
  }

  _startService() async {
    if (await AudioService.running) return;
    await AudioService.start(
      backgroundTaskEntrypoint: audioPlayerBackgroundTask,
      androidNotificationIcon: 'mipmap/ic_launcher',
    );
  }

  _handleEvent(AudioPlayerEvent event) async {
    switch (event.action) {
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
