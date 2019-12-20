import 'dart:async';

import 'package:audio_service/audio_service.dart';

class VocAmpAudioPlayer extends BackgroundAudioTask {
  Completer _serviceStopCompleter = Completer();

  @override
  onStart() async {
    // Wait for service stop
    await _serviceStopCompleter.future;
    return;
  }

  @override
  void onStop() {

    // Release service stop completer
    _serviceStopCompleter.complete();
  }


}
