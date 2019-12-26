// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'track.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Track _$TrackFromJson(Map<String, dynamic> json) {
  return Track()
    ..id = json['id'] as int
    ..title = json['title'] as String
    ..artist = json['artist'] as String
    ..duration = json['duration'] as int
    ..artUri = json['artUri'] as String
    ..album = json['album'] == null
        ? null
        : AlbumRef.fromJson(json['album'] as Map<String, dynamic>)
    ..sources = (json['sources'] as List)
        ?.map((e) =>
            e == null ? null : TrackSource.fromJson(e as Map<String, dynamic>))
        ?.toList();
}

Map<String, dynamic> _$TrackToJson(Track instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'artist': instance.artist,
      'duration': instance.duration,
      'artUri': instance.artUri,
      'album': instance.album,
      'sources': instance.sources,
    };
