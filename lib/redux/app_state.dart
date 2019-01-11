import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:vocaloid_player/redux/states/album_state.dart';
import 'package:vocaloid_player/redux/states/home_state.dart';
import 'package:vocaloid_player/redux/states/player_state.dart';

class AppState {
  final AlbumState albumState;
  final PlayerState playerState;
  final HomeState homeState;

  AppState(
      {@required this.albumState,
      @required this.playerState,
      @required this.homeState});

  factory AppState.initial() => AppState(
        albumState: AlbumState.initial(),
        playerState: PlayerState.initial(),
        homeState: HomeState.initial(),
      );
}
