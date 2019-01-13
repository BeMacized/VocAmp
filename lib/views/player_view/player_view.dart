import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:vocaloid_player/globals.dart';
import 'package:vocaloid_player/redux/app_state.dart';
import 'package:vocaloid_player/utils/string_utils.dart';
import 'package:vocaloid_player/views/player_view/player_view_model.dart';
import 'package:vocaloid_player/views/player_view/seek_bar.dart';
import 'package:vocaloid_player/widgets/album_art.dart';
import 'package:vocaloid_player/widgets/player_controls.dart';
import 'package:vocaloid_player/widgets/scrolling_text.dart';

class PlayerView extends StatelessWidget {
  const PlayerView({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, PlayerViewModel>(
      converter: PlayerViewModel.fromStore,
      builder: (BuildContext context, PlayerViewModel vm) {
        return Stack(
          children: <Widget>[
            PlayerBackground(vm),
            Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                brightness: Brightness.dark,
                leading: Application.navigator.canPop()
                    ? IconButton(
                        icon: Icon(Icons.keyboard_arrow_down,
                            color: Colors.white),
                        onPressed: Application.navigator.pop,
                      )
                    : null,
                actions: <Widget>[
                  IconButton(
                    icon: Icon(Icons.queue_music),
                    color: Colors.white,
                    onPressed: () => Application.navigator.pushNamed('/queue'),
                  )
                ],
              ),
              body: vm.playerState.currentSong == null
                  ? null
                  : PlayerBody(vm: vm),
            ),
          ],
        );
      },
    );
  }
}

class PlayerBody extends StatelessWidget {
  final PlayerViewModel vm;

  PlayerBody({
    Key key,
    this.vm,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String thumbUrl = vm.playerState.currentSong?.mediaItem?.artUri;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
              child: Container(
                decoration: BoxDecoration(boxShadow: [
                  BoxShadow(
                      color: Colors.black,
                      blurRadius: 20,
                      spreadRadius: 5,
                      offset: Offset(0, 10))
                ]),
                child: AlbumArt(
                  albumImageUrl: thumbUrl,
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 24.0),
          child: Container(
            height: 48,
            child: ScrollingText(
              TextSpan(
                text: vm.playerState.currentSong.song.name,
                style: TextStyle(color: Colors.white, fontSize: 32),
              ),
              alignment: Alignment.center,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 24.0),
          child: Container(
            height: 20,
            child: ScrollingText(
              TextSpan(
                text: vm.playerState.currentSong.song.artistString,
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
              alignment: Alignment.center,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 24, right: 24, top: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(getDurationString(vm.playerState.position),
                  style: TextStyle(color: Colors.white)),
              Text(getDurationString(vm.playerState.duration),
                  style: TextStyle(color: Colors.white))
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: SeekBar(vm: vm),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 24, bottom: 96),
          child: PlayerControls(vm.playerState),
        ),
      ],
    );
  }
}

class PlayerBackground extends StatelessWidget {
  final PlayerViewModel vm;

  const PlayerBackground(
    this.vm, {
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          color: Colors.black,
        ),
        Container(
          width: double.infinity,
          height: double.infinity,
          child: CachedNetworkImage(
            imageUrl: vm.playerState.currentSong?.mediaItem?.artUri ?? '',
//            placeholder: new AlbumPlaceholder(),
//            errorWidget: new AlbumPlaceholder(),
            fadeInCurve: Curves.ease,
            fadeOutCurve: Curves.ease,
            fit: BoxFit.cover,
          ),
        ),
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(color: Colors.transparent),
          ),
        ),
        Container(
          width: double.infinity,
          height: double.infinity,
          child: DecoratedBox(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [Color(0xFF000000), Color(0x99000000)],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter)),
          ),
        ),
      ],
    );
  }
}
