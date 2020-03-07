import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:voc_amp/models/media/queue-track.dart';
import 'package:voc_amp/views/queue/queue-view.provider.dart';
import 'package:voc_amp/views/queue/widgets/queue-bottom-controls.dart';
import 'package:voc_amp/widgets/track-list-item.dart';

class QueueView extends StatefulWidget {
  @override
  _QueueViewState createState() => _QueueViewState();
}

class _QueueViewState extends State<QueueView> {
  bool _popping = false;
  QueueViewProvider _viewProvider;

  @override
  void didChangeDependencies() {
    _viewProvider = Provider.of<QueueViewProvider>(context);
    _viewProvider.addListener(_onViewProviderChange);
    _onViewProviderChange();
    super.didChangeDependencies();
  }

  @override
  dispose() {
    _viewProvider.removeListener(_onViewProviderChange);
    super.dispose();
  }

  _onViewProviderChange() {
    if (_viewProvider.currentTrack == null && !_popping) {
      _popping = true;
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<QueueViewProvider>(builder: (context, vp, snapshot) {
      return Stack(
        children: <Widget>[
          Scaffold(
            backgroundColor: Colors.black,
            appBar: _buildAppBar(),
            body: Column(
              children: <Widget>[
                Expanded(
                  child: ReorderableListView(
                    onReorder: vp.reorder,
                    children:
                        vp.tracks.map((t) => _buildTrackListItem(t)).toList(),
                  ),
                ),
                QueueBottomControls(vp),
              ],
            ),
          ),
        ],
      );
    });
  }

  Widget _buildAppBar() {
    return AppBar(
      title: Text(
        'QUEUE',
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

  Widget _buildTrackListItem(QueueTrack t) {
    return TrackListItem(
      key: ValueKey(t.id),
      track: t.track,
      onTap: () {},
    );
  }
}
