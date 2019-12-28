// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'queue-track.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QueueTrack _$QueueTrackFromJson(Map<String, dynamic> json) {
  return QueueTrack()
    ..id = json['id'] as String
    ..track = json['track'] == null
        ? null
        : Track.fromJson(json['track'] as Map<String, dynamic>);
}

Map<String, dynamic> _$QueueTrackToJson(QueueTrack instance) =>
    <String, dynamic>{
      'id': instance.id,
      'track': instance.track,
    };
