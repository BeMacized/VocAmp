import 'package:meta/meta.dart';
import 'package:vocaloid_player/model/vocadb/vocadb_album.dart';
import 'package:vocaloid_player/model/vocadb/vocadb_song.dart';
import 'package:vocaloid_player/model/status_data.dart';

class SearchState {
  StatusData error;
  final bool loading;
  String query;
  List<VocaDBAlbum> albumResults;
  List<VocaDBSong> songResults;

  //List<VocaDBArtist> artistResults;

  bool get hasResults =>
      (albumResults?.length ?? 0) > 0 || (songResults?.length ?? 0) > 0;

  SearchState({
    @required this.loading,
    @required this.albumResults,
    @required this.songResults,
    @required this.query,
    this.error,
  });

  SearchState copyWith({
    String query,
    bool loading,
    List<VocaDBAlbum> albumResults,
    List<VocaDBSong> songResults,
    StatusData errorState,
  }) {
    return SearchState(
      loading: loading ?? this.loading,
      albumResults: albumResults ?? this.albumResults,
      songResults: songResults ?? this.songResults,
      error: errorState ?? this.error,
      query: query ?? this.query,
    );
  }

  SearchState copyWithoutError() {
    return SearchState(
      loading: loading,
      query: query,
      albumResults: albumResults,
      songResults: songResults,
    );
  }

  factory SearchState.initial() => SearchState(
        loading: false,
        query: '',
        albumResults: [],
        songResults: [],
      );
}
