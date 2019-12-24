import 'package:json_annotation/json_annotation.dart';
import 'package:voc_amp/models/media/track.dart';

part 'queued-track.g.dart';

@JsonSerializable()
class QueuedTrack {
  Track track;

  QueuedTrack();

  factory QueuedTrack.fromTrack(Track track) {
    return QueuedTrack()..track = track;
  }

  factory QueuedTrack.fromJson(Map<String, dynamic> json) =>
      _$QueuedTrackFromJson(json);

  Map<String, dynamic> toJson() => _$QueuedTrackToJson(this);
}
