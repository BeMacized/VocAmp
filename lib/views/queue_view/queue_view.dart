import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:vocaloid_player/globals.dart';
import 'package:vocaloid_player/model/QueuedSong.dart';
import 'package:vocaloid_player/redux/app_state.dart';
import 'package:vocaloid_player/views/queue_view/queue_view_model.dart';
import 'package:vocaloid_player/widgets/player_controls.dart';
import 'package:flutter_reorderable_list/flutter_reorderable_list.dart';

class QueueView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, QueueViewModel>(
        converter: QueueViewModel.fromStore,
        builder: (BuildContext context, QueueViewModel vm) {
          return Scaffold(
            backgroundColor: Colors.black,
            appBar: AppBar(
              brightness: Brightness.dark,
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
              title: Text(
                'Queue',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              leading: Application.navigator.canPop()
                  ? IconButton(
                      icon: Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                      ),
                      onPressed: Application.navigator.pop,
                    )
                  : null,
            ),
            body: Column(
              children: <Widget>[
                new QueueBody(vm),
                new BottomControls(vm),
              ],
            ),
          );
        });
  }
}

class QueueBody extends StatelessWidget {
  final QueueViewModel vm;

  QueueBody(this.vm);

  void _reorderDone(Key item) {}

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ReorderableList(
        onReorder: vm.reorderItems,
        onReorderDone: this._reorderDone,
        child: CustomScrollView(
          slivers: <Widget>[
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  QueuedSong queuedSong = vm.playerState.queue[index];
                  bool active = vm.playerState.queueIndex == index;
                  return QueueItem(
                    queuedSong: queuedSong,
                    active: active,
                    selected: vm.playerState.selectedQueueItems
                        .contains(queuedSong.id),
                    onSelect: () => vm.selectQueueItem(queuedSong.id),
                  );
                },
                childCount: vm.playerState.queue.length,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class QueueItem extends StatelessWidget {
  final QueuedSong queuedSong;
  final bool active;
  final bool selected;
  final VoidCallback onSelect;

  QueueItem(
      {@required this.queuedSong,
      this.active = false,
      this.selected = false,
      this.onSelect});

  Widget _buildChild(BuildContext context, ReorderableItemState state) {
    bool dragging = state == ReorderableItemState.dragProxy ||
        state == ReorderableItemState.dragProxyFinished;
    bool placeholder = state == ReorderableItemState.placeholder;
    return Opacity(
      opacity: placeholder ? 0.0 : dragging ? 0.5 : 1.0,
      child: Container(
        color: Colors.black,
        child: Material(
          color: Colors.transparent,
          child: ListTile(
            title: Text(
              queuedSong.song.name,
              style: TextStyle(
                color: active ? Theme.of(context).primaryColor : Colors.white,
              ),
              softWrap: false,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              queuedSong.song.artistString,
              softWrap: false,
              overflow: TextOverflow.ellipsis,
            ),
            leading: IconButton(
              icon: Icon(
                selected ? Icons.check_circle : Icons.radio_button_unchecked,
                color: selected ? Theme.of(context).primaryColor : Colors.white,
              ),
              onPressed: onSelect,
            ),
            trailing: ReorderableListener(
              child: Icon(
                Icons.reorder,
                color: Color(0xFF888888),
              ),
            ),
            onTap: () async {
              await Application.audioManager.skipToSong(queuedSong.id);
              await Application.audioManager.play();
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ReorderableItem(
        key: ValueKey<String>(queuedSong.id), //
        childBuilder: _buildChild);
  }
}

class BottomControls extends StatelessWidget {
  final QueueViewModel vm;

  const BottomControls(
    this.vm, {
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double progressValue = 0;
    if (vm.playerState.state == BasicPlaybackState.buffering) {
      progressValue = null;
    } else if (vm.playerState.duration.inMilliseconds > 0) {
      progressValue = vm.playerState.position.inMilliseconds /
          vm.playerState.duration.inMilliseconds;
    }
    bool showManipulationControls =
        vm.playerState.selectedQueueItems.length > 0;

    return Column(
      children: <Widget>[
        SizedBox(
          width: double.infinity,
          height: 2,
          child: LinearProgressIndicator(
            value: progressValue,
            backgroundColor: Colors.grey.shade800,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
        AnimatedCrossFade(
          secondChild:
              Container(height: 110, child: PlayerControls(vm.playerState)),
          firstChild: Container(
              height: 110,
              child:
                  ManipulationControls(vm, enabled: showManipulationControls)),
          duration: Duration(milliseconds: 300),
          firstCurve: Curves.ease,
          secondCurve: Curves.ease,
          crossFadeState: showManipulationControls
              ? CrossFadeState.showFirst
              : CrossFadeState.showSecond,
        ),
      ],
    );
  }
}

class ManipulationControls extends StatelessWidget {
  final QueueViewModel vm;
  final bool enabled;

  ManipulationControls(this.vm, {this.enabled});

  _buildButton({
    @required IconData icon,
    @required String text,
    @required VoidCallback onPressed,
  }) =>
      Expanded(
        child: FlatButton(
          onPressed: onPressed,
          disabledTextColor: Colors.white,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Icon(icon),
              Center(child: Text(text)),
            ],
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        _buildButton(
          icon: Icons.remove,
          text: 'Remove',
          onPressed: enabled ? () => vm.removeSelected(context) : null,
        ),
        _buildButton(
          icon: Icons.add,
          text: 'Add to Queue',
          onPressed: enabled ? () => vm.queueSelected(context) : null,
        ),
        _buildButton(
          icon: Icons.arrow_forward,
          text: 'Play Next',
          onPressed: enabled ? () => vm.playSelectedNext(context) : null,
        ),
      ],
    );
  }
}
