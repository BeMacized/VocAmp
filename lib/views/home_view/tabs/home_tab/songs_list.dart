import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:vocaloid_player/model/vocadb/vocadb_song.dart';
import 'package:vocaloid_player/views/home_view/tabs/home_tab/home_tab_model.dart';
import 'package:vocaloid_player/widgets/album_art.dart';
import 'package:vocaloid_player/widgets/press_animation.dart';

class SongsList extends StatelessWidget {
  final double padding = 12;
  final HomeTabModel vm;

  const SongsList(
    this.vm, {
    Key key,
  }) : super(key: key);

  Widget _buildSongListTile(BuildContext context, VocaDBSong song) {
    List<PopupMenuEntry<String>> menuItems = [
      const PopupMenuItem<String>(
        value: 'QUEUE',
        child: ListTile(
          title: Text('Queue Album'),
        ),
      ),
      const PopupMenuItem<String>(
        value: 'PLAY_NEXT',
        child: ListTile(
          title: Text('Play Next'),
        ),
      ),
    ];

    return PressAnimation(
      onTap: () => vm.playSongInList(
            song,
            vm.homeState.highlightedSongs.songs,
            vm.generateHighlightedSongContextId(song),
          ),
      child: ListTile(
        leading: AlbumArt(
          albumImageUrl: song.artUrl,
          size: 48,
        ),
        title: Text(
          song.name,
          style: vm.generateHighlightedSongContextId(song) ==
                  vm.currentSongContextId
              ? TextStyle(
                  color: Theme.of(context).primaryColor,
                )
              : null,
          softWrap: false,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          song.artistString,
          softWrap: false,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: menuItems.length > 0
            ? PopupMenuButton<String>(
                onSelected: (item) {
                  switch (item) {
                    case 'QUEUE':
                      vm.queueSong(
                        context,
                        song,
                        vm.generateHighlightedSongContextId(song),
                      );
                      break;
                    case 'PLAY_NEXT':
                      vm.playSongNext(
                        context,
                        song,
                        vm.generateHighlightedSongContextId(song),
                      );
                      break;
                  }
                },
                itemBuilder: (BuildContext context) => menuItems,
              )
            : null,
      ),
    );
  }

  Widget _buildPlaceholderList(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          height: 58,
          alignment: Alignment.center,
          child: CircularProgressIndicator(),
        ),
      ],
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
              "Highlighted Songs",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
              softWrap: false,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          AnimatedCrossFade(
            firstChild: _buildPlaceholderList(context),
            secondChild: Container(
              child: Column(
                children: vm.homeState.highlightedSongs.songs
                    .map<Widget>((song) => _buildSongListTile(context, song))
                    .toList(),
              ),
            ),
            crossFadeState: vm.homeState.highlightedSongs.loading
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            duration: Duration(milliseconds: 300),
          )
        ],
      ),
    );
  }
}
