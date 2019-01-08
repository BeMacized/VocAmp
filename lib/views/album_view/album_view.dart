import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:vocaloid_player/redux/app_state.dart';
import 'package:vocaloid_player/views/album_view/album_header.dart';
import 'package:vocaloid_player/views/album_view/album_view_model.dart';
import 'package:vocaloid_player/widgets/main_nav_bar.dart';
import 'package:vocaloid_player/widgets/now_playing_bar.dart';

class AlbumView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, AlbumViewModel>(
      converter: AlbumViewModel.fromStore,
      builder: (BuildContext context, AlbumViewModel vm) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          bottomNavigationBar: MainNavBar(),
          body: Column(
            children: <Widget>[
              Expanded(
                child: Stack(
                  children: <Widget>[
                    Material(
                      color: Colors.black,
                      child: CustomScrollView(
                        slivers: _buildSlivers(context, vm),
                      ),
                    ),
                    IgnorePointer(
                      ignoring: !vm.loading,
                      child: AnimatedOpacity(
                        opacity: vm.loading ? 1.0 : 0.0,
                        curve: Curves.easeOut,
                        duration: Duration(milliseconds: 500),
                        child: Container(
                          color: Colors.black,
                          child: SafeArea(
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              NowPlayingBar(),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildSlivers(BuildContext context, AlbumViewModel vm) {
    // Add album header
    List<Widget> slivers = [AlbumHeader(vm)];
    // Define transformation functions
    ListTile mapTrackToListTile(AlbumViewModelTrack track) {
      bool enabled = track.song?.isAvailable ?? false;

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
        title: track.name == null
            ? null
            : Text(
                track.name,
                style: track.active
                    ? TextStyle(
                        color: Theme.of(context).primaryColor,
                      )
                    : null,
                softWrap: false,
                overflow: TextOverflow.ellipsis,
              ),
        subtitle: track.artistString == null
            ? null
            : Text(
                track.artistString,
                softWrap: false,
                overflow: TextOverflow.ellipsis,
              ),
        onTap: () => vm.playAlbum(track: track),
        enabled: enabled,
        trailing: menuItems.length > 0
            ? PopupMenuButton<String>(
                onSelected: (item) {
                  switch (item) {
                    case 'QUEUE':
                      vm.queueTrack(context, track);
                      break;
                    case 'PLAY_NEXT':
                      vm.playTrackNext(context, track);
                      break;
                  }
                },
                itemBuilder: (BuildContext context) => menuItems,
              )
            : null,
      );
    }

    List<Widget> foldDisks(List<Widget> list, entry) {
      // Add disc header
      list.add(
        SliverPersistentHeader(
          delegate: DiskHeader("Disc " + entry.key.toString()),
        ),
      );
      // Add songs from disc
      list.add(
        SliverList(
          delegate: SliverChildListDelegate(
            entry.value.map<Widget>(mapTrackToListTile).toList()
                as List<Widget>,
          ),
        ),
      );
      return list;
    }

    // Add disk and song entries
    slivers.addAll(
        (vm.discs?.entries ?? []).fold<List<Widget>>(<Widget>[], foldDisks));
    return slivers;
  }
}

class DiskHeader extends SliverPersistentHeaderDelegate {
  final String diskName;

  DiskHeader(this.diskName);

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Center(
          child: Text(
            diskName,
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
            softWrap: false,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }

  @override
  double get maxExtent => 40;

  @override
  double get minExtent => 40;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
