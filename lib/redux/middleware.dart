import 'package:redux/redux.dart';
import 'package:vocaloid_player/redux/app_state.dart';
import 'package:redux_thunk/redux_thunk.dart';

List<Middleware<AppState>> createStoreMiddleware() {
  return [thunkMiddleware];
}
