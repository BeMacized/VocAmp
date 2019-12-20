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
    ..trackSource = json['trackSource'] == null
        ? null
        : TrackSource.fromJson(json['trackSource'] as Map<String, dynamic>)
    ..albums = (json['albums'] as List)
        ?.map((e) =>
            e == null ? null : AlbumRef.fromJson(e as Map<String, dynamic>))
        ?.toList();
}

Map<String, dynamic> _$TrackToJson(Track instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'artist': instance.artist,
      'duration': instance.duration,
      'artUri': instance.artUri,
      'trackSource': instance.trackSource,
      'albums': instance.albums,
    };
