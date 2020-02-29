import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class SeekBar extends StatefulWidget {
  @override
  _SeekBarState createState() => _SeekBarState();
}

class _SeekBarState extends State<SeekBar> {
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
                child: Slider(
                  value: 1000,
                  max: 3000,
                  onChanged: (double value) {},
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    '0:00',
                    style: Theme.of(context).textTheme.caption,
                  ),
                  Text(
                    '3:56',
                    style: Theme.of(context).textTheme.caption,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
