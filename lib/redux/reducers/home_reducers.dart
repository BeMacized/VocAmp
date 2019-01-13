import 'package:redux/redux.dart';
import 'package:vocaloid_player/redux/states/home_state.dart';
import 'package:vocaloid_player/redux/actions/home_actions.dart';

Reducer<HomeState> homeStateReducer = combineReducers<HomeState>([
  TypedReducer<HomeState, SetHomeTabAction>(setHomeTabReducer),
  TypedReducer<HomeState, LoadingHomeTopAlbumsAction>(loadingHomeTopAlbumsReducer),
  TypedReducer<HomeState, LoadedHomeTopAlbumsAction>(loadedHomeTopAlbumsReducer),
  TypedReducer<HomeState, ErrorLoadingHomeTopAlbumsAction>(errorLoadingHomeTopAlbumsReducer),
]);

HomeState setHomeTabReducer(HomeState state, SetHomeTabAction action) {
  return state.copyWith(tab: action.index);
}

HomeState loadingHomeTopAlbumsReducer(HomeState state, LoadingHomeTopAlbumsAction action) {
  return state.copyWithoutError().copyWith(loadingTopAlbums: true, topAlbums: []);
}
HomeState loadedHomeTopAlbumsReducer(HomeState state, LoadedHomeTopAlbumsAction action) {
  return state.copyWithoutError().copyWith(loadingTopAlbums: false, topAlbums: action.albums);
}
HomeState errorLoadingHomeTopAlbumsReducer(HomeState state, ErrorLoadingHomeTopAlbumsAction action) {
  return state.copyWith(loadingTopAlbums: false, errorState: action.statusData);
}
