import 'package:meta/meta.dart';
import 'package:vocaloid_player/model/vocadb/vocadb_album.dart';
import 'package:vocaloid_player/model/status_data.dart';

class AlbumState {
  final bool loading;
  final StatusData errorState;
  final VocaDBAlbum album;

  AlbumState({
    @required this.loading,
    this.album,
    this.errorState,
  });

  factory AlbumState.initial() => AlbumState(
        loading: false,
        album: null,
        errorState: null,
      );
}
