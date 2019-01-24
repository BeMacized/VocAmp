import 'package:redux/redux.dart';
import 'package:vocaloid_player/redux/actions/home_actions.dart';
import 'package:vocaloid_player/redux/states/home_top_albums_state.dart';

Reducer<HomeTopAlbumsState> homeTopAlbumsStateReducer =
    combineReducers<HomeTopAlbumsState>([
  TypedReducer<HomeTopAlbumsState, LoadingHomeTopAlbumsAction>(
      loadingHomeTopAlbumsReducer),
  TypedReducer<HomeTopAlbumsState, LoadedHomeTopAlbumsAction>(
      loadedHomeTopAlbumsReducer),
  TypedReducer<HomeTopAlbumsState, ErrorLoadingHomeTopAlbumsAction>(
      errorLoadingHomeTopAlbumsReducer),
]);

HomeTopAlbumsState loadingHomeTopAlbumsReducer(
    HomeTopAlbumsState state, LoadingHomeTopAlbumsAction action) {
  return state.copyWithoutError().copyWith(loading: true, albums: []);
}

HomeTopAlbumsState loadedHomeTopAlbumsReducer(
    HomeTopAlbumsState state, LoadedHomeTopAlbumsAction action) {
  return state
      .copyWithoutError()
      .copyWith(loading: false, albums: action.albums);
}

HomeTopAlbumsState errorLoadingHomeTopAlbumsReducer(
    HomeTopAlbumsState state, ErrorLoadingHomeTopAlbumsAction action) {
  return state.copyWith(loading: false, error: action.statusData);
}
