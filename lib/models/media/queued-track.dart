import 'package:audio_service/audio_service.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:voc_amp/models/media/track.dart';
import 'package:uuid/uuid.dart';

part 'queued-track.g.dart';

@JsonSerializable()
class QueuedTrack {
  String id;
  Track track;

  QueuedTrack() {
    id = Uuid().v4();
  }

  MediaItem buildMediaItem() {
    return MediaItem(
      // required
      id: id,
      album: track.album?.albumName ?? 'No Album',
      title: track.title,
      // non-required
      artist: track.artist,
      duration: track.duration,
      artUri: track.artUri,
    );
  }

  factory QueuedTrack.fromTrack(Track track) {
    return QueuedTrack()..track = track;
  }

  factory QueuedTrack.fromJson(Map<String, dynamic> json) =>
      _$QueuedTrackFromJson(json);

  Map<String, dynamic> toJson() => _$QueuedTrackToJson(this);
}
