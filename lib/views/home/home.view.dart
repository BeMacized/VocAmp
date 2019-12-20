import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:voc_amp/models/media/track-list.dart';
import 'package:voc_amp/providers/track-list.provider.dart';
import 'package:voc_amp/utils/gradient-utils.dart';
import 'package:voc_amp/views/tracklist/track-list.view.dart';
import 'package:voc_amp/widgets/pressable.dart';
import 'package:voc_amp/widgets/tile-row.dart';
import 'package:voc_amp/widgets/tile.dart';

class HomeView extends StatefulWidget {
  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.black,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _buildMainArea(),
            //TODO: PLAY BAR
            //TODO: TAB BAR
          ],
        ),
      ),
    );
  }

  Widget _buildMainArea() {
    return Expanded(
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Positioned.fill(
            child: _buildBackgroundGradient(),
          ),
          Positioned.fill(
            child: SingleChildScrollView(
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 20, right: 20, top: 40, bottom: 20),
                      child: Text(
                        'Popular Tracks',
                        style: Theme.of(context).textTheme.headline,
                      ),
                    ),
                    _buildTopTracksRow(),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 20, right: 20, top: 40, bottom: 20),
                      child: Text(
                        'New Tracks',
                        style: Theme.of(context).textTheme.headline,
                      ),
                    ),
                    _buildNewTracksRow(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopTracksRow() {
    TrackListProvider trackLists = Provider.of<TrackListProvider>(context);
    return TileRow(
      children: <Widget>[
        _buildTracksListTile(trackLists.tracksTopOverall),
        _buildTracksListTile(trackLists.tracksTopYearly),
        _buildTracksListTile(trackLists.tracksTopMonthly),
        _buildTracksListTile(trackLists.tracksTopWeekly),
        _buildTracksListTile(trackLists.tracksTopDaily),
      ],
    );
  }

  Widget _buildNewTracksRow() {
    TrackListProvider trackLists = Provider.of<TrackListProvider>(context);
    return TileRow(
      children: <Widget>[
        _buildTracksListTile(trackLists.tracksNewReleases),
        _buildTracksListTile(trackLists.tracksNewlyAdded),
      ],
    );
  }

  Widget _buildTracksListTile(TrackList trackList) {
    return Pressable(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (BuildContext context) {
              return TrackListView(trackList: trackList);
            },
          ),
        );
      },
      child: Tile(
        art: trackList.image.buildWidget(),
        title: trackList.title,
        subtitle: trackList.subtitle,
      ),
    );
  }

  Widget _buildBackgroundGradient() {
    Color color = Color.lerp(Colors.lightBlue, Colors.white, .8);
    color = Colors.tealAccent;
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(-1, -1.25),
          radius: 1.25,
          colors: GradientUtils.curved(
            [
              color.withOpacity(.4),
              color.withOpacity(0),
            ],
            curve: Curves.easeInOut,
          ),
        ),
      ),
    );
  }
}
