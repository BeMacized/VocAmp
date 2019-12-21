import 'package:voc_amp/models/media/track-list-image.dart';
import 'package:voc_amp/models/media/track.dart';

typedef Future<List<Track>> TrackFetcher();

class TrackList {
  String title;
  String subtitle;
  TrackListImage image;
  TrackFetcher fetchTracks;

  TrackList({
    this.title,
    this.subtitle,
    this.image,
    this.fetchTracks,
  });
}
