import 'dart:ui';

import 'package:flutter/material.dart';

class GradientUtils {
  static List<Color> curved(
    List<Color> colors, {
    List<double> stops,
    int resolution = 24,
    curve: Curves.linear,
  }) {
    assert(colors != null);
    assert(colors.length > 1);
    assert(stops == null ||
        (stops.length == colors.length && stops[stops.length - 1] == 1));
    // Generate uniform stops if none provided
    if (stops == null) {
      stops =
          List.generate(colors.length, (index) => index / (colors.length - 1));
    }
    // Color calc function
    Color getColorForStop(int stop, Curve curve) {
      // Calculate linear position
      double position = stop / (resolution - 1);
      // Calculate neighbouring stops
      double stopBeforeValue;
      int stopBeforeIndex;
      double stopAfterValue;
      int stopAfterIndex;
      for (int s = 0; s < stops.length; s++) {
        if (stops[s] <= position && s != stops.length - 1) {
          stopBeforeIndex = s;
          stopBeforeValue = stops[s];
        } else if (stops[s] >= position && stopAfterIndex == null) {
          stopAfterIndex = s;
          stopAfterValue = stops[s];
        }
      }
      // Calculate local (curved) position
      double localPosition = curve.transform(
          (position - stopBeforeValue) / (stopAfterValue - stopBeforeValue));
      // Calculate color
      return Color.lerp(
          colors[stopBeforeIndex], colors[stopAfterIndex], localPosition);
    }

    // Construct new list
    return [
      for (int stop = 0; stop < resolution; stop++) getColorForStop(stop, curve)
    ];
  }
}
