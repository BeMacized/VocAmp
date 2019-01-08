import 'package:redux/redux.dart';
import 'package:vocaloid_player/model/QueuedSong.dart';
import 'package:vocaloid_player/redux/actions.dart';
import 'package:vocaloid_player/redux/app_state.dart';

Reducer<PlayerState> playerStateReducer = combineReducers<PlayerState>([
  TypedReducer<PlayerState, PlayerStateChangeAction>(playerStateChangeReducer),
  TypedReducer<PlayerState, QueueChangeAction>(queueChangeReducer),
  TypedReducer<PlayerState, QueueIndexChangeAction>(queueIndexChangeReducer),
  TypedReducer<PlayerState, DurationChangeAction>(durationChangeReducer),
  TypedReducer<PlayerState, ChangeRepeatModeAction>(changeRepeatModeReducer),
  TypedReducer<PlayerState, SetShuffleModeAction>(setShuffleModeReducer),
  TypedReducer<PlayerState, ReorderQueueItemAction>(reorderQueueItemReducer),
  TypedReducer<PlayerState, SetSelectedQueueItemsAction>(
      setSelectedQueueItemsReducer),
]);

PlayerState playerStateChangeReducer(
    PlayerState state, PlayerStateChangeAction action) {
  return state.copyWith(
    state: action.state,
    position: Duration(milliseconds: action.position),
  );
}

PlayerState queueChangeReducer(PlayerState state, QueueChangeAction action) {
  return state.copyWith(
    queue: List.from(action.queue),
  );
}

PlayerState queueIndexChangeReducer(
    PlayerState state, QueueIndexChangeAction action) {
  return state.copyWith(queueIndex: action.queueIndex);
}

PlayerState durationChangeReducer(
    PlayerState state, DurationChangeAction action) {
  return state.copyWith(
    duration: Duration(milliseconds: action.duration),
  );
}

PlayerState changeRepeatModeReducer(
    PlayerState state, ChangeRepeatModeAction action) {
  return state.copyWith(repeatMode: action.mode);
}

PlayerState setShuffleModeReducer(
    PlayerState state, SetShuffleModeAction action) {
  return state.copyWith(shuffle: action.mode);
}

PlayerState reorderQueueItemReducer(
    PlayerState state, ReorderQueueItemAction action) {
  List<QueuedSong> queue = List<QueuedSong>.from(state.queue);
  QueuedSong song = queue.singleWhere((song) => song.id == action.itemId);
  queue.remove(song);
  queue.insert(action.newIndex, song);
  return state.copyWith(queue: queue);
}

PlayerState setSelectedQueueItemsReducer(
    PlayerState state, SetSelectedQueueItemsAction action) {
  return state.copyWith(selectedQueueItems: action.selectedQueueItems);
}
