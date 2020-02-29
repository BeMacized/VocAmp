import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

const ALBUM_ART_URL = "https://vocadb.net/Album/CoverPicture/26528?v=11";

class PlayAlbumArea extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PageView(
      children: <Widget>[for (int i = 0; i < 10; i++) _buildAlbumPage()],
    );
  }

  Widget _buildAlbumPage() {
    return Container(
      padding: EdgeInsets.all(24),
      child: Center(
        child: AspectRatio(
          aspectRatio: 1 / 1,
          child: Card(
            elevation: 10,
            child: CachedNetworkImage(
              imageUrl: ALBUM_ART_URL,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}
