import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';

class ConnectivityBar extends StatefulWidget {
  @override
  _ConnectivityBarState createState() => _ConnectivityBarState();
}

class _ConnectivityBarState extends State<ConnectivityBar> {
  StreamSubscription _connectivitySubscription;
  ConnectivityResult connectivityResult;

  @override
  void initState() {
    super.initState();
    Connectivity connectivity = Connectivity();
    // Check connectivity now
    connectivity
        .checkConnectivity()
        .then((result) => setState(() => connectivityResult = result));
    // Listen to connectivity changes
    _connectivitySubscription = connectivity.onConnectivityChanged
        .listen((result) => setState(() => connectivityResult = result));
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double expandedHeight = 22;
    return AnimatedContainer(
      curve: Curves.easeInOut,
      duration: Duration(milliseconds: 250),
      height: this.connectivityResult == ConnectivityResult.none
          ? expandedHeight
          : 0,
      color: Colors.black,
      child: ClipRect(
        child: OverflowBox(
          maxHeight: expandedHeight,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 20),
              child: Text(
                'No internet connection available',
                style: Theme.of(context)
                    .textTheme
                    .caption
                    .copyWith(color: Colors.white),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
