import 'package:flutter/widgets.dart';
import 'package:fluro/fluro.dart';
import 'package:redux/redux.dart';
import 'package:vocaloid_player/audio/AudioManager.dart';
import 'package:vocaloid_player/redux/app_state.dart';
import 'package:vocaloid_player/redux/reducers.dart';
import 'package:vocaloid_player/redux/middleware.dart';

class Application {
  static final GlobalKey<NavigatorState> navigatorKey =
      new GlobalKey<NavigatorState>();

  static NavigatorState get navigator => navigatorKey.currentState;

  static final router = Router();

  static final Store<AppState> store = Store<AppState>(
    appReducer,
    initialState: AppState.initial(),
    middleware: createStoreMiddleware(),
  );

  static final AudioManager audioManager = new AudioManager();
}
