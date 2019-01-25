import 'dart:async';
import 'dart:isolate';
import 'dart:ui';

import 'package:audio_service/audio_service.dart';
import 'package:audioplayer/audioplayer.dart';
import 'package:yt_audiostream/yt_audiostream.dart';
import 'package:vocaloid_player/audio/MediaSource.dart';
import 'package:vocaloid_player/utils/mediaitem_utils.dart';
import 'package:stream_transform/stream_transform.dart';

const String BG_AUDIO_ERROR_PORT = "BG_AUDIO_ERROR_PORT";

enum RepeatMode { NONE, ALL, SINGLE }

class SongCache {
  final String mediaId;
  final String playUrl;

  SongCache(this.mediaId, this.playUrl);
}

class CustomAudioPlayer {
  RepeatMode _repeatMode = RepeatMode.NONE;
  AudioPlayer _audioPlayer = AudioPlayer();
  Completer _completer = Completer();
  List<MediaItem> _queue = [];
  List<MediaItem> _queueBackup = [];
  bool _shuffle = false;
  int _cursor = 0;
  Map<String, MediaSource> _sourceMap = {};
  SongCache _songCache;
  Duration _position = Duration(seconds: 0);
  BasicPlaybackState _basicState = BasicPlaybackState.paused;
  SendPort errorPort;

  Future<void> start() async {
    print("[CustomAudioPlayer] RUNNING");
    // Lookup error port
    errorPort = IsolateNameServer.lookupPortByName(BG_AUDIO_ERROR_PORT);
    // initialize audio service default state
    this._setState();
    // Listen for audio position changes
    StreamSubscription<Duration> positionSubscription = _audioPlayer.onAudioPositionChanged.transform(throttle(Duration(seconds: 1)))
        .listen((position) => _setState(position: position));
    // Listen for audio player changes
    StreamSubscription<AudioPlayerState> audioPlayerStateSubscription =
        _audioPlayer.onPlayerStateChanged.listen(_onPlayerStateChange);
    // Await completer to block task ending
    await _completer.future;
    // Clean up subscriptions before task end
    positionSubscription.cancel();
    audioPlayerStateSubscription.cancel();
  }

  Future<void> addQueueItem(MediaItem item) async {
    await addQueueItems([item]);
  }

  Future<void> addQueueItemAt(MediaItem item, int index) async {
    await addQueueItems([item], index: index);
  }

  Future<void> addQueueItems(List<MediaItem> items, {int index}) async {
    // If no index provided, append
    if (index == null) index = _queue.length;
    // Verify index
    if (index < 0 || index > _queue.length) {
      throw Exception("Provided insertion index out of bounds");
    }
    // Insert items
    _queue.insertAll(index, items);
    if (_shuffle) _queueBackup.addAll(items);
    // Fix cursor
    if (index <= _cursor) {
      _cursor += items.length;
      if (_cursor >= _queue.length) _cursor = 0;
    }
    // Notify clients
    await AudioServiceBackground.setQueue(_queue);
    await AudioServiceBackground.setMediaItem(_queue[_cursor]);
  }

  Future<void> setQueueItems(List<MediaItem> items, int cursor) async {
    // Stop player as we're clearing the current queue
    await _audioPlayer.stop();
    // Clear queue
    _queue.clear();
    // Add all items
    _queue.addAll(items);
    // Set the cursor
    this._cursor = cursor;
    // If we're shuffling, assume new list as unshuffled
    if (_shuffle) {
      // Backup unshuffled queue
      _queueBackup = List.from(_queue);
      if (_queue.length > 0) {
        // Obtain current item for cursor fix
        MediaItem cursorItem = items[cursor];
        // Shuffle new queue
        _queue.shuffle();
        // Fix cursor
        this._cursor = _queue.indexOf(cursorItem);
      }
    }
    // Notify clients
    await AudioServiceBackground.setQueue(_queue);
    await AudioServiceBackground.setMediaItem(_queue[cursor]);
  }

  Future<void> skipToQueueItem(String mediaId) async {
    await _audioPlayer.stop();
    int index = _queue.indexWhere((item) => item.id == mediaId);
    if (index < 0) {
      throw Exception("Tried to skip to non-existent mediaId");
    }
    _cursor = index;
    await AudioServiceBackground.setMediaItem(_queue[_cursor]);
  }

  Future<void> playPause() async {
    if (_audioPlayer.state == AudioPlayerState.PLAYING)
      pause();
    else
      play();
  }

  Future<void> play() async {
    if (_cursor < _queue.length) {
      _setState(basicState: BasicPlaybackState.playing);
      MediaItem item = _queue[_cursor];
      String streamUrl = _songCache?.playUrl;
      if (streamUrl == null || _songCache.mediaId != item.id) {
        try {
          streamUrl = await _getUrlForMedia(_queue[_cursor]);
        } catch (e) {
          // Is already being sent over error port in _getUrlForMedia method
          return;
        }
        _songCache = SongCache(item.id, streamUrl);
      }
      // If by this point we are not playing the current item anymore, don't start anyways
      if (this._basicState != BasicPlaybackState.playing ||
          _queue[_cursor].id != item.id) return;
      // Start playing audio
      AudioServiceBackground.androidForceEnableMediaButtons();
      await _audioPlayer.play(streamUrl);
    }
  }

