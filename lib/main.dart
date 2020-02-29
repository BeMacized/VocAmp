import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:voc_amp/providers/audio-player.provider.dart';
import 'package:voc_amp/views/play/play-view.provider.dart';
import 'package:voc_amp/views/tracklist/track-list-view.provider.dart';
import 'package:voc_amp/providers/track-list.provider.dart';
import 'package:voc_amp/repositories/track-list.repository.dart';
import 'package:voc_amp/repositories/vocadb-songs-api.repository.dart';
import 'package:voc_amp/theme.dart';
import 'package:voc_amp/views/main/main.view.dart';
import 'package:voc_amp/views/play/play.view.dart';

import 'globals.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
  runApp(VocAmp());
}

class VocAmp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  _VocAmpState createState() => _VocAmpState();
}

class _VocAmpState extends State<VocAmp> with WidgetsBindingObserver {
  VocaDBSongsApiRepository _vocaDBSongsApiRepository;
  TrackListRepository _trackListRepository;

  @override
  initState() {
    super.initState();
    // Add app state observer
    WidgetsBinding.instance.addObserver(this);
    // Setup repositories
    _setupRepositories();
    // Connect to the audio service
    connectAudioService();
  }

  _setupRepositories() {
    _vocaDBSongsApiRepository = VocaDBSongsApiRepository();
    _trackListRepository = TrackListRepository(_vocaDBSongsApiRepository);
  }

  @override
  void dispose() {
    // Disconnect from the audio service
    disconnectAudioService();
    // Remove app state observer
    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

  void connectAudioService() async {
    await AudioService.connect();
  }

  void disconnectAudioService() {
    AudioService.disconnect();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        connectAudioService();
        break;
      case AppLifecycleState.paused:
        disconnectAudioService();
        break;
      default:
        break;
    }
  }

  Route<dynamic> onGenerateRoute(RouteSettings settings) {
    WidgetBuilder builder;
    bool fullscreenDialog = false;
    switch (settings.name) {
      case '/':
      case '/main':
        builder = (BuildContext _) => MainView();
        break;
      case '/play':
        builder = (BuildContext _) => PlayView();
        fullscreenDialog = true;
        break;
      default:
        throw Exception('Invalid route: ${settings.name}');
    }
    return MaterialPageRoute(
      builder: builder,
      settings: settings,
      fullscreenDialog: fullscreenDialog,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      child: MaterialApp(
        title: 'vocAmp',
        theme: getAppTheme(context),
        navigatorKey: Application.navigatorKey,
        debugShowCheckedModeBanner: false,
        onGenerateRoute: onGenerateRoute,
      ),
      providers: [
        Provider<TrackListProvider>(
          create: (_) => TrackListProvider(_trackListRepository),
        ),
        Provider<AudioPlayerProvider>(
          create: (_) => AudioPlayerProvider(),
          dispose: (_, provider) => provider.dispose(),
        ),
        ChangeNotifierProxyProvider<AudioPlayerProvider, TrackListViewProvider>(
          create: (_) => null,
          update: (_, audioPlayerProvider, __) =>
              TrackListViewProvider(audioPlayerProvider),
        ),
        ChangeNotifierProxyProvider<AudioPlayerProvider, PlayViewProvider>(
          create: (_) => null,
          update: (_, audioPlayerProvider, __) =>
              PlayViewProvider(audioPlayerProvider),
        ),
      ],
    );
  }
}
