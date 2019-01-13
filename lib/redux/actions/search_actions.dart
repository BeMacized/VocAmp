import 'package:flutter/material.dart';
import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';
import 'package:vocaloid_player/api/vocadb_api.dart';
import 'package:vocaloid_player/api/api_exceptions.dart';
import 'package:vocaloid_player/model/vocadb/vocadb_album.dart';
import 'package:vocaloid_player/model/vocadb/vocadb_song.dart';
import 'package:vocaloid_player/redux/app_state.dart';
import 'package:vocaloid_player/model/status_data.dart';

class QueryingSearchAction {
  final String query;

  QueryingSearchAction(this.query);
}

class ErrorQueryingSearchAction {
  StatusData errorState;

  ErrorQueryingSearchAction(this.errorState);
}

class ReceivedSearchQueryResultsAction {
  final List<VocaDBAlbum> albumResults;
  final List<VocaDBSong> songResults;

  ReceivedSearchQueryResultsAction(this.albumResults, this.songResults);
}

ThunkAction<AppState> searchQueryAction(String query) {
  return (Store<AppState> store) async {
    // Dispatch loading action
    store.dispatch(QueryingSearchAction(query));

    // If query was empty, return empty results
    if (query.trim() == '') {
      store.dispatch(ReceivedSearchQueryResultsAction([], []));
      return;
    }

    try {
      List<VocaDBAlbum> albums = await searchAlbums(query, maxResults: 50);
      List<VocaDBSong> songs = await searchSongs(query, maxResults: 50);
      store.dispatch(ReceivedSearchQueryResultsAction(albums, songs));
    } on NotConnectedException {
      store.dispatch(
        ErrorQueryingSearchAction(
          StatusData(
              icon: Icons.signal_wifi_off,
              title: "You're Offline",
              subtitle: "Please connect to the internet and try again."),
        ),
      );
    } on CantReachException {
      store.dispatch(
        ErrorQueryingSearchAction(
          StatusData(
              icon: Icons.warning,
              title: "Can't Reach VocaDB",
              subtitle:
                  "The server could not be reached. Please try again later."),
        ),
      );
    } on InternalServerErrorException {
      store.dispatch(
        ErrorQueryingSearchAction(
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
        ErrorQueryingSearchAction(
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
          ErrorQueryingSearchAction(
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
        ErrorQueryingSearchAction(
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
