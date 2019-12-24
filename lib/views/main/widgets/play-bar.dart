import 'package:flutter/material.dart';
import 'package:voc_amp/theme.dart';
import 'package:voc_amp/widgets/marquee.dart';

class PlayBar extends StatefulWidget {
  @override
  _PlayBarState createState() => _PlayBarState();
}

class _PlayBarState extends State<PlayBar> {
  @override
  Widget build(BuildContext context) {
    double expandedHeight = 56;
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed('/play');
      },
      child: AnimatedContainer(
        curve: Curves.easeInOut,
        duration: Duration(milliseconds: 250),
        height: expandedHeight,
        child: ClipRect(
          child: OverflowBox(
            alignment: Alignment.center,
            maxHeight: expandedHeight,
            child: Column(
              children: <Widget>[
                LayoutBuilder(builder: (context, constraints) {
                  return Container(
                    height: 2,
                    color: Colors.white.withOpacity(0.5),
                    alignment: Alignment.centerLeft,
                    child: AnimatedContainer(
                      height: 2,
                      duration: Duration(milliseconds: 250),
                      color: Colors.white,
                      width: constraints.maxWidth * 0.5,
                    ),
                  );
                }),
                Expanded(
                  child: Material(
                    color: paneBackgroundColor,
                    child: Row(
                      children: <Widget>[
                        AspectRatio(
                          aspectRatio: 1,
                          child: Center(
                            child: IconButton(
                              icon: Icon(Icons.star_border),
                              onPressed: () {},
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 5,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                Marquee(
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Text(
                                        'This is a very long track title',
                                        style: Theme.of(context)
                                            .textTheme
                                            .body2
                                            .copyWith(fontSize: 12),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 3.0,
                                        ),
                                        child: Text(
                                          '\u{2E31}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .body2
                                              .copyWith(
                                                fontSize: 12,
                                                color:
                                                    Colors.white.withOpacity(0.6),
                                              ),
                                        ),
                                      ),
                                      Text(
                                        'By this very artist who also has a long name',
                                        style: Theme.of(context)
                                            .textTheme
                                            .body2
                                            .copyWith(
                                              fontSize: 12,
                                              color:
                                                  Colors.white.withOpacity(0.6),
                                            ),
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        AspectRatio(
                          aspectRatio: 1,
                          child: Center(
                            child: IconButton(
                              icon: Icon(Icons.play_circle_outline),
                              onPressed: () {},
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
