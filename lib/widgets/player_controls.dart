import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:vocaloid_player/audio/CustomAudioPlayer.dart';
import 'package:vocaloid_player/globals.dart';
import 'package:vocaloid_player/redux/states/player_state.dart';

class PlayerControls extends StatelessWidget {
  final PlayerState playerState;

  const PlayerControls(
    this.playerState, {
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        shuffleButton(context),
        previousButton(),
        playPauseButton(context),
        nextButton(),
        repeatButton(context),
      ],
    );
  }

  Widget repeatButton(BuildContext context) {
    IconData icon;
    Color color;
    switch (playerState.repeatMode) {
      case RepeatMode.ALL:
        icon = Icons.repeat;
        color = Theme.of(context).primaryColor;
        break;
      case RepeatMode.SINGLE:
        icon = Icons.repeat_one;
        color = Theme.of(context).primaryColor;
        break;
      case RepeatMode.NONE:
        icon = Icons.repeat;
        color = Colors.white;
        break;
    }
    return IconButton(
        icon: Icon(icon, color: color),
        onPressed: Application.audioManager.cycleRepeatMode);
  }

  Widget shuffleButton(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.shuffle,
          color: playerState.shuffle
              ? Theme.of(context).primaryColor
              : Colors.white),
      onPressed: Application.audioManager.toggleShuffleMode,
    );
  }

  Widget previousButton() {
    return IconButton(
      icon: Icon(Icons.skip_previous, size: 32),
      onPressed: Application.audioManager.skipToPrevious,
      disabledColor: Colors.white.withOpacity(0.25),
    );
  }

  Widget nextButton() {
    return IconButton(
      icon: Icon(Icons.skip_next, size: 32),
      onPressed: Application.audioManager.skipToNext,
      disabledColor: Colors.white.withOpacity(0.25),
    );
  }

  IconData _getPlaybackButtonIcon(BasicPlaybackState state) {
    switch (state) {
      case BasicPlaybackState.buffering:
      case BasicPlaybackState.playing:
        return Icons.pause;
      case BasicPlaybackState.paused:
        return Icons.play_arrow;
      default:
        return Icons.play_arrow;
    }
  }

  Widget playPauseButton(BuildContext context) {
    bool disabled = playerState.state != BasicPlaybackState.playing &&
        playerState.state != BasicPlaybackState.paused &&
        playerState.state != BasicPlaybackState.stopped;
    IconData icon = _getPlaybackButtonIcon(playerState.state);
    return OutlineButton(
      child: Icon(icon,
          color: Colors.white.withOpacity(disabled ? 0.25 : 1), size: 32),
      shape: new CircleBorder(),
      highlightedBorderColor: Colors.white,
      splashColor: Theme.of(context).splashColor,
      padding: EdgeInsets.all(12),
      onPressed: disabled ? null : Application.audioManager.playPause,
    );
  }
}
