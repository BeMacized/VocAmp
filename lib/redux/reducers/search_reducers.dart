import 'package:redux/redux.dart';
import 'package:vocaloid_player/redux/states/search_state.dart';
import 'package:vocaloid_player/redux/actions/search_actions.dart';

Reducer<SearchState> searchStateReducer = combineReducers<SearchState>([
  TypedReducer<SearchState, QueryingSearchAction>(queryingSearchReducer),
  TypedReducer<SearchState, ErrorQueryingSearchAction>(
      errorQueryingSearchReducer),
  TypedReducer<SearchState, ReceivedSearchQueryResultsAction>(
      receivedSearchQueryResultsReducer),
]);

SearchState queryingSearchReducer(
    SearchState state, QueryingSearchAction action) {
  return state.copyWithoutError().copyWith(loading: true, query: action.query);
}

SearchState errorQueryingSearchReducer(
    SearchState state, ErrorQueryingSearchAction action) {
  return state.copyWith(loading: false, errorState: action.errorState);
}

SearchState receivedSearchQueryResultsReducer(
    SearchState state, ReceivedSearchQueryResultsAction action) {
  return state.copyWithoutError().copyWith(
        loading: false,
        albumResults: action.albumResults,
        songResults: action.songResults,
      );
}