  Future<void> pause() async {
    _setState(basicState: BasicPlaybackState.paused);
    _audioPlayer.pause();
  }

  Future<void> stop() async {
    _audioPlayer.stop();
    await _setState(
      basicState: BasicPlaybackState.stopped,
      position: Duration(seconds: 0),
    );
    _completer.complete();
  }

  Future<void> onClick(MediaButton btn) async {
    switch (btn) {
      case MediaButton.media:
        playPause();
        break;
      case MediaButton.next:
        skipNext();
        break;
      case MediaButton.previous:
        skipPrevious();
        break;
    }
  }

  Future<void> skipPrevious() async {
    // Reset to start of song
    if (_position.inMilliseconds >= 2000 ||
        (_repeatMode != RepeatMode.ALL && _cursor == 0)) {
      await _audioPlayer.seek(0);
      play();
    }
    // Go to previous
    else {
      _cursor--;
      if (_cursor < 0)
        _cursor = _repeatMode == RepeatMode.ALL ? _queue.length - 1 : 0;
      AudioServiceBackground.setMediaItem(_queue[_cursor]);
      _audioPlayer.stop();
      play();
    }
  }

  Future<void> skipNext() async {
    _cursor++;
    if (_cursor >= _queue.length) _cursor = 0;
    AudioServiceBackground.setMediaItem(_queue[_cursor]);
    await _audioPlayer.stop();
    if (_cursor > 0 || _repeatMode == RepeatMode.ALL) play();
  }

  Future<void> seekTo(int pos) async {
    if ((_audioPlayer.state == AudioPlayerState.PLAYING ||
            _audioPlayer.state == AudioPlayerState.PAUSED) &&
        _audioPlayer.duration.inMilliseconds > 0 &&
        pos <= _audioPlayer.duration.inMilliseconds) {
      await _audioPlayer.seek(pos / 1000);
    }
  }

  setShuffleMode(bool mode) {
    if (mode == _shuffle) return;
    // Apply queue changes
    if (mode) {
      // backup current queue
      _queueBackup = List.from(_queue);
      if (_queue.length > 0) {
        // Get current item id
        MediaItem currentItem = _queue[_cursor];
        // Shuffle current queue
        _queue.shuffle();
        // Fix cursor
        _cursor = _queue.indexOf(currentItem);
      }
    } else {
      MediaItem currentItem = _queue.length > 0 ? _queue[_cursor] : null;
      // Restore backup queue
      _queue = List.from(_queueBackup);
      // Fix cursor
      if (currentItem != null) _cursor = _queue.indexOf(currentItem);
      // Clear backup queue
      _queueBackup.clear();
    }
    // Update clients
    AudioServiceBackground.setQueue(_queue);
    if (_cursor < _queue.length)
      AudioServiceBackground.setMediaItem(_queue[_cursor]);
    // Set shuffle mode
    _shuffle = mode;
  }

  _onPlayerStateChange(AudioPlayerState state) {
    switch (state) {
      case AudioPlayerState.PLAYING:
        if (_queue[_cursor].duration == null) {
          _queue[_cursor] = copyMediaItem(
            _queue[_cursor],
            duration: _audioPlayer.duration.inMilliseconds,
          );
          AudioServiceBackground.setMediaItem(_queue[_cursor]);
        }

        _setState(
          basicState: BasicPlaybackState.playing,
        );
        break;
      case AudioPlayerState.COMPLETED:
        _setState(
            position: Duration(seconds: 0),
            basicState: BasicPlaybackState.stopped);
        if (_repeatMode == RepeatMode.SINGLE) {
          play();
        } else {
          skipNext();
        }
        break;
      case AudioPlayerState.LOADING:
        _setState(basicState: BasicPlaybackState.buffering);
        break;
      case AudioPlayerState.STOPPED:
        _setState(
          basicState: BasicPlaybackState.stopped,
        );
        break;
      case AudioPlayerState.PAUSED:
        _setState(
          basicState: BasicPlaybackState.paused,
        );
        break;
    }
  }

  Future<void> _setState(
      {Duration position, BasicPlaybackState basicState}) async {
    // Don't do unnecessary updates
    if (basicState != null && position == null && this._basicState == basicState) return;
    // set position & state
    this._position = position ?? this._position;
    this._basicState = basicState ?? this._basicState;
    // Determine controls
    List<MediaControl> controls;
    switch (this._basicState) {
      case BasicPlaybackState.buffering:
      case BasicPlaybackState.playing:
        controls = [previousControl, pauseControl, nextControl];
        break;
      case BasicPlaybackState.paused:
        controls = [previousControl, playControl, nextControl];
        break;
      case BasicPlaybackState.stopped:
      default:
        controls = [];
    }
    // Report state to clients
    await AudioServiceBackground.setState(
        controls: controls,
        basicState: basicState ?? this._basicState,
        position: this._position.inMilliseconds,
        updateTime: position != null ? DateTime.now().millisecondsSinceEpoch : null
    );
  }

