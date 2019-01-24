import 'package:meta/meta.dart';
import 'package:vocaloid_player/model/status_data.dart';
import 'package:vocaloid_player/model/vocadb/vocadb_song.dart';

class HomeHighlightedSongsState {
  bool loading;
  List<VocaDBSong> songs;
  StatusData error;

  HomeHighlightedSongsState({
    @required this.loading,
    @required this.songs,
    this.error,
  });

  HomeHighlightedSongsState copyWith({
    bool loading,
    List<VocaDBSong> songs,
    StatusData error,
  }) {
    return HomeHighlightedSongsState(
      loading: loading ?? this.loading,
      songs: songs ?? this.songs,
      error: error ?? this.error,
    );
  }

  HomeHighlightedSongsState copyWithoutError() {
    return HomeHighlightedSongsState(
      loading: loading,
      songs: songs,
    );
  }

  factory HomeHighlightedSongsState.initial() => HomeHighlightedSongsState(
        loading: false,
        songs: [],
      );
}
