import 'package:redux/redux.dart';
import 'package:vocaloid_player/redux/actions.dart';
import 'package:vocaloid_player/redux/app_state.dart';

Reducer<AlbumState> albumStateReducer = combineReducers<AlbumState>([
  TypedReducer<AlbumState, LoadingAlbumAction>(loadingAlbumReducer),
  TypedReducer<AlbumState, LoadedAlbumAction>(loadedAlbumReducer),
  TypedReducer<AlbumState, ErrorLoadingAlbumAction>(errorLoadingAlbumReducer),
]);

AlbumState loadingAlbumReducer(AlbumState state, LoadingAlbumAction action) {
  return AlbumState(loading: true);
}

AlbumState loadedAlbumReducer(AlbumState state, LoadedAlbumAction action) {
  return AlbumState(loading: false, album: action.album);
}

AlbumState errorLoadingAlbumReducer(
    AlbumState state, ErrorLoadingAlbumAction action) {
  return AlbumState(loading: false, errorState: action.errorState);
}
