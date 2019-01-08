import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:vocaloid_player/globals.dart';
import 'package:vocaloid_player/redux/app_state.dart';
import 'package:vocaloid_player/routes.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  MyAppState createState() {
    return new MyAppState();
  }
}

class MyAppState extends State<MyApp> with WidgetsBindingObserver {
  MyAppState() {
    Routes.configureRoutes(Application.router);
  }

  @override
  initState() {
    super.initState();
    // Add widget observer for lifecycle changes
    WidgetsBinding.instance.addObserver(this);
    Application.audioManager.connect();
  }

  @override
  Widget build(BuildContext context) {
    return StoreProvider<AppState>(
      store: Application.store,
      child: MaterialApp(
        title: 'Flutter Demo',
        navigatorKey: Application.navigatorKey,
        debugShowCheckedModeBanner: false,
        onGenerateRoute: Application.router.generator,
        theme: ThemeData(
            brightness: Brightness.dark,
            primaryColor: Colors.pink,
            accentColor: Colors.pinkAccent,
            buttonColor: Colors.pink,
            splashColor: Colors.pink,
            fontFamily: 'Raleway'),
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        Application.audioManager.connect();
        break;
      case AppLifecycleState.paused:
        Application.audioManager.disconnect();
        break;
      default:
        break;
    }
  }

}
