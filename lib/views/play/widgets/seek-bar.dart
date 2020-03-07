import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../play-view.provider.dart';

class SeekBar extends StatefulWidget {
  @override
  _SeekBarState createState() => _SeekBarState();
}

class _SeekBarState extends State<SeekBar> {
  double seekValue;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 28,
      child: Stack(
        children: <Widget>[
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 16,
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  thumbColor: Colors.white,
                  disabledThumbColor: Colors.white.withOpacity(0.7),
                  activeTrackColor: Colors.white,
                  disabledActiveTrackColor: Colors.white.withOpacity(0.7),
                  inactiveTrackColor: Colors.white.withOpacity(0.3),
                  disabledInactiveTrackColor: Colors.white.withOpacity(0.1),
                  trackShape: RoundedRectSliderTrackShape(),
                  trackHeight: 2,
                  thumbShape: RoundSliderThumbShape(
                    disabledThumbRadius: 5.0,
                    enabledThumbRadius: 5.0,
                  ),
                ),
                child: Consumer<PlayViewProvider>(
                  builder: (context, vp, child) {
                    double sliderMax = vp.currentTrack
                            ?.getDuration()
                            ?.inMilliseconds
                            ?.toDouble() ??
                        0.0;
                    return StreamBuilder(
                      stream: Stream.periodic(Duration(milliseconds: 10)),
                      builder: (context, snapshot) {
                        double sliderValue = (seekValue ?? vp.position.inMilliseconds.toDouble()).clamp(0, sliderMax);
                        return Slider(
                          value: sliderValue,
                          max: sliderMax,
                          onChangeStart: (value) =>
                              setState(() => this.seekValue = value),
                          onChanged: (value) =>
                              setState(() => this.seekValue = value),
                          onChangeEnd: (double value) async {
                            await vp.seek(Duration(seconds: value.floor()));
                            setState(() => this.seekValue = null);
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Consumer<PlayViewProvider>(builder: (context, vp, child) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    StreamBuilder(
                        stream: Stream.periodic(Duration(milliseconds: 10)),
                        builder: (context, snapshot) {
                          return Text(
                            _formatDuration(vp.position),
                            style: Theme.of(context).textTheme.caption,
                          );
                        }),
                    Text(
                      _formatDuration(
                        vp.currentTrack?.getDuration() ?? Duration(seconds: 0),
                      ),
                      style: Theme.of(context).textTheme.caption,
                    ),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => (n >= 10) ? "$n" : "0$n";
    int seconds = duration.inSeconds.remainder(60).toInt();
    int minutes = duration.inMinutes.remainder(60).toInt();
    int hours = duration.inHours.remainder(24).toInt();
    return (hours > 0)
        ? "$hours:${twoDigits(minutes)}:${twoDigits(seconds)}"
        : "$minutes:${twoDigits(seconds)}";
  }
}
