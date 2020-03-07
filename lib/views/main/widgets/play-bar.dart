import 'dart:math';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:voc_amp/models/media/queue-track.dart';
import 'package:voc_amp/providers/audio-player.provider.dart';
import 'package:voc_amp/theme.dart';
import 'package:voc_amp/views/main/widgets/play-bar.provider.dart';
import 'package:voc_amp/views/play/play-view.provider.dart';
import 'package:voc_amp/widgets/marquee.dart';

class PlayBar extends StatefulWidget {
  @override
  _PlayBarState createState() => _PlayBarState();
}

class _PlayBarState extends State<PlayBar> {
  @override
  Widget build(BuildContext context) {
    double expandedHeight = 56;
    return Consumer<PlayBarProvider>(builder: (context, vp, snapshot) {
      return GestureDetector(
        onTap: () {
          Navigator.of(context).pushNamed('/play');
        },
        child: AnimatedContainer(
          curve: Curves.easeInOut,
          duration: Duration(milliseconds: 250),
          height: vp.currentTrack != null ? expandedHeight : 0,
          child: ClipRect(
            child: OverflowBox(
              alignment: Alignment.topCenter,
              maxHeight: expandedHeight,
              child: Column(
                children: <Widget>[
                  _buildSeekBar(),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Colors.black),
                        ),
                      ),
                      child: Material(
                        color: paneBackgroundColor,
                        child: Row(
                          children: <Widget>[
                            AspectRatio(
                              aspectRatio: 1,
                              child: Center(
                                child: _buildLikeButton(),
                              ),
                            ),
                            Expanded(
                              child: _buildCenterPane(vp.currentTrack),
                            ),
                            AspectRatio(
                              aspectRatio: 1,
                              child: Center(
                                child: _buildPlayPauseButton(
                                  vp,
                                  vp.basicPlaybackState,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildSeekBar() {
    return Consumer<PlayBarProvider>(builder: (context, vp, snapshot) {
      return LayoutBuilder(builder: (context, constraints) {
        return StreamBuilder(
          stream: Stream.periodic(Duration(milliseconds: 10)),
          builder: (context, snapshot) {
            return Container(
              height: 2,
              color: Colors.white.withOpacity(0.5),
              alignment: Alignment.centerLeft,
              child: AnimatedContainer(
                height: 2,
                duration: Duration(milliseconds: 250),
                color: Colors.white,
                width: constraints.maxWidth * vp.normalPosition,
              ),
            );
          },
        );
      });
    });
  }

  Widget _buildCenterPane(QueueTrack currentTrack) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 5,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          if (currentTrack?.track != null)
            Marquee(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    currentTrack.track.title,
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
                      style: Theme.of(context).textTheme.body2.copyWith(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.6),
                          ),
                    ),
                  ),
                  Text(
                    currentTrack.track.artist,
                    style: Theme.of(context).textTheme.body2.copyWith(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.6),
                        ),
                  )
                ],
              ),
            )
        ],
      ),
    );
  }

  Widget _buildLikeButton() {
    return IconButton(
      icon: Icon(Icons.star_border),
      onPressed: () {},
    );
  }

  Widget _buildPlayPauseButton(
      PlayBarProvider vp, BasicPlaybackState playbackState) {
    IconData icon;
    VoidCallback action;
    switch (playbackState) {
      case BasicPlaybackState.error:
      case BasicPlaybackState.paused:
        icon = Icons.play_circle_outline;
        action = vp.play;
        break;
      case BasicPlaybackState.connecting:
      case BasicPlaybackState.buffering:
      case BasicPlaybackState.playing:
        icon = Icons.pause_circle_outline;
        action = vp.pause;
        break;
      case BasicPlaybackState.stopped:
      case BasicPlaybackState.none:
      default:
        icon = Icons.play_circle_outline;
        break;
    }
    return IconButton(
      icon: Icon(icon),
      onPressed: action,
    );
  }
}
