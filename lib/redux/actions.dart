import 'package:audio_service/audio_service.dart';
import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';
import 'package:vocaloid_player/api/vocadb_api.dart';
import 'package:vocaloid_player/audio/CustomAudioPlayer.dart';
import 'package:vocaloid_player/model/QueuedSong.dart';
import 'package:vocaloid_player/model/vocadb/vocadb_album.dart';
import 'package:vocaloid_player/redux/app_state.dart';

//
// ALBUM ACTIONS
//

class LoadedAlbumAction {
  final VocaDBAlbum album;

  LoadedAlbumAction(this.album);
}

class LoadingAlbumAction {}

ThunkAction<AppState> loadAlbumAction(int albumId) {
  return (Store<AppState> store) async {
    // Dispatch loading action
    store.dispatch(LoadingAlbumAction());
    // Load the album
    VocaDBAlbum album = await getAlbum(albumId);
    // Dispatch loaded action
    store.dispatch(LoadedAlbumAction(album));
  };
}

//
// PLAYER ACTIONS
//

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
