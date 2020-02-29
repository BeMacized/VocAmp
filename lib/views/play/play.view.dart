import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:voc_amp/utils/gradient-utils.dart';
import 'package:voc_amp/views/play/play-view.provider.dart';
import 'package:voc_amp/views/play/widgets/play-album-area.dart';
import 'package:voc_amp/views/play/widgets/play-bottom-controls.dart';

const ALBUM_ART_URL = "https://vocadb.net/Album/CoverPicture/26528?v=11";

class PlayView extends StatefulWidget {
  @override
  _PlayViewState createState() => _PlayViewState();
}

class _PlayViewState extends State<PlayView> {
  PlayViewProvider _viewProvider;

  didChangeDependencies() {
    super.didChangeDependencies();
    // Obtain view provider
    final _viewProvider = Provider.of<PlayViewProvider>(context);
    if (_viewProvider != this._viewProvider) {
      this._viewProvider = _viewProvider;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Stack(
        children: <Widget>[
          _buildBackground(),
          Column(
            children: <Widget>[
              Expanded(
                child: PlayAlbumArea(_viewProvider),
              ),
              PlayBottomControls(_viewProvider),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return AppBar(
      title: Text(
        'NOW PLAYING',
        style: Theme.of(context).textTheme.subtitle,
      ),
      backgroundColor: Colors.transparent,
      centerTitle: true,
      automaticallyImplyLeading: false,
      leading: Navigator.of(context).canPop()
          ? IconButton(
              icon: Icon(Icons.arrow_back_ios),
              onPressed: () => Navigator.of(context).pop(),
            )
          : null,
    );
  }

  Widget _buildBackground() {
    return Stack(
      children: <Widget>[
        Container(color: Colors.black),
        Consumer<PlayViewProvider>(
          builder: (context, vp, child) => CachedNetworkImage(
            imageUrl: vp.currentTrack?.track?.artUri,
            fit: BoxFit.cover,
            height: double.infinity,
            width: double.infinity,
            fadeInDuration: Duration(milliseconds: 300),
            fadeOutDuration: Duration(milliseconds: 300),
            fadeInCurve: Curves.easeInOut,
            fadeOutCurve: Curves.easeInOut,
            useOldImageOnUrlChange: true,
          ),
        ),
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(color: Colors.transparent),
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: GradientUtils.curved(
                [Colors.transparent, Colors.transparent, Colors.black],
                stops: [0.0, 0.25, 1.0],
                curve: Curves.easeOut,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
