import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'package:audio_service/audio_service.dart';
import 'package:voc_amp/models/media/queued-track.dart';

import 'audio-player-queue.dart';

void audioPlayerBackgroundTask() async {
  AudioServiceBackground.run(() => VocAmpAudioPlayer());
}

class VocAmpAudioPlayer extends BackgroundAudioTask {
  AudioPlayerQueue queue;
  Completer serviceStopCompleter = Completer();

  StreamSubscription queueSubscription;

  VocAmpAudioPlayer() {
    Isolate.current.errors.forEach((err) {
      if (err is Error) {
        print('$err ${err.stackTrace}');
      } else {
        print(err);
      }
    });
  }

  @override
  onStart() async {
    // Setup queue
    queue = AudioPlayerQueue();
    queueSubscription = queue.updated.listen((_) => this.onQueueUpdate());
    // Wait for service stop
    await serviceStopCompleter.future;
    return;
  }

  @override
  void onStop() {
    // Release service stop completer
    serviceStopCompleter.complete();
    queueSubscription.cancel();
  }

  @override
  void onCustomAction(String name, dynamic arguments) {
    switch (name) {
      case 'setQueue':
        return _handleSetQueue(arguments);
    }
  }

  void onQueueUpdate() {
    AudioServiceBackground.setQueue(
      queue.tracks.map((t) => t.track.buildMediaItem()).toList(),
    );
    MediaItem current = queue.currentTrack != null
        ? queue.currentTrack.track.buildMediaItem()
        : null;
    AudioServiceBackground.setMediaItem(current);
  }

  void _handleSetQueue(arguments) {
    List<QueuedTrack> tracks = (jsonDecode(arguments) as List<dynamic>)
        .map((t) => QueuedTrack.fromJson(t))
        .toList();
    queue.set(tracks);
  }
}
