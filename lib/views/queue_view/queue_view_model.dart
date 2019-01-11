import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:redux/redux.dart';
import 'package:vocaloid_player/globals.dart';
import 'package:vocaloid_player/model/QueuedSong.dart';
import 'package:vocaloid_player/redux/actions/player_actions.dart';
import 'package:vocaloid_player/redux/app_state.dart';
import 'package:vocaloid_player/widgets/center_toast.dart';

class QueueViewModel {
  PlayerState playerState;

  QueueViewModel({
    this.playerState,
  });

  static QueueViewModel fromStore(Store<AppState> store) {
    return QueueViewModel(
      playerState: store.state.playerState,
    );
  }

  void selectQueueItem(String id) {
    List<String> newItems = List<String>.from(playerState.selectedQueueItems);
    if (newItems.contains(id)) {
      newItems.remove(id);
    } else {
      newItems.add(id);
    }
    Application.store.dispatch(SetSelectedQueueItemsAction(newItems));
  }

  Future<void> playSelectedNext(BuildContext context) async {
    // Play items next
    Application.audioManager
        .playSongsNext(playerState.selectedQueueItems.map<QueuedSong>((id) {
      return playerState.queue
          .singleWhere((queuedSong) => queuedSong.id == id)
          .clone();
    }).toList());
    // Show toast
    CenterToast.showToast(context,
        icon: Icons.queue,
        text: playerState.selectedQueueItems.length > 1
            ? 'Songs play next'
            : 'Song plays next');
    // Clear selection
    Application.store.dispatch(SetSelectedQueueItemsAction([]));
  }

  Future<void> queueSelected(BuildContext context) async {
    // Queue items
    Application.audioManager
        .queueSongs(playerState.selectedQueueItems.map<QueuedSong>((id) {
      return playerState.queue
          .singleWhere((queuedSong) => queuedSong.id == id)
          .clone();
    }).toList());
    // Show toast
    CenterToast.showToast(context,
        icon: Icons.queue,
        text: playerState.selectedQueueItems.length > 1
            ? 'Songs queued'
            : 'Song queued');
    // Clear selection
    Application.store.dispatch(SetSelectedQueueItemsAction([]));
  }

  Future<void> removeSelected(BuildContext context) async {
    // Remove items
    Application.audioManager.removeSongs(playerState.selectedQueueItems);
    // Show toast
    CenterToast.showToast(context,
        icon: Icons.queue,
        text: playerState.selectedQueueItems.length > 1
            ? 'Songs removed'
            : 'Song removed');
    // Clear selection
    Application.store.dispatch(SetSelectedQueueItemsAction([]));
  }

  bool reorderItems(Key item, Key newPosition) {
    QueuedSong draggingItem = playerState.queue
        .singleWhere((e) => e.id == (item as ValueKey<String>).value);
    int newIndex = playerState.queue
        .singleWhere((e) => e.id == (newPosition as ValueKey<String>).value)
        .index;
    Application.audioManager.reorderQueueItem(draggingItem.id, newIndex);
    return true;
  }
}
