
import 'package:redux/redux.dart';
import 'package:vocaloid_player/redux/actions.dart';
import 'package:vocaloid_player/redux/app_state.dart';

Reducer<AlbumState> albumStateReducer = combineReducers<AlbumState>([
  TypedReducer<AlbumState, LoadingAlbumAction>(loadingAlbumReducer),
  TypedReducer<AlbumState, LoadedAlbumAction>(loadedAlbumReducer),
]);

AlbumState loadingAlbumReducer(AlbumState state, LoadingAlbumAction action) {
  return AlbumState(loading: true, album: null);
}

AlbumState loadedAlbumReducer(AlbumState state, LoadedAlbumAction action) {
  return AlbumState(loading: false, album: action.album);
}