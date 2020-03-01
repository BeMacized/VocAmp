import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import '../play-view.provider.dart';

class PlayAlbumArea extends StatefulWidget {
  PlayViewProvider _viewProvider;

  PlayAlbumArea(this._viewProvider);

  @override
  _PlayAlbumAreaState createState() => _PlayAlbumAreaState();
}

class _PlayAlbumAreaState extends State<PlayAlbumArea> {
  PageController _pageController;
  bool _pageViewIsAnimating = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    widget._viewProvider.addListener(_onViewProviderChange);
    _onViewProviderChange();
  }

  @override
  void dispose() {
    widget._viewProvider.removeListener(_onViewProviderChange);
    _pageController.dispose();
    super.dispose();
  }

  _onViewProviderChange() {
    // Determine current page
    int page = widget._viewProvider.queueIndex;
    // Animate to page
    bool animate = _pageController.hasClients;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (animate) {
        _pageViewIsAnimating = true;
        _pageController
            .animateToPage(
              page,
              duration: Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            )
            .then((_) => _pageViewIsAnimating = false);
      } else {
        _pageViewIsAnimating = true;
        _pageController.jumpToPage(page);
        _pageViewIsAnimating = false;
      }
    });
  }

  _onPageChange(int newPage) async {
    if (!_pageViewIsAnimating && newPage != widget._viewProvider.queueIndex)
      widget._viewProvider.skipToIndex(newPage);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PlayViewProvider>(
      builder: (context, vp, child) {
        // Build page view
        return PageView(
          controller: _pageController,
          onPageChanged: _onPageChange,
          children: (vp.tracks ?? [])
              .map(
                (t) => _buildAlbumPage(t?.track?.artUri),
              )
              .toList(),
        );
      },
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
