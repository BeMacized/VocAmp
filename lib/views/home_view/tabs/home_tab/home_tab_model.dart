import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:meta/meta.dart';
import 'package:redux/redux.dart';
import 'package:vocaloid_player/api/vocadb_api.dart';
import 'package:vocaloid_player/globals.dart';
import 'package:vocaloid_player/model/queued_song.dart';
import 'package:vocaloid_player/model/vocadb/vocadb_album.dart';
import 'package:vocaloid_player/model/vocadb/vocadb_song.dart';
import 'package:vocaloid_player/redux/app_state.dart';
import 'package:vocaloid_player/redux/states/home_state.dart';
import 'package:vocaloid_player/redux/states/search_state.dart';
import 'package:vocaloid_player/views/album_view/album_view_model.dart';
import 'package:vocaloid_player/widgets/center_toast.dart';
import 'package:vocaloid_player/api/api_exceptions.dart';

class HomeTabModel {
  SearchState searchState;
  HomeState homeState;
  String currentSongContextId;

  HomeTabModel({
    @required this.searchState,
    @required this.homeState,
    @required this.currentSongContextId,
  });

  String generateSearchContextId(VocaDBSong song) {
    if (song == null) return null;
    return 'SEARCH_' + song.id.toString();
  }

  String generateHighlightedSongContextId(VocaDBSong song) {
    if (song == null) return null;
    return 'HOME_HIGHLIGHTED_' + song.id.toString();
  }

  static HomeTabModel fromStore(Store<AppState> store) {
    String currentSongContextId =
        store.state.player.currentSong?.contextId;
    return HomeTabModel(
        searchState: store.state.search,
        homeState: store.state.home,
        currentSongContextId: currentSongContextId);
  }

  playSongInList(VocaDBSong song, List<VocaDBSong> list, String contextId) async {
    List<QueuedSong> queue = list
        .where((song) => song.isAvailable)
        .map<QueuedSong>((song) {
      return QueuedSong.fromSong(
        song,
        song.firstAlbum,
        contextId: contextId,
      );
    }).toList();
    int cursor = list.indexOf(song);
    // Set Queue
    await Application.audioManager.setQueue(queue, cursor);
    await Application.audioManager.play();
  }

  void queueSong(BuildContext context, VocaDBSong song, String contextId) async {
    // Determine if we should start playing after queueing depending on if the queue was empty
    bool startPlay = Application.store.state.player.queue.length == 0;
    // Queue track
    await Application.audioManager.queueSong(
      QueuedSong.fromSong(
        song,
        song.firstAlbum,
        contextId: contextId
      ),
    );
    // Show toast
    CenterToast.showToast(context, icon: Icons.queue, text: 'Song queued');
    // Start
    if (startPlay) await Application.audioManager.play();
  }

  void playSongNext(BuildContext context, VocaDBSong song, String contextId) async {
    // Determine if we should start playing after queueing depending on if the queue was empty
    bool startPlay = Application.store.state.player.queue.length == 0;
    // Insert into queue
    await Application.audioManager.playSongNext(
      QueuedSong.fromSong(
        song,
        song.firstAlbum,
        contextId: contextId,
      ),
    );
    // Show toast
    CenterToast.showToast(context, icon: Icons.queue, text: 'Song plays next');
    // Start
    if (startPlay) await Application.audioManager.play();
  }

  void queueAlbum(BuildContext context, VocaDBAlbum album) async {
    try {
      album = await getAlbum(album.id);
    } on NotConnectedException {
      CenterToast.showToast(context,
          icon: Icons.error_outline, text: 'No Internet Connection');
      return;
    } catch (e) {
      CenterToast.showToast(context,
          icon: Icons.error_outline, text: 'Album could not be queued');
      return;
    }
    // Determine if we should start playing after queueing depending on if the queue was empty
    bool startPlay = Application.store.state.player.queue.length == 0;
    // Queue songs
    List<QueuedSong> queue = album.buildQueuedSongs(
        (song) => AlbumViewModel.generateContextId(song.id, album.id));
    await Application.audioManager.queueSongs(queue);
    // Show toast
    CenterToast.showToast(context, icon: Icons.queue, text: 'Album queued');
    // Start
    if (startPlay) await Application.audioManager.play();
  }

  void playAlbumNext(BuildContext context, VocaDBAlbum album) async {
    try {
      album = await getAlbum(album.id);
    } on NotConnectedException {
      CenterToast.showToast(context,
          icon: Icons.error_outline, text: 'No Internet Connection');
      return;
    } catch (e) {
      CenterToast.showToast(context,
          icon: Icons.error_outline, text: 'Album could not be queued');
      return;
    }
    // Determine if we should start playing after queueing depending on if the queue was empty
    bool startPlay = Application.store.state.player.queue.length == 0;
    // Queue songs
    List<QueuedSong> queue = album.buildQueuedSongs(
        (song) => AlbumViewModel.generateContextId(song.id, album.id));
    await Application.audioManager.playSongsNext(queue);
    // Show toast
    CenterToast.showToast(context, icon: Icons.queue, text: 'Album plays next');
    // Start
    if (startPlay) await Application.audioManager.play();
  }

  playAlbum(BuildContext context, VocaDBAlbum album,
      {AlbumViewModelTrack track}) async {
    try {
      album = await getAlbum(album.id);
    } on NotConnectedException {
      CenterToast.showToast(context,
          icon: Icons.error_outline, text: 'No Internet Connection');
      return;
    } catch (e) {
      CenterToast.showToast(context,
          icon: Icons.error_outline, text: 'Album could not be queued');
      return;
    }
    List<QueuedSong> queue = album.buildQueuedSongs(
        (song) => AlbumViewModel.generateContextId(song.id, album.id));
    // Set Queue
    await Application.audioManager.setQueue(queue, 0);
    await Application.audioManager.play();
  }
}
