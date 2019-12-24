import 'dart:convert';

import 'package:audio_service/audio_service.dart';
import 'package:voc_amp/audio/vocamp-audio-player.dart';
import 'package:voc_amp/models/media/queued-track.dart';
import 'package:voc_amp/models/media/track.dart';

class AudioPlayerProvider {
  AudioPlayerProvider();

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
}
