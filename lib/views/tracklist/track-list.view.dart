import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:voc_amp/models/media/track-list.dart';
import 'package:voc_amp/views/tracklist/widgets/track-list-header.dart';

enum LoadStatus { loading, loaded, error }

class TrackListView extends StatefulWidget {
  final TrackList trackList;

  TrackListView({@required this.trackList});

  @override
  _TrackListViewState createState() => _TrackListViewState();
}

class _TrackListViewState extends State<TrackListView> {
  LoadStatus status = LoadStatus.loading;

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
      child: CustomScrollView(
        slivers: [
          TrackListHeader(trackList: widget.trackList),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  for (int i = 0; i < 20; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Container(
                        height: 100,
                        color: Colors.amber,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
