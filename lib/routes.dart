import 'package:fluro/fluro.dart';
import 'package:flutter/widgets.dart';
import 'package:vocaloid_player/globals.dart';
import 'package:vocaloid_player/redux/actions/album_actions.dart';
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
    router.notFoundHandler = new Handler(
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

final Handler rootHandler = new Handler(
  handlerFunc: (BuildContext context, Map<String, List<String>> params) {
    return new HomeView();
  },
);

final Handler albumHandler = new Handler(
  handlerFunc: (BuildContext context, Map<String, dynamic> params) {
    Application.store
        .dispatch(loadAlbumAction(int.parse(params['id'][0] as String)));
    return new AlbumView();
  },
);

final Handler nowPlayingHandler = new Handler(
  handlerFunc: (BuildContext context, Map<String, dynamic> params) {
    return new PlayerView();
  },
);

final Handler queueHandler = new Handler(
  handlerFunc: (BuildContext context, Map<String, dynamic> params) {
    return new QueueView();
  },
);
