import 'package:meta/meta.dart';
import 'package:vocaloid_player/model/status_data.dart';
import 'package:vocaloid_player/model/vocadb/vocadb_album.dart';

class HomeState {
  int tab;
  bool loadingTopAlbums;
  List<VocaDBAlbum> topAlbums;
  StatusData errorState;

  HomeState(
      {@required this.tab,
      @required this.loadingTopAlbums,
      @required this.topAlbums,
      this.errorState});

  HomeState copyWith({
    int tab,
    bool loadingTopAlbums,
    List<VocaDBAlbum> topAlbums,
    StatusData errorState,
  }) {
    return HomeState(
      tab: tab ?? this.tab,
      loadingTopAlbums: loadingTopAlbums ?? this.loadingTopAlbums,
      topAlbums: topAlbums ?? this.topAlbums,
      errorState: errorState ?? this.errorState,
    );
  }

  HomeState copyWithoutError() {
    return HomeState(
      tab: tab,
      loadingTopAlbums: loadingTopAlbums,
      topAlbums: topAlbums,
    );
  }

  factory HomeState.initial() => HomeState(
        tab: 0,
        loadingTopAlbums: false,
        topAlbums: [],
      );
}
