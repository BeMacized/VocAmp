import 'package:vocaloid_player/redux/app_state.dart';
import 'package:vocaloid_player/redux/reducers/album_reducers.dart';
import 'package:vocaloid_player/redux/reducers/player_reducers.dart';
import 'package:vocaloid_player/redux/reducers/home_reducers.dart';
import 'package:vocaloid_player/redux/reducers/search_reducers.dart';

AppState appReducer(AppState state, action) => AppState(
      albumState: albumStateReducer(state.albumState, action),
      playerState: playerStateReducer(state.playerState, action),
      homeState: homeStateReducer(state.homeState, action),
      searchState: searchStateReducer(state.searchState, action),
    );
