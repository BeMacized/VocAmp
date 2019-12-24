import 'package:rxdart/subjects.dart';
import 'package:voc_amp/models/media/queued-track.dart';

class AudioPlayerQueue {
  bool _shuffled = false;
  List<QueuedTrack> _tracks = [];
  List<QueuedTrack> _originalQueue = [];
  Subject<void> _updated = PublishSubject<void>();
  QueuedTrack _currentTrack;

  bool get shuffled => _shuffled;

  List<QueuedTrack> get tracks => List.from(_tracks);

  Stream<void> get updated => _updated.asBroadcastStream();

  QueuedTrack get currentTrack => _currentTrack;

  void clear() {
    _tracks = [];
    _originalQueue = [];
    _currentTrack = null;
    _notifyListeners();
  }

  void set(List<QueuedTrack> tracks) {
    _tracks = List<QueuedTrack>.from(tracks);
    if (_shuffled) {
      _originalQueue = List<QueuedTrack>.from(tracks);
      _tracks.shuffle();
    }
    _currentTrack = _tracks.isEmpty ? null : _tracks[0];
    _notifyListeners();
  }

  void appendTrack(QueuedTrack track, {bool afterCursor = false}) {
    appendTracks([track], afterCursor: afterCursor);
  }

  void appendTracks(List<QueuedTrack> tracks, {bool afterCursor = false}) {
    // No duplicates! (Duplicate songs need separate QueuedTrack wrapper instances)
    if (tracks.any((qt) => _tracks.contains(qt)))
      throw "Cannot queue the same QueuedTrack instance more than once";
    // Insert into current queue
    _tracks.insertAll(
        afterCursor ? _tracks.indexOf(_currentTrack) + 1 : _tracks.length,
        tracks);
    // Add to original queue if currently shuffled
    if (shuffled) _originalQueue.addAll(tracks);
    // Set current track if needed
    if (_currentTrack == null)
      _currentTrack = _tracks.isEmpty ? null : _tracks[0];
    _notifyListeners();
  }

  void setShuffled(bool shuffled) {
    if (this._shuffled == shuffled) return;
    this._shuffled = shuffled;
    if (shuffled) {
      // Shuffle queue
      _originalQueue = List<QueuedTrack>.from(_tracks);
      _tracks.shuffle();
    } else {
      // Restore queue
      _tracks = List<QueuedTrack>.from(_originalQueue);
      _originalQueue = [];
    }
    _notifyListeners();
  }

  QueuedTrack next() {
    int index = _tracks.indexOf(_currentTrack);
    if (index < 0 || index >= _tracks.length - 1) return null;
    _currentTrack = _tracks[index + 1];
    _notifyListeners();
    return _currentTrack;
  }

  QueuedTrack previous() {
    int index = _tracks.indexOf(_currentTrack);
    if (index <= 0) return null;
    _currentTrack = _tracks[index - 1];
    _notifyListeners();
    return _currentTrack;
  }

  void _notifyListeners() {
    _updated.add(null);
  }

  void dispose() {
    _updated.close();
  }
}
