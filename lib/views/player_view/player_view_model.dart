import 'package:redux/redux.dart';
import 'package:vocaloid_player/redux/app_state.dart';
import 'package:vocaloid_player/redux/states/player_state.dart';

class PlayerViewModel {
  PlayerState playerState;

  PlayerViewModel({
    this.playerState,
  });

  static PlayerViewModel fromStore(Store<AppState> store) {
    return PlayerViewModel(playerState: store.state.player);
  }
}
