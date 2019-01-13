import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class AlbumArt extends StatelessWidget {
  final double size;
  final ValueChanged<ImageProvider> loadedCallback;
  final VoidCallback failedCallback;
  final String albumImageUrl;

  AlbumArt({
    this.loadedCallback,
    this.size = double.infinity,
    this.albumImageUrl,
    this.failedCallback,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      child: CachedNetworkImage(
        imageUrl: albumImageUrl ?? '',
        placeholder: AlbumPlaceholder(size: size),
        errorWidget: AlbumPlaceholder(size: size),
        width: size,
        fadeInCurve: Curves.ease,
        fadeOutCurve: Curves.ease,
        height: size,
        fit: BoxFit.contain,
        loadedCallback: loadedCallback,
        failedCallback: failedCallback,
      ),
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
      decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey.shade800,
          ),
          color: Colors.grey.shade900),
      child: Icon(Icons.album, color: Colors.grey.shade800, size: size * 0.75),
    );
  }
}
