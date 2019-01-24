import 'package:meta/meta.dart';
import 'package:vocaloid_player/model/status_data.dart';
import 'package:vocaloid_player/model/vocadb/vocadb_album.dart';
import 'package:vocaloid_player/model/vocadb/vocadb_song.dart';
import 'package:vocaloid_player/redux/states/home_highlighted_songs_state.dart';
import 'package:vocaloid_player/redux/states/home_top_albums_state.dart';

class HomeState {
  final int tab;

  final HomeTopAlbumsState topAlbums;
  final HomeHighlightedSongsState highlightedSongs;

  HomeState({
    @required this.tab,
    @required this.topAlbums,
    @required this.highlightedSongs,
  });

  HomeState copyWith({
    int tab,
    HomeTopAlbumsState topAlbums,
    HomeHighlightedSongsState highlightedSongs,
  }) {
    return HomeState(
      tab: tab ?? this.tab,
      highlightedSongs: highlightedSongs ?? this.highlightedSongs,
      topAlbums: topAlbums ?? this.topAlbums,
    );
  }

  factory HomeState.initial() => HomeState(
        tab: 0,
        topAlbums: HomeTopAlbumsState.initial(),
        highlightedSongs: HomeHighlightedSongsState.initial(),
      );
}
