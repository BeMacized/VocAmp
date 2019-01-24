import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:vocaloid_player/redux/states/album_state.dart';
import 'package:vocaloid_player/redux/states/home_state.dart';
import 'package:vocaloid_player/redux/states/player_state.dart';
import 'package:vocaloid_player/redux/states/search_state.dart';

class AppState {
  final AlbumState album;
  final PlayerState player;
  final HomeState home;
  final SearchState search;

  AppState({
    @required this.album,
    @required this.player,
    @required this.home,
    @required this.search,
  });

  factory AppState.initial() => AppState(
        album: AlbumState.initial(),
        player: PlayerState.initial(),
        home: HomeState.initial(),
        search: SearchState.initial(),
      );
}
