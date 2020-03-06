import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:voc_amp/models/media/queue-track.dart';
import '../play-view.provider.dart';

class PlayAlbumArea extends StatefulWidget {
  PlayViewProvider _viewProvider;

  PlayAlbumArea(this._viewProvider);

  @override
  _PlayAlbumAreaState createState() => _PlayAlbumAreaState();
}

class _PlayAlbumAreaState extends State<PlayAlbumArea> {
  PageController _pageController;
  bool _shuffled;
  List<QueueTrack> _tracks = [];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    widget._viewProvider.addListener(_onViewProviderChange);
    _shuffled = widget._viewProvider.shuffled;
    _tracks = widget._viewProvider.tracks;
    _onViewProviderChange();
  }

  @override
  void dispose() {
    widget._viewProvider.removeListener(_onViewProviderChange);
    _pageController.dispose();
    super.dispose();
  }

  _onViewProviderChange() {
    setState(() => this._tracks = widget._viewProvider.tracks);
    // Determine if the shuffle status changed (for skipping animation)
    bool shuffleChanged = widget._viewProvider.shuffled != _shuffled;
    if (shuffleChanged) _shuffled = widget._viewProvider.shuffled;
    // Determine current page
    int page = widget._viewProvider.queueIndex;
    // Animate to page
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_pageController.hasClients || page == _pageController.page.round())
        return;
      if (!shuffleChanged) {
        _pageController
            .animateToPage(
              page,
              duration: Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            )
            .then((_) {});
      } else {
        _pageController.jumpToPage(page);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Build page view
    return PageView(
      controller: _pageController,
      physics: NeverScrollableScrollPhysics(),
      children: (_tracks ?? [])
          .map(
            (t) => _buildAlbumPage(t?.track?.artUri),
          )
          .toList(),
    );
  }

  Widget _buildAlbumPage(String artUri) {
    return Container(
      padding: EdgeInsets.all(24),
      child: Center(
        child: AspectRatio(
          aspectRatio: 1 / 1,
          child: Material(
            elevation: 10,
            child: CachedNetworkImage(
              imageUrl: artUri,
              fit: BoxFit.cover,
              height: double.infinity,
              width: double.infinity,
            ),
          ),
        ),
      ),
    );
  }
}
