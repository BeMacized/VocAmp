import 'package:dartz/dartz.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:voc_amp/models/media/queue-track.dart';
import 'package:voc_amp/models/media/track-list.dart';
import 'package:voc_amp/models/media/track.dart';
import 'package:voc_amp/models/utils/failure.dart';
import 'package:voc_amp/extensions/task.extension.dart';

import '../../providers/audio-player.provider.dart';

enum ProviderState { initial, loading, loaded }

class TrackListViewProvider extends ChangeNotifier {

  AudioPlayerProvider _audioPlayerProvider;

  TrackListViewProvider(this._audioPlayerProvider);

  // State
  ProviderState _state = ProviderState.initial;

  ProviderState get state => _state;

  void _setState(ProviderState state) {
    _state = state;
    notifyListeners();
  }

  // Tracks
  Either<Failure, List<Track>> _tracks;

  Either<Failure, List<Track>> get tracks => _tracks;

  void _setTracks(Either<Failure, List<Track>> tracks) {
    _tracks = tracks;
    notifyListeners();
  }

  // TrackList
  TrackList _trackList;

  TrackList get trackList => _trackList;

  void setTrackList(TrackList trackList) {
    _trackList = trackList;
    _state = ProviderState.initial;
    _tracks = null;
    notifyListeners();
  }

  // Utils
  void fetchTracks() async {
    _setState(ProviderState.loading);
    await Task(() => trackList.fetchTracks())
        .attempt()
        .mapLeftToFailure()
        .run()
        .then((value) => _setTracks(value));
    _setState(ProviderState.loaded);
  }

  shuffleAll(List<Track> tracks) async {
    List<QueueTrack> queueTracks = tracks
        .where((t) => t.sources.isNotEmpty)
        .map((t) => QueueTrack.fromTrack(t))
        .toList();
    // Show error if none can be played
    if (queueTracks.isEmpty) {
      return Fluttertoast.showToast(
        msg: "No tracks in this list are playable.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
    // Set the track queue
    await _audioPlayerProvider.setQueue(queueTracks, shuffled: true);
    await _audioPlayerProvider.play();
  }

  playTrack(Track track, List<Track> tracks) async {
    // Stop here if track has no source
    if (track.sources.isEmpty) return;
    // Build queue tracks
    List<QueueTrack> queueTracks = tracks
        .where((t) => t.sources.isNotEmpty)
        .map((t) => QueueTrack.fromTrack(t))
        .toList();
    // Get queue track for selected track
    QueueTrack cursor = queueTracks.singleWhere((qt) => qt.track == track);
    // Set the track queue
    await _audioPlayerProvider.setQueue(
      queueTracks,
      cursor: cursor,
    );
    await _audioPlayerProvider.play();
  }
}
