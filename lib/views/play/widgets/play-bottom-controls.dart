import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:voc_amp/views/play/widgets/seek-bar.dart';
import 'package:voc_amp/widgets/marquee.dart';

class PlayBottomControls extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          _buildTitleArea(context),
          _buildSeekBar(),
          _buildControlRow(),
          _buildActionRow(),
        ],
      ),
    );
  }

  Widget _buildTitleArea(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 12, bottom: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Marquee(
                  alignment: MarqueeAlignment.start,
                  child: Text(
                    'ラッキー☆オーブ',
                    style: Theme.of(context).textTheme.title,
                  ),
                ),
                Marquee(
                  alignment: MarqueeAlignment.start,
                  child: Text(
                    'emon feat. 初音ミク',
                    style: Theme.of(context).textTheme.subtitle.copyWith(
                          color: Colors.white.withOpacity(0.7),
                        ),
                  ),
                )
              ],
            ),
          ),
          _buildControlButton(icon: AntDesign.staro, onTap: () {}),
        ],
      ),
    );
  }

  Widget _buildSeekBar() {
    return Padding(
      padding: const EdgeInsets.only(),
      child: SeekBar(),
    );
  }

  Widget _buildControlRow() {
    return Padding(
      padding: const EdgeInsets.only(
        left: 12,
        right: 12,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          _buildShuffleToggle(),
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
          _buildRepeatToggle(),
        ],
      ),
    );
  }

  Widget _buildActionRow() {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 48.0,
        left: 12,
        right: 12,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(),
          _buildControlButton(icon: MaterialIcons.playlist_play, onTap: () {}),
        ],
      ),
    );
  }

  Widget _buildShuffleToggle() {
    return _buildControlButton(
      icon: Feather.shuffle,
      onTap: () {},
    );
  }

  Widget _buildRepeatToggle() {
    return _buildControlButton(
      icon: Feather.repeat,
      onTap: () {},
    );
  }

  Widget _buildPreviousButton() {
    return _buildControlButton(
      icon: Feather.skip_back,
      iconSize: 32,
      size: 54,
      onTap: () {},
    );
  }

  Widget _buildPlayPauseButton() {
    bool playing = false;
    return _buildControlButton(
      icon: !playing ? Entypo.controller_play : Entypo.controller_paus,
      bgColor: Colors.white,
      splashColor: Colors.black.withOpacity(0.2),
      iconColor: Colors.black.withOpacity(0.8),
      iconSize: 42,
      size: 64,
      iconOffset: Offset(playing ? 0 : 2, -2),
      onTap: () {},
    );
  }

  Widget _buildNextButton() {
    return _buildControlButton(
      icon: Feather.skip_forward,
      iconSize: 32,
      size: 54,
      onTap: () {},
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
          color: bgColor,
          child: InkWell(
            splashColor: splashColor,
            onTap: onTap,
            child: Center(
              child: Transform.translate(
                offset: iconOffset,
                child: Icon(
                  icon,
                  size: iconSize,
                  color: iconColor,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
