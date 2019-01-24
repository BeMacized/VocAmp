import 'package:meta/meta.dart';
import 'package:vocaloid_player/model/status_data.dart';
import 'package:vocaloid_player/model/vocadb/vocadb_album.dart';

class HomeTopAlbumsState {
  bool loading;
  List<VocaDBAlbum> albums;
  StatusData error;

  HomeTopAlbumsState({
    @required this.loading,
    @required this.albums,
    this.error,
  });

  HomeTopAlbumsState copyWith({
    bool loading,
    List<VocaDBAlbum> albums,
    StatusData error,
  }) {
    return HomeTopAlbumsState(
      loading: loading ?? this.loading,
      albums: albums ?? this.albums,
      error: error ?? this.error,
    );
  }

  HomeTopAlbumsState copyWithoutError() {
    return HomeTopAlbumsState(
      loading: loading,
      albums: albums,
    );
  }

  factory HomeTopAlbumsState.initial() => HomeTopAlbumsState(
        loading: false,
        albums: [],
      );
}
