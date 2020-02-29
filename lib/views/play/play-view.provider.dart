import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:voc_amp/models/media/queue-track.dart';
import 'package:voc_amp/providers/audio-player.provider.dart';

class PlayViewProvider extends ChangeNotifier {
  AudioPlayerProvider _audioPlayerProvider;
  Subject _destroy$ = PublishSubject();

  PlayViewProvider(this._audioPlayerProvider) {
    _audioPlayerProvider.currentTrack
        .takeUntil(_destroy$)
        .listen((currentTrack) => _setCurrentTrack(currentTrack));
    _audioPlayerProvider.tracks
        .takeUntil(_destroy$)
        .listen((tracks) => _setTracks(tracks));
  }

  @override
  void dispose() {
    _destroy$.add(null);
    _destroy$.close();
    super.dispose();
  }

  // Current Track
  QueueTrack _currentTrack;

  QueueTrack get currentTrack => _currentTrack;

  void _setCurrentTrack(QueueTrack currentTrack) {
    _currentTrack = currentTrack;
    notifyListeners();
  }

  // Current Track
  List<QueueTrack> _tracks;

  List<QueueTrack> get tracks => _tracks;

  void _setTracks(List<QueueTrack> tracks) {
    _tracks = tracks;
    notifyListeners();
  }

  // Has Next
  bool get hasNext => queueIndex < (tracks?.length ?? 0) - 1;

  // Has Previous
  bool get hasPrevious => queueIndex > 0;

  int get queueIndex =>
      (tracks?.indexOf(currentTrack) ?? 0).clamp(0, tracks?.length ?? 0);

  // Utils
  skipNext() {
    if (hasNext) this._audioPlayerProvider.skipNext();
  }

  skipPrevious() {
    if (hasPrevious) this._audioPlayerProvider.skipPrevious();
  }

  skipToIndex(int index) {
    if (index >= _tracks.length || index < 0) return;
    this._audioPlayerProvider.skipToTrack(_tracks[index]);
  }
}
