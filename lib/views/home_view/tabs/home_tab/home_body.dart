import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:vocaloid_player/globals.dart';
import 'package:vocaloid_player/model/status_data.dart';
import 'package:vocaloid_player/redux/actions/home_actions.dart';
import 'package:vocaloid_player/views/home_view/tabs/home_tab/album_row.dart';
import 'package:vocaloid_player/views/home_view/tabs/home_tab/home_tab_model.dart';
import 'package:vocaloid_player/views/home_view/tabs/home_tab/songs_list.dart';
import 'package:vocaloid_player/widgets/status_view.dart';

class HomeBody extends StatefulWidget {
  final HomeTabModel vm;

  HomeBody(this.vm);

  @override
  HomeBodyState createState() {
    return HomeBodyState();
  }
}

class HomeBodyState extends State<HomeBody> {
  ScrollController _scrollController;

  @override
  void initState() {
    _scrollController = ScrollController();
    Application.store.dispatch(loadHomeTopAlbumsAction());
    Application.store.dispatch(loadHomeHighlightedSongsAction());
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    StatusData loadError = widget.vm.homeState.topAlbums.error ??
        widget.vm.homeState.highlightedSongs.error;

    List<Widget> children = [
      Container(
        color: Colors.black,
        alignment: Alignment.topCenter,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: _buildSlivers(context, loadError != null),
        ),
      ),
    ];

    if (loadError != null) children.add(StatusView(loadError));

    return Stack(children: children);
  }

  List<Widget> _buildSlivers(BuildContext context, bool error) {
    List<Widget> slivers = [];

    // Image Header
    slivers.add(
      SliverToBoxAdapter(
        child: Stack(
          children: <Widget>[
            Container(
              height: 200,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('images/home/header_bg.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Container(
              height: 200,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.transparent, Colors.black.withOpacity(1)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (!error) {
      // Random Popular Albums
      slivers.add(AlbumRow(widget.vm.homeState.topAlbums));
      // Highlighted Songs
      slivers.add(SongsList(widget.vm));
    }

    return slivers;
  }
}
