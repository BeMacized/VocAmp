import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:vocaloid_player/globals.dart';
import 'package:vocaloid_player/model/vocadb/vocadb_album.dart';
import 'package:vocaloid_player/redux/states/home_top_albums_state.dart';
import 'package:vocaloid_player/widgets/album_art.dart';
import 'package:vocaloid_player/widgets/press_animation.dart';

class AlbumRow extends StatelessWidget {
  final double padding = 12;
  final HomeTopAlbumsState vm;

  const AlbumRow(
    this.vm, {
    Key key,
  }) : super(key: key);

  Widget _buildPlaceholderList(
      BuildContext context, double height, double albumSize) {
    return Stack(
      children: <Widget>[
        IgnorePointer(
          child: Opacity(
            opacity: 0.5,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 3,
              padding: EdgeInsets.symmetric(horizontal: padding),
              itemBuilder: (context, index) {
                return Container(
                  width: albumSize,
                  height: height,
                  child: Column(
                    children: <Widget>[
                      AlbumArt(
                        albumImageUrl: '',
                        size: albumSize,
                      ),
                    ],
                  ),
                );
              },
              separatorBuilder: (BuildContext context, int index) {
                return Container(width: padding);
              },
            ),
          ),
        ),
        Container(
          height: albumSize,
          alignment: Alignment.center,
          child: CircularProgressIndicator(),
        ),
      ],
    );
  }

  Widget _buildList(BuildContext context, double height, double albumSize) {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: vm.albums.length,
      padding: EdgeInsets.symmetric(horizontal: padding),
      itemBuilder: (context, index) {
        VocaDBAlbum album = vm.albums[index];
        return PressAnimation(
          onTap: () =>
              Application.navigator.pushNamed('/album/' + album.id.toString()),
          child: Container(
            width: albumSize,
            height: height,
            child: Column(
              children: <Widget>[
                AlbumArt(
                  albumImageUrl: album.albumArtUrl,
                  size: albumSize,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8, left: 8, right: 8),
                  child: Text(
                    album.name,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
              ],
            ),
          ),
        );
      },
      separatorBuilder: (BuildContext context, int index) {
        return Container(width: padding);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              "Popular Albums",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
              softWrap: false,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              double albumSize = (constraints.maxWidth - padding * 4) / 2.5;
              double height = albumSize + 50;
              return AnimatedCrossFade(
                firstChild: Container(
                  height: height,
                  child: _buildPlaceholderList(context, height, albumSize),
                ),
                secondChild: Container(
                  height: height,
                  child: _buildList(context, height, albumSize),
                ),
                crossFadeState: vm.loading
                    ? CrossFadeState.showFirst
                    : CrossFadeState.showSecond,
                duration: Duration(milliseconds: 300),
              );
            },
          ),
        ],
      ),
    );
  }
}