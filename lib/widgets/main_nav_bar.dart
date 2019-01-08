import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class MainNavBar extends StatelessWidget {
  const MainNavBar({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
          canvasColor: Colors.grey.shade900
      ),
      child: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), title: Text('Home')),
          BottomNavigationBarItem(
              icon: Icon(Icons.search), title: Text('Search')),
          BottomNavigationBarItem(
              icon: Icon(Icons.library_books), title: Text('Your Library')),
        ],
        currentIndex: 0,
        fixedColor: Colors.white,
        onTap: (index) => {},
      ),
    );
  }
}
