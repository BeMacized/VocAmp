import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:vocaloid_player/globals.dart';
import 'package:vocaloid_player/model/vocadb/vocadb_album.dart';
import 'package:vocaloid_player/redux/actions/home_actions.dart';
import 'package:vocaloid_player/views/home_view/tabs/home_tab/home_tab_model.dart';
import 'package:vocaloid_player/widgets/album_art.dart';
import 'package:vocaloid_player/widgets/press_animation.dart';

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
      alignment: Alignment.topCenter,
      child: CustomScrollView(
        controller: _scrollController,
        slivers: _buildSlivers(context),
      ),
    );
  }

  List<Widget> _buildSlivers(BuildContext context) {
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
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(1)
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    // Random Popular Albums
    slivers.add(AlbumRow(widget.vm));
    slivers.add(AlbumRow(widget.vm));
    return slivers;
  }
}

class AlbumRow extends StatelessWidget {
  final double padding = 12;
  final HomeTabModel vm;

  const AlbumRow(
    this.vm, {
    Key key,
  }) : super(key: key);

  Widget _buildList(BuildContext context, double height, double albumSize) {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: vm.homeState.topAlbums.length,
      padding: EdgeInsets.symmetric(horizontal: padding),
      itemBuilder: (context, index) {
        VocaDBAlbum album = vm.homeState.topAlbums[index];
        return PressAnimation(
          onTap: () =>
              Application.navigator.pushNamed('/album/' + album.id.toString()),
          child: Container(
            width: albumSize,
            height: height,
            child: Column(
              children: <Widget>[
                AlbumArt(
                  albumImageUrl: album.mainPicture?.urlThumb,
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
                  alignment: Alignment.center,
                  width: double.infinity,
                  child: CircularProgressIndicator(),
                ),
                secondChild: Container(
                  height: height,
                  child: _buildList(context, height, albumSize),
                ),
                crossFadeState: vm.homeState.loadingTopAlbums
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
