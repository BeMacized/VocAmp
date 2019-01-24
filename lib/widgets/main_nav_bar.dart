import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:vocaloid_player/globals.dart';
import 'package:vocaloid_player/redux/actions/home_actions.dart';
import 'package:vocaloid_player/redux/app_state.dart';

class MainNavBar extends StatelessWidget {
  const MainNavBar({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, int>(
      converter: (Store<AppState> store) => store.state.home.tab,
      builder: (BuildContext context, tabIndex) {
        return Theme(
          data: Theme.of(context).copyWith(canvasColor: Colors.grey.shade900),
          child: BottomNavigationBar(
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                  icon: Icon(Icons.home), title: Text('Home')),
              BottomNavigationBarItem(
                  icon: Icon(Icons.library_books), title: Text('Your Library')),
            ],
            currentIndex: tabIndex,
            fixedColor: Colors.white,
            onTap: (index) {
              Application.navigator.popUntil(ModalRoute.withName('/'));
              Application.store.dispatch(SetHomeTabAction(index));
            },
          ),
        );
      },
    );
  }
}
