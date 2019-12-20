import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:voc_amp/widgets/list-art.dart';

class TrackListImage {
  String url;
  double size;
  Color gradientColor;
  Color textColor;
  List<String> text;

  TrackListImage({
    @required this.url,
    this.size,
    this.gradientColor,
    this.textColor,
    this.text,
  });

  ListArt buildWidget() {
    return ListArt(
      imageUrl: url,
      size: size,
      gradientColor: gradientColor,
      textColor: textColor,
      text: text,
    );
  }
}
