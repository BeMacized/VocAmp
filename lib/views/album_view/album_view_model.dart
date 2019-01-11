import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:redux/redux.dart';
import 'package:vocaloid_player/globals.dart';
import 'package:vocaloid_player/model/QueuedSong.dart';
import 'package:vocaloid_player/model/vocadb/vocadb_song.dart';
import 'package:vocaloid_player/model/vocadb/vocadb_songinalbum.dart';
import 'package:vocaloid_player/redux/app_state.dart';
import 'package:collection/collection.dart';
import 'package:vocaloid_player/widgets/center_toast.dart';

class AlbumViewModelTrack {
  final int id;
  final String name;
  final String artistString;
  final int trackNumber;
  final int discNumber;
  final bool active;
  final VocaDBSong song;

  AlbumViewModelTrack(
      {this.id,
      this.name,
      this.artistString,
      this.discNumber,
      this.trackNumber,
      this.song,
      this.active});

  static AlbumViewModelTrack fromVocaDBSongInAlbum(VocaDBSongInAlbum track,
      {bool active = false}) {
    return AlbumViewModelTrack(
        id: track.id,
        active: active,
        name: track.name,
        artistString: track.song?.artistString,
        discNumber: track.discNumber,
        trackNumber: track.trackNumber,
        song: track.song);
  }
}

class AlbumViewModel {
  ErrorState errorState;
  int albumId;
  String title;
  String albumImageUrl;
  String artistsString;
  Map<int, List<AlbumViewModelTrack>> discs;
  bool loading = true;

  AlbumViewModel(
      {this.albumId,
      this.title,
      this.albumImageUrl,
      this.artistsString,
      this.discs,
      this.loading,
      this.errorState});

  static String _generateContextId(int songId, int albumId) {
    if (songId == null || albumId == null) return null;
    return 'ALBUM_' + albumId.toString() + '_' + songId.toString();
  }

  List<QueuedSong> _buildQueuedSongs() {
    // Merge discs && filter to playable tracks
    List<VocaDBSong> items = discs.values
        .expand((songs) => songs)
        .where((song) => song.song != null && song.song.isAvailable)
        .map((song) => song.song)
        .toList();
    // Generate songs for queueing
    List<QueuedSong> queue = items
        .map<QueuedSong>(
          (song) => QueuedSong.fromSong(
                song,
                albumName: title,
                albumArtUrl: albumImageUrl,
                contextId: _generateContextId(song.id, albumId),
              ),
        )
        .toList();
    return queue;
  }

  int _getQueueIndexForTrack(AlbumViewModelTrack track) {
    if (track == null) return 0;
    // Merge discs && filter to playable tracks
    List<AlbumViewModelTrack> items = discs.values
        .expand((songs) => songs)
        .where((song) => song.song != null && song.song.isAvailable)
        .toList();
    // Determine cursor
    return items.indexOf(track).clamp(0, items.length);
  }

  queueTrack(BuildContext context, AlbumViewModelTrack track) async {
    // Determine if we should start playing after queueing depending on if the queue was empty
    bool startPlay = Application.store.state.playerState.queue.length == 0;
    // Queue track
    await Application.audioManager.queueSong(
      QueuedSong.fromSong(
        track.song,
        albumName: title,
        albumArtUrl: albumImageUrl,
        contextId: _generateContextId(track.song.id, albumId),
      ),
    );
    // Show toast
    CenterToast.showToast(context, icon: Icons.queue, text: 'Song queued');
    // Start
    if (startPlay) await Application.audioManager.play();
  }

  playTrackNext(BuildContext context, AlbumViewModelTrack track) async {
    // Determine if we should start playing after queueing depending on if the queue was empty
    bool startPlay = Application.store.state.playerState.queue.length == 0;
    // Insert into queue
    await Application.audioManager.playSongNext(
      QueuedSong.fromSong(
        track.song,
        albumName: title,
        albumArtUrl: albumImageUrl,
        contextId: _generateContextId(track.song.id, albumId),
      ),
    );
    // Show toast
    CenterToast.showToast(context, icon: Icons.queue, text: 'Song plays next');
    // Start
    if (startPlay) await Application.audioManager.play();
  }

  queueAlbum(BuildContext context) async {
    // Determine if we should start playing after queueing depending on if the queue was empty
    bool startPlay = Application.store.state.playerState.queue.length == 0;
    // Queue songs
    await Application.audioManager.queueSongs(_buildQueuedSongs());
    // Show toast
    CenterToast.showToast(context, icon: Icons.queue, text: 'Album queued');
    // Start
    if (startPlay) await Application.audioManager.play();
  }

  playAlbumNext(BuildContext context) async {
    // Determine if we should start playing after queueing depending on if the queue was empty
    bool startPlay = Application.store.state.playerState.queue.length == 0;
    // Queue songs
    await Application.audioManager.playSongsNext(_buildQueuedSongs());
    // Show toast
    CenterToast.showToast(context, icon: Icons.queue, text: 'Album plays next');
    // Start
    if (startPlay) await Application.audioManager.play();
  }

  playAlbum({AlbumViewModelTrack track}) async {
    List<QueuedSong> queue = _buildQueuedSongs();
    int cursor = _getQueueIndexForTrack(track);
    // Set Queue
    await Application.audioManager.setQueue(queue, cursor);
    await Application.audioManager.play();
  }

  static AlbumViewModel fromStore(Store<AppState> store) {
    AlbumState state = store.state.albumState;
    String currentSongContextId =
        store.state.playerState.currentSong?.contextId;

    Map<int, List<AlbumViewModelTrack>> discs = null;

    if (state.album?.tracks != null) {
      Map<int, List<VocaDBSongInAlbum>> songsByDisc =
          groupBy<VocaDBSongInAlbum, int>(
              state.album.tracks, (VocaDBSongInAlbum song) => song.discNumber);

      mapSongToViewModel(VocaDBSongInAlbum song) {
        bool active = currentSongContextId != null &&
            _generateContextId(song.song?.id, state.album?.id) ==
                currentSongContextId;

        return AlbumViewModelTrack.fromVocaDBSongInAlbum(
          song,
          active: active,
        );
      }

      discs =
          mapMap<int, List<VocaDBSongInAlbum>, int, List<AlbumViewModelTrack>>(
        songsByDisc,
        key: (k, v) => k,
        value: (k, v) => v.map(mapSongToViewModel).toList(),
      );
    }

    return AlbumViewModel(
      albumId: state.album?.id,
      loading: state.loading,
      title: state.album?.name,
      albumImageUrl: state.album?.mainPicture?.urlThumb,
      artistsString: state.album?.artistString,
      discs: discs,
      errorState: state.errorState,
    );
  }
}
