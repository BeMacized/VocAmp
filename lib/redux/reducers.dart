import 'package:vocaloid_player/redux/app_state.dart';
import 'package:vocaloid_player/redux/reducers/album_reducers.dart';
import 'package:vocaloid_player/redux/reducers/player_reducers.dart';
import 'package:vocaloid_player/redux/reducers/home/home_reducers.dart';
import 'package:vocaloid_player/redux/reducers/search_reducers.dart';

AppState appReducer(AppState state, action) => AppState(
      album: albumStateReducer(state.album, action),
      player: playerStateReducer(state.player, action),
      home: homeStateReducer(state.home, action),
      search: searchStateReducer(state.search, action),
    );
