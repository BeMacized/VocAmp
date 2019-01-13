import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:vocaloid_player/views/home_view/home_view_tab_controller.dart';
import 'package:vocaloid_player/views/home_view/tabs/home_tab/home_tab.dart';
import 'package:vocaloid_player/views/home_view/tabs/library_tab/library_tab.dart';
import 'package:vocaloid_player/widgets/main_nav_bar.dart';
import 'package:vocaloid_player/widgets/now_playing_bar.dart';

class HomeView extends StatefulWidget {
  @override
  HomeViewState createState() {
    return HomeViewState();
  }
}

class HomeViewState extends State<HomeView>
    with SingleTickerProviderStateMixin {
  HomeViewTabController _tabController;
  List<Widget> _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = [
      HomeTab(),
      LibraryTab(),
    ];
    _tabController = HomeViewTabController(vsync: this, length: _tabs.length);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      bottomNavigationBar: MainNavBar(),
      body: Column(
        children: <Widget>[
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: _tabs,
            ),
          ),
          NowPlayingBar()
        ],
      ),
    );
  }
}
