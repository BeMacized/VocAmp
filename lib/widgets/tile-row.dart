import 'package:flutter/widgets.dart';

class TileRow extends StatelessWidget {
  final List<Widget> children;
  final double gap;
  final double padding;

  TileRow({this.children = const <Widget>[], this.gap = 20, this.padding = 20});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: padding),
        child: Row(
          children: children
              .map((c) => [c, SizedBox(width: gap)])
              .expand((w) => w)
              .take(children.isEmpty ? 0 : children.length * 2 - 1)
              .toList(),
        ),
      ),
    );
  }
}
