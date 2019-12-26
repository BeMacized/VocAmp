// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'track-source.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TrackSource _$TrackSourceFromJson(Map<String, dynamic> json) {
  return TrackSource()
    ..type = json['type'] as String
    ..pvType = json['pvType'] as String
    ..data = (json['data'] as Map<String, dynamic>)?.map(
      (k, e) => MapEntry(k, e as String),
    );
}

Map<String, dynamic> _$TrackSourceToJson(TrackSource instance) =>
    <String, dynamic>{
      'type': instance.type,
      'pvType': instance.pvType,
      'data': instance.data,
    };
