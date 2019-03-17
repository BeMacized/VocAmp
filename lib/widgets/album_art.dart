import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class AlbumArt extends StatefulWidget {
  final double size;
  final String albumImageUrl;
  final ValueChanged<ImageProvider> imageProviderChanged;

  AlbumArt({
    this.size = double.infinity,
    this.albumImageUrl,
    this.imageProviderChanged,
  });

  @override
  AlbumArtState createState() {
    return AlbumArtState();
  }
}

class AlbumArtState extends State<AlbumArt> {
  ImageProvider provider;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        Widget placeholder =
            AlbumPlaceholder(size: min(constraints.maxWidth, widget.size));
        if (widget.albumImageUrl == null || widget.albumImageUrl.trim().isEmpty)
          return placeholder;
        return CachedNetworkImage(
          imageUrl: widget.albumImageUrl,
          placeholder: (context, url) => placeholder,
          errorWidget: (context, url, error) => placeholder,
          width: min(widget.size, constraints.maxWidth),
          fadeInCurve: Curves.ease,
          fadeOutCurve: Curves.ease,
          height: min(widget.size, constraints.maxWidth),
          fit: BoxFit.contain,
          imageBuilder: (BuildContext context, ImageProvider provider) {
            if (widget.imageProviderChanged != null &&
                this.provider != provider) {
              widget.imageProviderChanged(provider);
              this.provider = provider;
            }
            return Image(
              image: provider,
              fit: BoxFit.contain,
              width: min(widget.size, constraints.maxWidth),
              height: min(widget.size, constraints.maxWidth),
              alignment: Alignment.center,
              repeat: ImageRepeat.noRepeat,
              matchTextDirection: false,
            );
          },
        );
      },
    );
  }
}

class AlbumPlaceholder extends StatelessWidget {
  final double size;

  const AlbumPlaceholder({Key key, this.size = double.infinity})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey.shade800,
        ),
        color: Colors.grey.shade900,
      ),
      child: Icon(
        Icons.album,
//        color: Colors.grey.shade800,
        color: Theme.of(context).primaryColor,
        size: size * 0.75,
      ),
    );
  }
}
