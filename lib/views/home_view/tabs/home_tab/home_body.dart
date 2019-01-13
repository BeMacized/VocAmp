import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class HomeBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      alignment: Alignment.topCenter,
      child: Padding(
        padding:
            EdgeInsets.only(top: MediaQuery.of(context).padding.top + 54 + 8),
        child: Text(
          "Home",
          style: TextStyle(
            fontSize: 50,
          ),
        ),
      ),
    );
  }
}
