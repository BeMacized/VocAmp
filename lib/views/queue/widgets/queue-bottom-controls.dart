import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:provider/provider.dart';
import 'package:voc_amp/views/play/play-view.provider.dart';
import 'package:voc_amp/views/play/widgets/seek-bar.dart';

import '../queue-view.provider.dart';

class QueueBottomControls extends StatelessWidget {
  QueueViewProvider _viewProvider;

  QueueBottomControls(this._viewProvider);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          _buildSeekBar(),
          _buildControlRow(),
        ],
      ),
    );
  }

  Widget _buildSeekBar() {
    return Consumer<QueueViewProvider>(builder: (context, vp, snapshot) {
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

  Widget _buildControlRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 24,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: Center(
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: 200,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    _buildPreviousButton(),
                    _buildPlayPauseButton(),
                    _buildNextButton()
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviousButton() {
    return Consumer<PlayViewProvider>(
      builder: (context, vp, child) {
        return _buildControlButton(
          icon: Feather.skip_back,
          iconSize: 24,
          size: 48,
          onTap: vp.hasPrevious ? vp.skipPrevious : null,
        );
      },
    );
  }

  Widget _buildPlayPauseButton() {
    return Consumer<PlayViewProvider>(
      builder: (context, vp, child) {
        VoidCallback action;
        if (vp.playing) action = vp.pause;
        if (vp.paused || vp.stopped) action = vp.play;
        return _buildControlButton(
          icon: !vp.playing ? Entypo.controller_play : Entypo.controller_paus,
          iconSize: 24,
          size: 48,
//          iconOffset: Offset(vp.playing ? 0 : 2, -2),
          onTap: action,
        );
      },
    );
  }

  Widget _buildNextButton() {
    return Consumer<PlayViewProvider>(
      builder: (context, vp, child) {
        return _buildControlButton(
          icon: Feather.skip_forward,
          iconSize: 24,
          size: 48,
          onTap: vp.hasNext ? vp.skipNext : null,
        );
      },
    );
  }

  Widget _buildControlButton({
    double size = 48,
    double iconSize = 24,
    Color bgColor = Colors.transparent,
    Color splashColor = const Color(0x88FFFFFF),
    Color iconColor = Colors.white,
    Offset iconOffset = Offset.zero,
    VoidCallback onTap,
    @required IconData icon,
  }) {
    return SizedBox(
      width: size,
      height: size,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size),
        child: Material(
          color: bgColor.withOpacity(
            bgColor.alpha > 0 ? (onTap == null ? 0.5 : 1.0) : 0.0,
          ),
          child: InkWell(
            splashColor: splashColor,
            onTap: onTap,
            child: Center(
              child: Transform.translate(
                offset: iconOffset,
                child: Icon(
                  icon,
                  size: iconSize,
                  color: iconColor.withOpacity(onTap == null ? 0.5 : 1.0),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
