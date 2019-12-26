import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'dart:ui';
import 'package:audio_service/audio_service.dart';
import 'package:voc_amp/models/isolates/audio-player-event.dart';
import 'package:voc_amp/models/media/queued-track.dart';
import 'package:voc_amp/providers/audio-player.provider.dart';

import 'audio-player-queue.dart';

void audioPlayerBackgroundTask() async {
  AudioServiceBackground.run(() => VocAmpAudioPlayer());
}

class VocAmpAudioPlayer extends BackgroundAudioTask {
  AudioPlayerQueue queue;
  Completer serviceStopCompleter = Completer();
  StreamSubscription queueSubscription;
  SendPort sendPort;

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
    // Fetch send port
    onRefreshSendPort();
    // Wait for service stop
    await serviceStopCompleter.future;
    return;
  }

  @override
  void onStop() {
    // Release service stop completer
    serviceStopCompleter.complete();
    queueSubscription.cancel();
    queue.dispose();
  }

  @override
  void onCustomAction(String name, dynamic arguments) {
    switch (name) {
      case 'setQueue':
        return handleSetQueue(arguments);
      case 'refreshSendPort':
        return onRefreshSendPort();
      case 'getQueueState':
        return onQueueUpdate();
    }
  }

  void onRefreshSendPort() {
    sendPort =
        IsolateNameServer.lookupPortByName(AudioPlayerProvider.PORT_NAME);
  }

  void onQueueUpdate() {
    AudioServiceBackground.setQueue(
      queue.tracks.map((t) => t.buildMediaItem()).toList(),
    );
    AudioServiceBackground.setMediaItem(
      queue.currentTrack != null ? queue.currentTrack.buildMediaItem() : null,
    );
    print(queue.currentTrack?.buildMediaItem()?.artUri);
    if (sendPort != null) {
      sendPort.send(AudioPlayerEvent.build('queueUpdate', {
        'queue': queue.tracks,
        'currentTrack': queue.currentTrack,
        'shuffled': queue.shuffled,
      }));
    }
  }

  void handleSetQueue(arguments) {
    List<QueuedTrack> tracks = (jsonDecode(arguments) as List<dynamic>)
        .map((t) => QueuedTrack.fromJson(t))
        .toList();
    queue.set(tracks);
  }
}
