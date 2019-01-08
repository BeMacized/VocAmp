import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:vocaloid_player/globals.dart';
import 'package:vocaloid_player/views/player_view/player_view_model.dart';

class SeekBar extends StatefulWidget {
  const SeekBar({
    Key key,
    @required this.vm,
  }) : super(key: key);

  final PlayerViewModel vm;

  @override
  SeekBarState createState() {
    return new SeekBarState();
  }
}

class SeekBarState extends State<SeekBar> {
  bool seeking = false;
  double seekValue = 0.0;

  @override
  Widget build(BuildContext context) {
    double value = seekValue;
    if (!seeking) {
      value = widget.vm.playerState.duration.inMilliseconds == 0
          ? 0
          : (widget.vm.playerState.position.inMilliseconds /
                  widget.vm.playerState.duration.inMilliseconds)
              .clamp(0, 1)
              .toDouble();
    }

    return Slider(
      value: value,
      activeColor: Theme.of(context).primaryColor,
      onChangeStart: (value) {
        seeking = true;
        seekValue = value;
      },
      onChangeEnd: (value) {
        seeking = false;
        int newPos =
            (seekValue * (widget.vm.playerState.duration?.inMilliseconds ?? 0))
                .round();
        Application.audioManager.seekTo(Duration(milliseconds: newPos));
      },
      onChanged: (value) => seekValue = value,
    );
  }
}
