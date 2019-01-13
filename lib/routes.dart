import 'package:fluro/fluro.dart';
import 'package:flutter/widgets.dart';
import 'package:vocaloid_player/globals.dart';
import 'package:vocaloid_player/redux/actions/album_actions.dart';
import 'package:vocaloid_player/redux/actions/home_actions.dart';
import 'package:vocaloid_player/views/album_view/album_view.dart';
import 'package:vocaloid_player/views/home_view/home_view.dart';
import 'package:vocaloid_player/views/player_view/player_view.dart';
import 'package:vocaloid_player/views/queue_view/queue_view.dart';

class Routes {
  static final String root = '/';
  static final String album = '/album/:id';
  static final String nowPlaying = '/nowplaying';
  static final String queue = '/queue';

  static void configureRoutes(Router router) {
    router.notFoundHandler = Handler(
        handlerFunc: (BuildContext context, Map<String, List<String>> params) {
      print("ROUTE WAS NOT FOUND !!!");
    });
    router.define(root,
        handler: rootHandler, transitionType: TransitionType.native);
    router.define(album,
        handler: albumHandler, transitionType: TransitionType.native);
    router.define(
      nowPlaying,
      handler: nowPlayingHandler,
      transitionType: TransitionType.inFromBottom,
    );
    router.define(
      queue,
      handler: queueHandler,
      transitionType: TransitionType.inFromRight,
    );
  }
}

final Handler rootHandler = Handler(
  handlerFunc: (BuildContext context, Map<String, List<String>> params) {
    Application.store.dispatch(loadHomeTopAlbumsAction());
    return HomeView();
  },
);

final Handler albumHandler = Handler(
  handlerFunc: (BuildContext context, Map<String, dynamic> params) {
    Application.store
        .dispatch(loadAlbumAction(int.parse(params['id'][0] as String)));
    return AlbumView();
  },
);

final Handler nowPlayingHandler = Handler(
  handlerFunc: (BuildContext context, Map<String, dynamic> params) {
    return PlayerView();
  },
);

final Handler queueHandler = Handler(
  handlerFunc: (BuildContext context, Map<String, dynamic> params) {
    return QueueView();
  },
);
