import 'package:audio_service/audio_service.dart';
import 'package:vocaloid_player/audio/CustomAudioPlayer.dart';
import 'package:vocaloid_player/model/queued_song.dart';

class PlayerStateChangeAction {
  final int position;
  final BasicPlaybackState state;

  PlayerStateChangeAction({this.position, this.state});
}

class QueueChangeAction {
  final List<QueuedSong> queue;

  QueueChangeAction(this.queue);
}

class QueueIndexChangeAction {
  final int queueIndex;

  QueueIndexChangeAction(this.queueIndex);
}

class DurationChangeAction {
  final int duration;

  DurationChangeAction(this.duration);
}

class ChangeRepeatModeAction {
  final RepeatMode mode;

  ChangeRepeatModeAction(this.mode);
}

class SetShuffleModeAction {
  final bool mode;

  SetShuffleModeAction(this.mode);
}

class ReorderQueueItemAction {
  String itemId;
  int newIndex;

  ReorderQueueItemAction(this.itemId, this.newIndex);
}

class SetSelectedQueueItemsAction {
  List<String> selectedQueueItems;

  SetSelectedQueueItemsAction(this.selectedQueueItems);
}
