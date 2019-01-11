import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vocaloid_player/globals.dart';
import 'package:vocaloid_player/redux/actions/home_actions.dart';

class HomeViewTabController extends TabController {
  StreamSubscription<int> _tabSubscription;

  HomeViewTabController(
      {int initialIndex = 0,
      @required int length,
      @required TickerProvider vsync})
      : super(initialIndex: initialIndex, length: length, vsync: vsync) {
    _tabSubscription = Application.store.onChange
        .map<int>((state) => state.homeState.tab)
        .distinct()
        .listen((tab) => super.index = tab);
  }

  // Instead of having this set the index, we send out an action.
  // This will eventually set the actual index via the store subscription.
  @override
  set index(int value) {
    Application.store.dispatch(SetHomeTabAction(value));
  }

  @override
  void dispose() {
    _tabSubscription.cancel();
    super.dispose();
  }
}