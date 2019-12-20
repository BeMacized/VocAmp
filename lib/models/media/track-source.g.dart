// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'track-source.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TrackSource _$TrackSourceFromJson(Map<String, dynamic> json) {
  return TrackSource()
    ..type = json['type'] as String
    ..uri = json['uri'] as String;
}

Map<String, dynamic> _$TrackSourceToJson(TrackSource instance) =>
    <String, dynamic>{
      'type': instance.type,
      'uri': instance.uri,
    };
