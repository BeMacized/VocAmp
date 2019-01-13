import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:vocaloid_player/globals.dart';
import 'package:vocaloid_player/model/vocadb/vocadb_album.dart';
import 'package:vocaloid_player/model/vocadb/vocadb_song.dart';
import 'package:vocaloid_player/redux/app_state.dart';
import 'package:vocaloid_player/redux/states/search_state.dart';
import 'package:vocaloid_player/views/home_view/tabs/home_tab/home_tab_model.dart';
import 'package:vocaloid_player/widgets/album_art.dart';

class SearchBody extends StatelessWidget {
  final HomeTabModel vm;

  SearchBody(this.vm);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: CustomScrollView(
        slivers: _buildSlivers(context, vm),
      ),
    );
  }

  ListTile _buildSongListTile(
    BuildContext context,
    HomeTabModel vm,
    VocaDBSong song,
  ) {
    bool enabled = song.isAvailable ?? false;

    List<PopupMenuEntry<String>> menuItems = [];
    if (enabled)
      menuItems.addAll(
        [
          const PopupMenuItem<String>(
            value: 'QUEUE',
            child: ListTile(
              title: Text('Queue Song'),
            ),
          ),
          const PopupMenuItem<String>(
            value: 'PLAY_NEXT',
            child: ListTile(
              title: Text('Play Next'),
            ),
          ),
        ],
      );

    return ListTile(
      title: song.name == null
          ? null
          : Text(
              song.name,
              style: vm.isSongActive(song)
                  ? TextStyle(
                      color: Theme.of(context).primaryColor,
                    )
                  : null,
              softWrap: false,
              overflow: TextOverflow.ellipsis,
            ),
      subtitle: song.artistString == null
          ? null
          : Text(
              song.artistString,
              softWrap: false,
              overflow: TextOverflow.ellipsis,
            ),
      onTap: () => vm.playSongSearchResults(song),
      enabled: enabled,
      trailing: menuItems.length > 0
          ? PopupMenuButton<String>(
              onSelected: (item) {
                switch (item) {
                  case 'QUEUE':
                    vm.queueSong(context, song);
                    break;
                  case 'PLAY_NEXT':
                    vm.playSongNext(context, song);
                    break;
                }
              },
              itemBuilder: (BuildContext context) => menuItems,
            )
          : null,
    );
  }

  List<Widget> _buildSlivers(BuildContext context, HomeTabModel vm) {
    List<Widget> slivers = [
      SearchHeader(
        child: Container(height: 54),
      ),
    ];

    // Songs
    if (vm.searchState.songResults.length > 0) {
      slivers.add(
        ResultBlock(
          title: "Songs",
          childCount: vm.searchState.songResults.length,
          builder: (BuildContext context, int index) => _buildSongListTile(
                context,
                vm,
                vm.searchState.songResults[index],
              ),
        ),
      );
    }

    // Albums
    if (vm.searchState.albumResults.length > 0) {
      slivers.add(
        ResultBlock(
          title: "Albums",
          childCount: vm.searchState.albumResults.length,
          builder: (BuildContext context, int index) {
            VocaDBAlbum album = vm.searchState.albumResults[index];
            return ListTile(
              leading: AlbumArt(
                albumImageUrl: album.mainPicture?.urlThumb,
                size: 48,
              ),
              title: Text(
                album.name,
                softWrap: false,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                album.artistString,
                softWrap: false,
                overflow: TextOverflow.ellipsis,
              ),
              onTap: () => Application.navigator
                  .pushNamed('/album/' + album.id.toString()),
            );
          },
        ),
      );
    }

    //TODO: Artists
    return slivers;
  }
}

class SearchHeader extends StatelessWidget {
  final Widget child;
  final Color color;

  SearchHeader({this.child, this.color = Colors.grey});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 58),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: <Color>[color, Colors.black],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: child,
      ),
    );
  }
}

class ResultBlock extends StatefulWidget {
  final String title;
  final int maxItems;
  final int childCount;
  final IndexedWidgetBuilder builder;

  const ResultBlock({
    Key key,
    @required this.title,
    @required this.builder,
    @required this.childCount,
    this.maxItems = 4,
  }) : super(key: key);

  @override
  ResultBlockState createState() {
    return ResultBlockState();
  }
}

class ResultBlockState extends State<ResultBlock> {
  bool expanded;

  @override
  void initState() {
    super.initState();
    expanded = false;
  }

  @override
  Widget build(BuildContext context) {
    // Start with title
    List<Widget> children = [
      Container(
        padding: EdgeInsets.symmetric(vertical: 12),
        alignment: Alignment.center,
        child: Text(
          widget.title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
    ];

    // Map items
    children.addAll(
      List.generate(
          expanded
              ? widget.childCount
              : min(widget.maxItems, widget.childCount),
          (i) => widget.builder(context, i)),
    );

    // Add "view more"
    if (widget.maxItems < widget.childCount) {
      String excess = (widget.childCount - widget.maxItems).toString();
      String text = expanded ? "Hide " + excess : "View " + excess + " more";
      children.add(
        ListTile(
          title: Text(text),
          leading: Icon(
            expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
          ),
          onTap: () => setState(() {
                expanded = !expanded;
              }),
        ),
      );
    }
    return SliverToBoxAdapter(
      child: Material(
        color: Colors.transparent,
        child: Column(
          children: children,
        ),
      ),
    );
  }
}
