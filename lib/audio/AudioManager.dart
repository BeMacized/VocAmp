import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:vocaloid_player/audio/CustomAudioPlayer.dart';
import 'package:vocaloid_player/audio/MediaSource.dart';
import 'package:vocaloid_player/globals.dart';
import 'package:vocaloid_player/model/QueuedSong.dart';
import 'package:vocaloid_player/redux/actions/player_actions.dart';
import 'package:vocaloid_player/utils/mediaitem_utils.dart';

class AudioManager {
  List<QueuedSong> _queueCache;
  StreamSubscription<PlaybackState> _playbackStateSubscription;
  StreamSubscription<List<MediaItem>> _queueChangedSubscription;
  StreamSubscription<MediaItem> _mediaChangedSubscription;

  AudioManager() {
    _queueCache = [];
  }

  Future<void> connect() async {
    await AudioService.connect();
    // Subscribe to playback state
    if (_playbackStateSubscription == null) {
      var cb = (PlaybackState playbackState) {
        Application.store.dispatch(PlayerStateChangeAction(
          state: playbackState.basicState,
          position: playbackState.position,
        ));
      };
      cb(AudioService.playbackState);
      _playbackStateSubscription = AudioService.playbackStateStream.listen(cb);
    }
    // Subscribe to queue changes
    if (_queueChangedSubscription == null) {
      var cb = (queue) {
        List<QueuedSong> newQueue = queue
            .map<QueuedSong>((mediaItem) =>
                Application.store.state.playerState.queue.singleWhere(
                  (song) => song.id == mediaItem.id,
                  orElse: () => _queueCache
                      .singleWhere((song) => song.id == mediaItem.id),
                ))
            .toList();
        // Remove songs from cache
        queue.forEach((mediaItem) =>
            _queueCache.removeWhere((song) => song.id == mediaItem.id));
        // Dispatch queue change action
        Application.store.dispatch(QueueChangeAction(newQueue));
      };
      _queueChangedSubscription = AudioService.queueStream.listen(cb);
    }
    // Subscribe to media changes
    if (_mediaChangedSubscription == null) {
      var cb = (mediaItem) {
        if (mediaItem == null) return;
        // Match with queued song
        QueuedSong song = Application.store.state.playerState.queue
            .singleWhere((song) => song.id == mediaItem.id, orElse: () => null);
        // If it exists, dispatch change action. If the duration is known, dispatch that too
        if (song != null) {
          Application.store.dispatch(QueueIndexChangeAction(song.index));
          Application.store
              .dispatch(DurationChangeAction(mediaItem.duration ?? 0));
        }
      };
      cb(AudioService.currentMediaItem);
      _mediaChangedSubscription =
          AudioService.currentMediaItemStream.listen(cb);
    }
    print("[AudioManager] CONNECTED");
  }

  void disconnect() async {
    if (_playbackStateSubscription != null) {
      _playbackStateSubscription.cancel();
      _playbackStateSubscription = null;
    }
    if (_queueChangedSubscription != null) {
      _queueChangedSubscription.cancel();
      _queueChangedSubscription = null;
    }
    if (_mediaChangedSubscription != null) {
      _mediaChangedSubscription.cancel();
      _mediaChangedSubscription = null;
    }
    await AudioService.disconnect();
    print("[AudioManager] DISCONNECTED");
  }

  Future<void> reorderQueueItem(String itemId, int newIndex) async {
    Application.store.dispatch(ReorderQueueItemAction(itemId, newIndex));
    await AudioService.customAction('reorderItem', [itemId, newIndex]);
  }

  Future<void> skipToNext() async {
    await AudioService.skipToNext();
  }

  Future<void> skipToPrevious() async {
    await AudioService.skipToPrevious();
  }

  Future<void> seekTo(Duration pos) async {
    await AudioService.seekTo(pos.inMilliseconds);
  }

  Future<void> playPause() async {
    await AudioService.customAction('playPause');
  }

  Future<void> play() async {
    await AudioService.play();
  }

  Future<void> setRepeatMode(RepeatMode mode) async {
    Application.store.dispatch(ChangeRepeatModeAction(mode));
    await AudioService.customAction('setRepeatMode', mode.toString());
  }

  Future<void> cycleRepeatMode() async {
    int newIndex = RepeatMode.values
            .indexOf(Application.store.state.playerState.repeatMode) +
        1;
    if (newIndex >= RepeatMode.values.length) newIndex = 0;
    setRepeatMode(RepeatMode.values[newIndex]);
  }

  Future<void> setShuffleMode(bool mode) async {
    Application.store.dispatch(SetShuffleModeAction(mode));
    await AudioService.customAction('setShuffleMode', mode);
  }

  Future<void> toggleShuffleMode() async {
    await setShuffleMode(!Application.store.state.playerState.shuffle);
  }

  Future<void> playSongNext(QueuedSong song) async {
    await playSongsNext([song]);
  }

  Future<void> playSongsNext(List<QueuedSong> songs) async {
    int index = Application.store.state.playerState.queueIndex + 1;
    while (index > Application.store.state.playerState.queue.length) index--;
    await queueSongs(songs, index: index);
  }

  Future<void> queueSong(QueuedSong song) async {
    await queueSongs([song]);
  }

  Future<void> queueSongs(List<QueuedSong> songs, {int index}) async {
    // Start background isolate if not yet started
    await _start();
    // Store all songs in cache
    _queueCache.addAll(songs);
    // Queue items
    List args = [songs.map((song) => mediaItem2raw(song.mediaItem)).toList()];
    if (index != null) args.add(index);
    await AudioService.customAction('queueItems', args);
    // Send sources
    await _addSources(
      Map<String, MediaSource>.fromIterables(
        songs.map((song) => song.id),
        songs.map((song) => song.song.mediaSource),
      ),
    );
  }

  Future<void> setQueue(List<QueuedSong> songs, int cursor) async {
    await _start();
    _queueCache.addAll(songs);
    await AudioService.customAction('setQueue',
        [songs.map((song) => mediaItem2raw(song.mediaItem)).toList(), cursor]);
    await _addSources(
      Map<String, MediaSource>.fromIterables(
        songs.map((song) => song.id),
        songs.map((song) => song.song.mediaSource),
      ),
    );
  }

  Future<void> removeSong(String songId) async {
    await removeSongs([songId]);
  }

  Future<void> removeSongs(List<String> songIds) async {
    await AudioService.customAction('removeItems', songIds);
  }

  Future<void> skipToSong(String id) async {
    await AudioService.skipToQueueItem(id);
  }

  Future<void> _addSources(Map<String, MediaSource> sources) async {
    Map<String, Map> rawSources = Map<String, Map>.fromIterables(
      sources.keys,
      sources.values.map<Map>((source) => source.toMap()),
    );
    await AudioService.customAction('addMediaSources', rawSources);
  }

  Future<void> _start() async {
    if (!(await AudioService.running)) {
      await AudioService.start(
        backgroundTask: backgroundAudioPlayerTask,
        resumeOnClick: true,
        notificationColor: 0xFFFFFFFF,
        androidNotificationIcon: 'mipmap/ic_launcher',
      );
    }
  }
}
