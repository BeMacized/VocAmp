import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:meta/meta.dart';
import 'package:redux/redux.dart';
import 'package:vocaloid_player/globals.dart';
import 'package:vocaloid_player/model/QueuedSong.dart';
import 'package:vocaloid_player/model/vocadb/vocadb_song.dart';
import 'package:vocaloid_player/redux/app_state.dart';
import 'package:vocaloid_player/redux/states/search_state.dart';
import 'package:vocaloid_player/widgets/center_toast.dart';

class HomeTabModel {
  SearchState searchState;
  String currentSongContextId;

  HomeTabModel({
    @required this.searchState,
    @required this.currentSongContextId,
  });

  static String _generateContextId(int songId) {
    if (songId == null) return null;
    return 'SEARCH_' + songId.toString();
  }

  bool isSongActive(VocaDBSong song) {
    return _generateContextId(song.id) == currentSongContextId;
  }

  static HomeTabModel fromStore(Store<AppState> store) {
    String currentSongContextId =
        store.state.playerState.currentSong?.contextId;
    return HomeTabModel(
        searchState: store.state.searchState,
        currentSongContextId: currentSongContextId);
  }

  playSongSearchResults(VocaDBSong song) async {
    List<QueuedSong> queue = searchState.songResults
        .where((song) => song.isAvailable)
        .map<QueuedSong>((song) {
      return QueuedSong.fromSong(song, contextId: _generateContextId(song.id));
    }).toList();
    int cursor = searchState.songResults.indexOf(song);
    // Set Queue
    await Application.audioManager.setQueue(queue, cursor);
    await Application.audioManager.play();
  }

  void queueSong(BuildContext context, VocaDBSong song) async {
    // Determine if we should start playing after queueing depending on if the queue was empty
    bool startPlay = Application.store.state.playerState.queue.length == 0;
    // Queue track
    await Application.audioManager.queueSong(
      QueuedSong.fromSong(
        song,
        contextId: _generateContextId(song.id),
      ),
    );
    // Show toast
    CenterToast.showToast(context, icon: Icons.queue, text: 'Song queued');
    // Start
    if (startPlay) await Application.audioManager.play();
  }

  void playSongNext(BuildContext context, VocaDBSong song) async {
    // Determine if we should start playing after queueing depending on if the queue was empty
    bool startPlay = Application.store.state.playerState.queue.length == 0;
    // Insert into queue
    await Application.audioManager.playSongNext(
      QueuedSong.fromSong(
        song,
        contextId: _generateContextId(song.id),
      ),
    );
    // Show toast
    CenterToast.showToast(context, icon: Icons.queue, text: 'Song plays next');
    // Start
    if (startPlay) await Application.audioManager.play();
  }
}
