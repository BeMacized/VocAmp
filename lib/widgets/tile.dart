import 'package:flutter/material.dart';

class Tile extends StatelessWidget {
  final Widget art;
  final String title;
  final String subtitle;
  final double width;
  final TextAlign textAlign;

  Tile(
      {@required this.art,
      @required this.title,
      this.width = 160,
      this.subtitle,
      this.textAlign = TextAlign.start});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          art,
          SizedBox(height: 10),
          Text(
            title,
            style: Theme.of(context).textTheme.body2,
            textAlign: textAlign,
            overflow: TextOverflow.ellipsis,
          ),
          if (subtitle != null) ...[
            SizedBox(height: 2),
            Opacity(
              opacity: 0.6,
              child: Text(
                subtitle,
                style: Theme.of(context).textTheme.body1,
                textAlign: textAlign,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