  Future<String> _getUrlForMedia(MediaItem item) async {
    if (!_sourceMap.containsKey(item.id)) {
      Exception e = Exception(
          "No source was provided for media item '" + item.title + "'");
      errorPort.send(e);
      throw e;
    }
    MediaSource source = _sourceMap[item.id];
    switch (source.type) {
      case MediaSourceType.YouTube:
        {
          try {
            return await YTAudioStream.getAudioStream(source.url);
          } on YTStreamError catch (e) {
            errorPort.send(e.toMap());
            return Future.error(e);
          } catch (e) {
            errorPort.send({'code': 'Unknown Error', 'str': e.toString()});
            return Future.error(e);
          }
          break;
        }
      default:
        {
          Exception e = Exception("Source type '" +
              source.type.toString() +
              "' not yet implemented");
          errorPort.send(e);
          throw e;
        }
    }
  }

  Future<void> customAction(String function, dynamic args) async {
    switch (function) {
      case 'queueItems':
        await addQueueItems(
            List<Map>.from(args[0]).map<MediaItem>(raw2mediaItem).toList(),
            index: args.length > 1 ? args[1] as int : null);
        break;

      case 'setQueue':
        await setQueueItems(
            List<Map>.from(args[0]).map<MediaItem>(raw2mediaItem).toList(),
            args[1] as int);
        break;

      case 'removeItems':
        String currentId = _queue[_cursor].id;
        _queue.removeWhere((item) => List<String>.from(args).contains(item.id));
        _queueBackup
            .removeWhere((item) => List<String>.from(args).contains(item.id));
        if (_queue.length == 0) {
          stop();
          return;
        }
        _cursor = _queue.indexWhere((item) => item.id == currentId);
        if (_cursor == -1) {
          _cursor = 0;
          _audioPlayer.stop();
        }
        AudioServiceBackground.setQueue(_queue);
        AudioServiceBackground.setMediaItem(_queue[_cursor]);
        break;

      case 'playPause':
        playPause();
        break;

      case 'setRepeatMode':
        _repeatMode = RepeatMode.values.singleWhere(
            (mode) => mode.toString() == (args as String),
            orElse: () => RepeatMode.NONE);
        break;

      case 'setShuffleMode':
        setShuffleMode(args as bool);
        break;

      case 'reorderItem':
        int oldIndex =
            _queue.indexWhere((item) => item.id == (args[0] as String));
        int newIndex = args[1] as int;
        MediaItem item = _queue[oldIndex];
        _queue.removeAt(oldIndex);
        _queue.insert(newIndex, item);
        if (oldIndex == _cursor)
          _cursor = newIndex;
        else if ((oldIndex > _cursor && newIndex <= _cursor))
          _cursor++;
        else if (oldIndex < _cursor && newIndex >= _cursor) _cursor--;
        AudioServiceBackground.setQueue(_queue);
        AudioServiceBackground.setMediaItem(_queue[_cursor]);
        break;

      case 'addMediaSources':
        Map<String, Map> rawSources = Map<String, Map>.from(args);
        _sourceMap.addAll(
          Map<String, MediaSource>.fromIterables(
            rawSources.keys,
            rawSources.values.map<MediaSource>(
                (rawSource) => MediaSource.fromMap(rawSource)),
          ),
        );
        break;
    }
  }
}

MediaControl playControl = MediaControl(
  androidIcon: 'drawable/ic_play_arrow',
  label: 'Play',
  action: MediaAction.play,
);
MediaControl pauseControl = MediaControl(
  androidIcon: 'drawable/ic_pause',
  label: 'Pause',
  action: MediaAction.pause,
);
MediaControl previousControl = MediaControl(
  androidIcon: 'drawable/ic_skip_previous',
  label: 'Previous',
  action: MediaAction.skipToPrevious,
);
MediaControl nextControl = MediaControl(
  androidIcon: 'drawable/ic_skip_next',
  label: 'Next',
  action: MediaAction.skipToNext,
);

void backgroundAudioPlayerTask() async {
  print("[AudioManager] RUNNING BACKGROUND TASK");
  CustomAudioPlayer audioPlayer = CustomAudioPlayer();
  AudioServiceBackground.run(
    onStart: audioPlayer.start,
    onPlay: audioPlayer.play,
    onPause: audioPlayer.pause,
    onStop: audioPlayer.stop,
    onSeekTo: audioPlayer.seekTo,
    onCustomAction: audioPlayer.customAction,
    onAddQueueItem: audioPlayer.addQueueItem,
    onAddQueueItemAt: audioPlayer.addQueueItemAt,
    onSkipToQueueItem: audioPlayer.skipToQueueItem,
    onSkipToNext: audioPlayer.skipNext,
    onSkipToPrevious: audioPlayer.skipPrevious,
    onClick: audioPlayer.onClick,
  );
}
