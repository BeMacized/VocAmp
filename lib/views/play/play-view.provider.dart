import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:voc_amp/models/audio/repeat-mode.dart';
import 'package:voc_amp/models/media/queue-track.dart';
import 'package:voc_amp/providers/audio-player.provider.dart';

class PlayViewProvider extends ChangeNotifier {
  AudioPlayerProvider _audioPlayerProvider;
  Subject _destroy$ = PublishSubject();

  PlayViewProvider(this._audioPlayerProvider) {
    // Current Track
    _audioPlayerProvider.currentTrack
        .takeUntil(_destroy$)
        .listen((currentTrack) => _setCurrentTrack(currentTrack));
    // Queue Tracks
    _audioPlayerProvider.tracks
        .takeUntil(_destroy$)
        .listen((tracks) => _setTracks(tracks));
    // Basic Playback State
    _audioPlayerProvider.playbackState
        .takeUntil(_destroy$)
        .where((state) => state.basicState != basicPlaybackState)
        .listen((state) => _setBasicPlaybackState(state.basicState));
    // Position
    _audioPlayerProvider.playbackState.takeUntil(_destroy$).listen((state) =>
        _setPosition(Duration(milliseconds: state.currentPosition),
            DateTime.fromMillisecondsSinceEpoch(state.updateTime)));
    // Shuffled
    _audioPlayerProvider.shuffled
        .takeUntil(_destroy$)
        .listen((shuffled) => _setShuffled(shuffled));
    // Repeat Mode
    _audioPlayerProvider.repeatMode
        .takeUntil(_destroy$)
        .listen((mode) => _setRepeatMode(mode));
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
    print('CURRENT INDEX: $queueIndex');
    notifyListeners();
  }

  // Current Track
  List<QueueTrack> _tracks;

  List<QueueTrack> get tracks => _tracks;

  void _setTracks(List<QueueTrack> tracks) {
    _tracks = tracks;
    notifyListeners();
  }

  // Basic Playback State
  BasicPlaybackState _basicPlaybackState;

  BasicPlaybackState get basicPlaybackState => _basicPlaybackState;

  void _setBasicPlaybackState(BasicPlaybackState playbackState) {
    _basicPlaybackState = playbackState;
    notifyListeners();
  }

  // Position
  Duration _position;

  Duration get position {
    int position = _position?.inMilliseconds ?? 0;
    if (playing && _currentTrack != null && positionLastUpdated != null) {
      position += DateTime.now().millisecondsSinceEpoch -
          positionLastUpdated.millisecondsSinceEpoch;
      position = position.clamp(
        0,
        _currentTrack.getDuration().inMilliseconds,
      );
    }
    return Duration(milliseconds: position);
  }

  // Position last updated
  DateTime _positionLastUpdated;

  DateTime get positionLastUpdated => _positionLastUpdated;

  void _setPosition(Duration position, DateTime updateTime) {
    _position = position;
    _positionLastUpdated = updateTime;
    notifyListeners();
  }

  // Shuffled
  bool _shuffled;

  bool get shuffled => _shuffled;

  void _setShuffled(bool shuffled) {
    _shuffled = shuffled;
    notifyListeners();
  }

  // Repeat
  RepeatMode _repeatMode;

  RepeatMode get repeatMode => _repeatMode;

  void _setRepeatMode(RepeatMode mode) {
    _repeatMode = mode;
    notifyListeners();
  }

  // Playing
  bool get playing => _basicPlaybackState == BasicPlaybackState.playing;

  // Paused
  bool get paused => _basicPlaybackState == BasicPlaybackState.paused;

  // Stopped
  bool get stopped => _basicPlaybackState == BasicPlaybackState.stopped;

  // Has Next
  bool get hasNext => queueIndex < (tracks?.length ?? 0) - 1;

  // Has Previous
  bool get hasPrevious => queueIndex > 0;

  // Queue Index
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

  pause() {
    if (!playing || currentTrack == null) return;
    _audioPlayerProvider.pause();
  }

  play() {
    if ((!paused && !stopped) || currentTrack == null) return;
    _audioPlayerProvider.play();
  }

  shuffle(bool value) {
    if (currentTrack == null) return;
    _audioPlayerProvider.shuffle(value);
  }

  repeat(RepeatMode mode) {
    _audioPlayerProvider.repeat(mode);
  }

  Future<void> seek(Duration position) async {
    if (!playing && !paused) return;
    await _audioPlayerProvider.seek(position);
  }
}
