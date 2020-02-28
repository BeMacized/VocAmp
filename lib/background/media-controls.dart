import 'package:audio_service/audio_service.dart';

class MediaControls {
  static MediaControl play = MediaControl(
    androidIcon: 'drawable/ic_play_arrow',
    label: 'Play',
    action: MediaAction.play,
  );
  static MediaControl pause = MediaControl(
    androidIcon: 'drawable/ic_pause',
    label: 'Pause',
    action: MediaAction.pause,
  );
  static MediaControl next = MediaControl(
    androidIcon: 'drawable/ic_skip_next',
    label: 'Next',
    action: MediaAction.skipToNext,
  );
  static MediaControl previous = MediaControl(
    androidIcon: 'drawable/ic_skip_previous',
    label: 'Previous',
    action: MediaAction.skipToPrevious,
  );
}
