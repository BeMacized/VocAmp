import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:vocaloid_player/globals.dart';
import 'package:vocaloid_player/model/status_data.dart';
import 'package:vocaloid_player/model/vocadb/vocadb_album.dart';
import 'package:vocaloid_player/model/vocadb/vocadb_song.dart';
import 'package:vocaloid_player/views/home_view/tabs/home_tab/home_tab_model.dart';
import 'package:vocaloid_player/widgets/album_art.dart';
import 'package:sliver_fill_remaining_box_adapter/sliver_fill_remaining_box_adapter.dart';
import 'package:vocaloid_player/widgets/status_view.dart';

class SearchBody extends StatefulWidget {
  final HomeTabModel vm;

  SearchBody(this.vm);

  @override
  SearchBodyState createState() {
    return SearchBodyState();
  }
}

class SearchBodyState extends State<SearchBody> {
  ScrollController _scrollController;

  @override
  void initState() {
    _scrollController = ScrollController();
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: CustomScrollView(
        controller: _scrollController,
        slivers: _buildSlivers(context),
      ),
    );
  }

  ListTile _buildAlbumListTile(BuildContext context, VocaDBAlbum album) {
    List<PopupMenuEntry<String>> menuItems = [
      const PopupMenuItem<String>(
        value: 'PLAY',
        child: ListTile(
          title: Text('Play Now'),
        ),
      ),
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

    return ListTile(
      leading: AlbumArt(
        albumImageUrl: album.albumArtUrl,
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
      onTap: () => Application.navigator.pushNamed(
            '/album/' + album.id.toString(),
          ),
      trailing: menuItems.length > 0
          ? PopupMenuButton<String>(
              onSelected: (item) {
                switch (item) {
                  case 'QUEUE':
                    widget.vm.queueAlbum(context, album);
                    break;
                  case 'PLAY_NEXT':
                    widget.vm.playAlbumNext(context, album);
                    break;
                  case 'PLAY':
                    widget.vm.playAlbum(context, album);
                    break;
                }
              },
              itemBuilder: (BuildContext context) => menuItems,
            )
          : null,
    );
  }

  ListTile _buildSongListTile(
    BuildContext context,
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
              style: widget.vm.isSongActive(song)
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
      onTap: () => widget.vm.playSongSearchResults(song),
      enabled: enabled,
      trailing: menuItems.length > 0
          ? PopupMenuButton<String>(
              onSelected: (item) {
                switch (item) {
                  case 'QUEUE':
                    widget.vm.queueSong(context, song);
                    break;
                  case 'PLAY_NEXT':
                    widget.vm.playSongNext(context, song);
                    break;
                }
              },
              itemBuilder: (BuildContext context) => menuItems,
            )
          : null,
    );
  }

  List<Widget> _buildSlivers(BuildContext context) {
    List<Widget> slivers = [
      SearchHeader(
        child: Container(height: 54),
      ),
    ];

    // Query error
    if (widget.vm.searchState.error != null) {
      slivers.add(
        SliverFillRemainingBoxAdapter(
          child: StatusView(
            widget.vm.searchState.error,
          ),
        ),
      );
      return slivers;
    }

    // Loading
    if (widget.vm.searchState.loading) {
      slivers.add(
        SliverFillRemainingBoxAdapter(
          child: Container(
            alignment: Alignment.center,
            child: CircularProgressIndicator(),
          ),
        ),
      );
      return slivers;
    }

    // No results
    if (!widget.vm.searchState.hasResults) {
      slivers.add(
        SliverFillRemainingBoxAdapter(
          child: StatusView(
            StatusData(
                icon: Icons.clear,
                title: 'No results',
                subtitle:
                    '"${widget.vm.searchState.query}" got no results. Maybe try a different query?'),
          ),
        ),
      );
      return slivers;
    }

    // Albums
    if (widget.vm.searchState.albumResults.length > 0) {
      slivers.add(
        ResultBlock(
          title: "Albums",
          childCount: widget.vm.searchState.albumResults.length,
          builder: (BuildContext context, int index) => _buildAlbumListTile(
            context,
            widget.vm.searchState.albumResults[index],
          ),
        ),
      );
    }

    // Songs
    if (widget.vm.searchState.songResults.length > 0) {
      slivers.add(
        ResultBlock(
          title: "Songs",
          childCount: widget.vm.searchState.songResults.length,
          builder: (BuildContext context, int index) => _buildSongListTile(
                context,
                widget.vm.searchState.songResults[index],
              ),
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
