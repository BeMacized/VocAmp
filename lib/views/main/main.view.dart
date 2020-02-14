import 'package:flutter/material.dart';
import 'package:voc_amp/views/home/home.view.dart';
import 'package:voc_amp/views/main/widgets/tab-bar.dart';
import 'package:voc_amp/views/tracklist/track-list.view.dart';
import 'package:voc_amp/views/main/widgets/connectivity-bar.dart';
import 'package:voc_amp/views/main/widgets/play-bar.dart';

class MainView extends StatefulWidget {
  @override
  _MainViewState createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  Route<dynamic> onGenerateRoute(RouteSettings settings) {
    WidgetBuilder builder;
    switch (settings.name) {
      case 'main/home':
        builder = (BuildContext _) => HomeView();
        break;
      case 'main/tracklist':
        builder = (BuildContext _) => TrackListView(
              trackList: settings.arguments,
            );
        break;
      default:
        throw Exception('Invalid route: ${settings.name}');
    }
    return MaterialPageRoute(
      builder: builder,
      settings: settings,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.black,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
              child: WillPopScope(
                onWillPop: () async {
                  if (_navigatorKey.currentState.canPop()) {
                    _navigatorKey.currentState.pop();
                    return false;
                  }
                  return true;
                },
                child: Navigator(
                  key: _navigatorKey,
                  initialRoute: 'main/home',
                  onGenerateRoute: onGenerateRoute,
                ),
              ),
            ),
            ConnectivityBar(),
            PlayBar(),
            MainTabBar(),
          ],
        ),
      ),
    );
  }
}
