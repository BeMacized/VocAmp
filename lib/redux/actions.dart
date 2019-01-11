import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';
import 'package:vocaloid_player/api/vocadb_api.dart';
import 'package:vocaloid_player/audio/CustomAudioPlayer.dart';
import 'package:vocaloid_player/model/QueuedSong.dart';
import 'package:vocaloid_player/model/vocadb/vocadb_album.dart';
import 'package:vocaloid_player/redux/app_state.dart';
import 'package:vocaloid_player/api/api_exceptions.dart';

//
// ALBUM ACTIONS
//

class LoadedAlbumAction {
  final VocaDBAlbum album;

  LoadedAlbumAction(this.album);
}

class ErrorLoadingAlbumAction {
  ErrorState errorState;

  ErrorLoadingAlbumAction(this.errorState);
}

class LoadingAlbumAction {}

ThunkAction<AppState> loadAlbumAction(int albumId) {
  return (Store<AppState> store) async {
    // Dispatch loading action
    store.dispatch(LoadingAlbumAction());
    try {
      // Load the album
      VocaDBAlbum album = await getAlbum(albumId);
      // Dispatch loaded action
      store.dispatch(LoadedAlbumAction(album));
    } on NotConnectedException {
      store.dispatch(
        ErrorLoadingAlbumAction(
          ErrorState(
              icon: Icons.signal_wifi_off,
              title: "You're Offline",
              subtitle: "Please connect to the internet and try again."),
        ),
      );
    } on CantReachException {
      store.dispatch(
        ErrorLoadingAlbumAction(
          ErrorState(
              icon: Icons.warning,
              title: "Can't Reach VocaDB",
              subtitle:
                  "The server could not be reached. Please try again later."),
        ),
      );
    } on InternalServerErrorException {
      store.dispatch(
        ErrorLoadingAlbumAction(
          ErrorState(
              icon: Icons.error_outline,
              title: "Server Error",
              subtitle:
                  "The server encountered an error. Please try again later."),
        ),
      );
    } on NotFoundException {
      store.dispatch(
        ErrorLoadingAlbumAction(
          ErrorState(
            icon: Icons.album,
            title: "Album Not Found",
            subtitle: "This album could not be found. Maybe it got removed?",
          ),
        ),
      );
    } on BadRequestException {
      store.dispatch(
        ErrorLoadingAlbumAction(
          ErrorState(
            icon: Icons.error,
            title: "Bad Request",
            subtitle:
                "Uh oh, looks like we made a mistake. Please submit a bug report, with some steps explaining how you got this to happen.",
          ),
        ),
      );
    } on UnknownAPIErrorException catch (e) {
      print(e.data);
      store.dispatch(
        ErrorLoadingAlbumAction(
          ErrorState(
            icon: Icons.error,
            title: "Unknown Error",
            subtitle:
                "Uh oh, something went very wrong. Please submit a bug report, with some steps explaining how you got this to happen." +
                    (e.statusCode != null
                        ? " Response code: " + e.statusCode.toString()
                        : ""),
          ),
        ),
      );
    } catch (e) {
      print(e);
      store.dispatch(
        ErrorLoadingAlbumAction(
          ErrorState(
              icon: Icons.error,
              title: "Unknown Error",
              subtitle:
                  "Uh oh, something went very wrong. Please submit a bug report, with some steps explaining how you got this to happen."),
        ),
      );
    }
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
