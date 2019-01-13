import 'package:meta/meta.dart';
import 'package:redux/redux.dart';
import 'package:vocaloid_player/redux/app_state.dart';
import 'package:vocaloid_player/redux/states/search_state.dart';

class HomeTabModel {
  SearchState searchState;

  HomeTabModel({
    @required this.searchState,
  });

  static HomeTabModel fromStore(Store<AppState> store) {
    return HomeTabModel(searchState: store.state.searchState);
  }
}
