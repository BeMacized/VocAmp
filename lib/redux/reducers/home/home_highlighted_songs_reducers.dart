import 'package:redux/redux.dart';
import 'package:vocaloid_player/redux/actions/home_actions.dart';
import 'package:vocaloid_player/redux/states/home_highlighted_songs_state.dart';

Reducer<HomeHighlightedSongsState> homeHighlightedSongsStateReducer =
    combineReducers<HomeHighlightedSongsState>([
  TypedReducer<HomeHighlightedSongsState, LoadingHomeHighlightedSongsAction>(
      loadingHomeHighlightedSongsReducer),
  TypedReducer<HomeHighlightedSongsState, LoadedHomeHighlightedSongsAction>(
      loadedHomeHighlightedSongsReducer),
  TypedReducer<HomeHighlightedSongsState,
          ErrorLoadingHomeHighlightedSongsAction>(
      errorLoadingHomeHighlightedSongsReducer),
]);

HomeHighlightedSongsState loadingHomeHighlightedSongsReducer(
    HomeHighlightedSongsState state, LoadingHomeHighlightedSongsAction action) {
  return state.copyWithoutError().copyWith(loading: true, songs: []);
}

HomeHighlightedSongsState loadedHomeHighlightedSongsReducer(
    HomeHighlightedSongsState state, LoadedHomeHighlightedSongsAction action) {
  return state.copyWithoutError().copyWith(loading: false, songs: action.songs);
}

HomeHighlightedSongsState errorLoadingHomeHighlightedSongsReducer(
    HomeHighlightedSongsState state,
    ErrorLoadingHomeHighlightedSongsAction action) {
  return state.copyWith(loading: false, error: action.statusData);
}
