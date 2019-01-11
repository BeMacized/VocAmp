import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:vocaloid_player/audio/CustomAudioPlayer.dart';
import 'package:vocaloid_player/model/QueuedSong.dart';
import 'package:vocaloid_player/model/vocadb/vocadb_album.dart';
import 'package:flutter/foundation.dart';

class AppState {
  final AlbumState albumState;
  final PlayerState playerState;

  AppState({@required this.albumState, @required this.playerState});

  factory AppState.initial() => AppState(
        albumState: AlbumState.initial(),
        playerState: PlayerState.initial(),
      );
}

class ErrorState {
  final IconData icon;
  final String title;
  final String subtitle;

  ErrorState({this.icon, this.title, this.subtitle});
}

class AlbumState {
  final bool loading;
  final ErrorState errorState;
  final VocaDBAlbum album;

  AlbumState({
    @required this.loading,
    this.album,
    this.errorState,
  });

  factory AlbumState.initial() => AlbumState(
        loading: false,
        album: null,
        errorState: null,
      );
}

class PlayerState {
  // Player state
  final BasicPlaybackState state;
  final Duration position;
  final Duration duration;
  final RepeatMode repeatMode;
  final bool shuffle;

  // Queue
  final List<QueuedSong> queue;
  final int queueIndex;
  final List<String> selectedQueueItems;

  PlayerState({
    @required this.state,
    @required this.position,
    @required this.duration,
    @required this.queue,
    @required this.queueIndex,
    @required this.repeatMode,
    @required this.shuffle,
    @required this.selectedQueueItems,
  });

  QueuedSong get currentSong =>
      queueIndex < queue.length ? queue[queueIndex] : null;

  PlayerState copyWith({
    BasicPlaybackState state,
    Duration position,
    Duration duration,
    List<QueuedSong> queue,
    int queueIndex,
    RepeatMode repeatMode,
    bool shuffle,
    List<String> selectedQueueItems,
  }) {
    return PlayerState(
      state: state ?? this.state,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      queue: queue ?? this.queue,
      queueIndex: queueIndex ?? this.queueIndex,
      repeatMode: repeatMode ?? this.repeatMode,
      shuffle: shuffle ?? this.shuffle,
      selectedQueueItems: selectedQueueItems ?? this.selectedQueueItems,
    );
  }

  factory PlayerState.initial() => PlayerState(
        state: BasicPlaybackState.none,
        position: Duration(seconds: 0),
        duration: Duration(seconds: 0),
        queue: [],
        queueIndex: 0,
        repeatMode: RepeatMode.NONE,
        shuffle: false,
        selectedQueueItems: [],
      );
}
