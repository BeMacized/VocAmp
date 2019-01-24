import 'package:flutter/material.dart';
import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';
import 'package:vocaloid_player/api/vocadb_api.dart';
import 'package:vocaloid_player/api/api_exceptions.dart';
import 'package:vocaloid_player/model/status_data.dart';
import 'package:vocaloid_player/model/vocadb/vocadb_album.dart';
import 'package:vocaloid_player/model/vocadb/vocadb_song.dart';
import 'package:vocaloid_player/redux/app_state.dart';

class SetHomeTabAction {
  final int index;

  SetHomeTabAction(this.index);
}

class LoadingHomeHighlightedSongsAction {}

class LoadedHomeHighlightedSongsAction {
  final List<VocaDBSong> songs;

  LoadedHomeHighlightedSongsAction(this.songs);
}

class ErrorLoadingHomeHighlightedSongsAction {
  final StatusData statusData;

  ErrorLoadingHomeHighlightedSongsAction(this.statusData);
}

ThunkAction<AppState> loadHomeHighlightedSongsAction() {
  return (Store<AppState> store) async {
    // Dispatch loading action
    store.dispatch(LoadingHomeHighlightedSongsAction());

    try {
      List<VocaDBSong> songs = await getHighlightedSongs();
      store.dispatch(LoadedHomeHighlightedSongsAction(songs));
    } on NotConnectedException {
      store.dispatch(
        ErrorLoadingHomeHighlightedSongsAction(
          StatusData(
              icon: Icons.signal_wifi_off,
              title: "You're Offline",
              subtitle: "Please connect to the internet and try again."),
        ),
      );
    } on CantReachException {
      store.dispatch(
        ErrorLoadingHomeHighlightedSongsAction(
          StatusData(
              icon: Icons.warning,
              title: "Can't Reach VocaDB",
              subtitle:
                  "The server could not be reached. Please try again later."),
        ),
      );
    } on InternalServerErrorException {
      store.dispatch(
        ErrorLoadingHomeHighlightedSongsAction(
          StatusData(
              icon: Icons.error_outline,
              title: "Server Error",
              subtitle:
                  "The server encountered an error. Please try again later."),
        ),
      );
    } on UnknownAPIErrorException catch (e) {
      print(e.data);
      store.dispatch(
        ErrorLoadingHomeHighlightedSongsAction(
          StatusData(
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
      if (e is BadRequestException || e is NotFoundException) {
        store.dispatch(
          ErrorLoadingHomeHighlightedSongsAction(
            StatusData(
              icon: Icons.error,
              title: "Bad Request",
              subtitle:
                  "Uh oh, looks like we made a mistake. Please submit a bug report, with some steps explaining how you got this to happen.",
            ),
          ),
        );
        return;
      }

      print(e);
      store.dispatch(
        ErrorLoadingHomeHighlightedSongsAction(
          StatusData(
              icon: Icons.error,
              title: "Unknown Error",
              subtitle:
                  "Uh oh, something went very wrong. Please submit a bug report, with some steps explaining how you got this to happen."),
        ),
      );
    }
  };
}

class LoadingHomeTopAlbumsAction {}

class LoadedHomeTopAlbumsAction {
  final List<VocaDBAlbum> albums;

  LoadedHomeTopAlbumsAction(this.albums);
}

class ErrorLoadingHomeTopAlbumsAction {
  final StatusData statusData;

  ErrorLoadingHomeTopAlbumsAction(this.statusData);
}

ThunkAction<AppState> loadHomeTopAlbumsAction() {
  return (Store<AppState> store) async {
    // Dispatch loading action
    store.dispatch(LoadingHomeTopAlbumsAction());

    try {
      List<VocaDBAlbum> albums = await getRandomTopAlbums();
      store.dispatch(LoadedHomeTopAlbumsAction(albums));
    } on NotConnectedException {
      store.dispatch(
        ErrorLoadingHomeTopAlbumsAction(
          StatusData(
              icon: Icons.signal_wifi_off,
              title: "You're Offline",
              subtitle: "Please connect to the internet and try again."),
        ),
      );
    } on CantReachException {
      store.dispatch(
        ErrorLoadingHomeTopAlbumsAction(
          StatusData(
              icon: Icons.warning,
              title: "Can't Reach VocaDB",
              subtitle:
                  "The server could not be reached. Please try again later."),
        ),
      );
    } on InternalServerErrorException {
      store.dispatch(
        ErrorLoadingHomeTopAlbumsAction(
          StatusData(
              icon: Icons.error_outline,
              title: "Server Error",
              subtitle:
                  "The server encountered an error. Please try again later."),
        ),
      );
    } on UnknownAPIErrorException catch (e) {
      print(e.data);
      store.dispatch(
        ErrorLoadingHomeTopAlbumsAction(
          StatusData(
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
      if (e is BadRequestException || e is NotFoundException) {
        store.dispatch(
          ErrorLoadingHomeTopAlbumsAction(
            StatusData(
              icon: Icons.error,
              title: "Bad Request",
              subtitle:
                  "Uh oh, looks like we made a mistake. Please submit a bug report, with some steps explaining how you got this to happen.",
            ),
          ),
        );
        return;
      }

      print(e);
      store.dispatch(
        ErrorLoadingHomeTopAlbumsAction(
          StatusData(
              icon: Icons.error,
              title: "Unknown Error",
              subtitle:
                  "Uh oh, something went very wrong. Please submit a bug report, with some steps explaining how you got this to happen."),
        ),
      );
    }
  };
}
