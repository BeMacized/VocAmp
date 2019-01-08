import 'package:redux/redux.dart';
import 'package:vocaloid_player/redux/app_state.dart';
import 'package:vocaloid_player/redux/reducers/album_state.dart';
import 'package:vocaloid_player/redux/reducers/player_state.dart';

AppState appReducer(AppState state, action) => AppState(
  albumState: albumStateReducer(state.albumState, action),
  playerState: playerStateReducer(state.playerState, action),
);
