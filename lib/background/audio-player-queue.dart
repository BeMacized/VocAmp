import 'package:rxdart/rxdart.dart';
import 'package:voc_amp/models/media/queue-track.dart';
import 'package:voc_amp/utils/logger.dart';

class AudioPlayerQueue {
  bool _shuffled = false;
  List<QueueTrack> _tracks = [];
  List<QueueTrack> _originalQueue = [];
  QueueTrack _currentTrack;
  Subject<void> _updated = PublishSubject<void>();

  bool get shuffled => _shuffled;

  List<QueueTrack> get tracks => List.from(_tracks);

  Stream<void> get updated => _updated.asBroadcastStream();

  QueueTrack get currentTrack => _currentTrack;

  Logger _log = Logger('AudioPlayerQueue');

  void clear() {
    _log.debug('clear()');
    _tracks = [];
    _originalQueue = [];
    _currentTrack = null;
    _notifyListeners();
  }

  void setTracks(List<QueueTrack> tracks) {
    _log.debug('setTracks()');
    _tracks = List<QueueTrack>.from(tracks);
    if (_shuffled) {
      _originalQueue = List<QueueTrack>.from(tracks);
      _tracks.shuffle();
    }
    _currentTrack = _tracks.isEmpty ? null : _tracks[0];
    _notifyListeners();
  }

  void appendTrack(QueueTrack track, {bool afterCursor = false}) {
    _log.debug('appendTrack()');
    appendTracks([track], afterCursor: afterCursor);
  }

  void appendTracks(List<QueueTrack> tracks, {bool afterCursor = false}) {
    _log.debug('appendTracks()');
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
    _log.debug('setShuffled()');
    if (this._shuffled == shuffled) return;
    this._shuffled = shuffled;
    if (shuffled) {
      // Shuffle queue
      _originalQueue = List<QueueTrack>.from(_tracks);
      _tracks.shuffle();
    } else {
      // Restore queue
      _tracks = List<QueueTrack>.from(_originalQueue);
      _originalQueue = [];
    }
    _notifyListeners();
  }

  QueueTrack setCursor(QueueTrack cursor) {
    _log.debug('setCursor()');
    int index = _tracks.indexOf(cursor);
    if (index < 0) return null;
    _currentTrack = _tracks[index];
    _notifyListeners();
    return _currentTrack;
  }

  bool hasPrevious() => _tracks.indexOf(_currentTrack) > 0;

  bool hasNext() {
    int index = _tracks.indexOf(_currentTrack);
    return index >= 0 && index < _tracks.length - 1;
  }

  QueueTrack next() {
    _log.debug('next()');
    int index = _tracks.indexOf(_currentTrack);
    if (index < 0 || index >= _tracks.length - 1) return null;
    _currentTrack = _tracks[index + 1];
    _notifyListeners();
    return _currentTrack;
  }

  QueueTrack previous() {
    _log.debug('previous()');
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
