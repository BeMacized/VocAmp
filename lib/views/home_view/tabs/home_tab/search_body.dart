import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:vocaloid_player/globals.dart';
import 'package:vocaloid_player/model/vocadb/vocadb_album.dart';
import 'package:vocaloid_player/redux/app_state.dart';
import 'package:vocaloid_player/redux/states/search_state.dart';
import 'package:vocaloid_player/widgets/album_art.dart';

class SearchBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, SearchState>(
      converter: (Store<AppState> store) => store.state.searchState,
      builder: (BuildContext context, SearchState vm) {
        return Container(
          color: Colors.black,
          child: CustomScrollView(
            slivers: _buildSlivers(context, vm),
          ),
        );
      },
    );
  }

  List<Widget> _buildSlivers(BuildContext context, SearchState vm) {
    List<Widget> slivers = [
      SearchHeader(
        child: Container(height: 54),
      ),
    ];
    //TODO: Songs

    // Albums
    slivers.add(
      ResultBlock(
        title: "Albums",
        childCount: vm.albumResults.length,
        maxItems: 5,
        builder: (BuildContext context, int index) {
          VocaDBAlbum album = vm.albumResults[index];
          return ListTile(
            leading: AlbumArt(
              albumImageUrl: album.mainPicture?.urlThumb,
              size: 48,
            ),
            title: Text(album.name),
            subtitle: Text(album.artistString),
            onTap: () => Application.navigator
                .pushNamed('/album/' + album.id.toString()),
          );
        },
      ),
    );

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
    this.maxItems = 5,
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
