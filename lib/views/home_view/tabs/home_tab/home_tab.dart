import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:vocaloid_player/redux/app_state.dart';
import 'package:vocaloid_player/views/home_view/tabs/home_tab/home_body.dart';
import 'package:vocaloid_player/views/home_view/tabs/home_tab/home_tab_model.dart';
import 'package:vocaloid_player/views/home_view/tabs/home_tab/search_bar.dart';
import 'package:vocaloid_player/views/home_view/tabs/home_tab/search_body.dart';

class HomeTab extends StatefulWidget {
  @override
  HomeTabState createState() {
    return HomeTabState();
  }
}

class HomeTabState extends State<HomeTab> {
  FocusNode _searchFocusNode;

  @override
  initState() {
    super.initState();
    // Search
    _searchFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _searchFocusNode?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, HomeTabModel>(
      converter: (Store<AppState> store) => HomeTabModel.fromStore(store),
      builder: (BuildContext context, HomeTabModel vm) {
        return Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.black,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => _searchFocusNode.unfocus(),
            child: Stack(
              children: <Widget>[
                HomeBody(),
                IgnorePointer(
                  ignoring: vm.searchState.query.length == 0 &&
                      !vm.searchState.loading,
                  child: AnimatedOpacity(
                    opacity: vm.searchState.query.length > 0 ||
                            vm.searchState.loading
                        ? 1.0
                        : 0.0,
                    child: SearchBody(vm),
                    duration: Duration(milliseconds: 250),
                  ),
                ),
                SearchBar(searchFocusNode: _searchFocusNode),
              ],
            ),
          ),
        );
      },
    );
  }
}
