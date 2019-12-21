import 'package:flutter/material.dart';
import 'package:voc_amp/models/media/track.dart';
import 'package:voc_amp/widgets/pressable.dart';

class TrackListItem extends StatelessWidget {
  final Track track;

  TrackListItem({
    @required this.track,
  });

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: (){},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: <Widget>[
            // Left size
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Text(
                      track.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.body1,
                    ),
                    SizedBox(height: 2),
                    Text(
                      track.artist,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.caption,
                    ),
                  ],
                ),
              ),
            ),
            // Right side
            Container()
          ],
        ),
      ),
    );
  }
}
