
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:vocaloid_player/views/home_view/home_view_tab_controller.dart';
import 'package:vocaloid_player/views/home_view/tabs/home_tab.dart';
import 'package:vocaloid_player/views/home_view/tabs/library_tab.dart';
import 'package:vocaloid_player/views/home_view/tabs/search_tab.dart';
import 'package:vocaloid_player/widgets/main_nav_bar.dart';

class HomeView extends StatefulWidget {
  @override
  HomeViewState createState() {
    return new HomeViewState();
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
      new HomeTab(),
      new SearchTab(),
      new LibraryTab(),
    ];
    _tabController = HomeViewTabController(
        vsync: this, length: _tabs.length, initialIndex: 0);
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
      body: TabBarView(
        controller: _tabController,
        children: _tabs,
      ),
    );
  }
}
