import 'package:dartz/dartz.dart';
import 'package:flutter/cupertino.dart';
import 'package:voc_amp/models/media/track-list.dart';
import 'package:voc_amp/models/media/track.dart';
import 'package:voc_amp/models/utils/failure.dart';
import 'package:voc_amp/extensions/task.extension.dart';

enum ProviderState { initial, loading, loaded }

class TrackListViewProvider extends ChangeNotifier {
  TrackListViewProvider();

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
}
