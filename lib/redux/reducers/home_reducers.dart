import 'package:redux/redux.dart';
import 'package:vocaloid_player/redux/states/home_state.dart';
import 'package:vocaloid_player/redux/actions/home_actions.dart';

Reducer<HomeState> homeStateReducer = combineReducers<HomeState>([
  TypedReducer<HomeState, SetHomeTabAction>(setHomeTabReducer),
]);

HomeState setHomeTabReducer(HomeState state, SetHomeTabAction action) {
  return state.copyWith(tab: action.index);
}
