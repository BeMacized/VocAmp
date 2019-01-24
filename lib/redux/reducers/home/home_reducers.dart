import 'package:redux/redux.dart';
import 'package:vocaloid_player/redux/states/home_state.dart';
import 'package:vocaloid_player/redux/actions/home_actions.dart';
import 'package:vocaloid_player/redux/reducers/home/home_highlighted_songs_reducers.dart';
import 'package:vocaloid_player/redux/reducers/home/home_top_albums_reducers.dart';

Reducer<HomeState> homeStateReducer = (HomeState state, dynamic action) {
  return HomeState(
    tab: setHomeTabReducer(state.tab, action),
    topAlbums: homeTopAlbumsStateReducer(state.topAlbums, action),
    highlightedSongs:
        homeHighlightedSongsStateReducer(state.highlightedSongs, action),
  );
};

int setHomeTabReducer(int state, dynamic action) {
  return action is SetHomeTabAction ? action.index : state;
}
