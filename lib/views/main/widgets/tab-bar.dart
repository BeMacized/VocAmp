import 'package:flutter/material.dart';
import 'package:voc_amp/theme.dart';

class MainTabBar extends StatefulWidget {
  @override
  _MainTabBarState createState() => _MainTabBarState();
}

class _MainTabBarState extends State<MainTabBar> {
  @override
  Widget build(BuildContext context) {
    double expandedHeight = 56;
    return AnimatedContainer(
      curve: Curves.easeInOut,
      duration: Duration(milliseconds: 250),
      height: expandedHeight,
      decoration: BoxDecoration(
        color: paneBackgroundColor,

      ),
      child: ClipRect(
        child: OverflowBox(
          alignment: Alignment.center,
          maxHeight: expandedHeight,
          child: Center(child: Text('TAB BAR')),
        ),
      ),
    );
  }
}
