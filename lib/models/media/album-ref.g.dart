// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'album-ref.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AlbumRef _$AlbumRefFromJson(Map<String, dynamic> json) {
  return AlbumRef()
    ..albumId = json['albumId'] as int
    ..albumName = json['albumName'] as String
    ..releaseDate = json['releaseDate'] == null
        ? null
        : DateTime.parse(json['releaseDate'] as String)
    ..artUri = json['artUri'] as String;
}

Map<String, dynamic> _$AlbumRefToJson(AlbumRef instance) => <String, dynamic>{
      'albumId': instance.albumId,
      'albumName': instance.albumName,
      'releaseDate': instance.releaseDate?.toIso8601String(),
      'artUri': instance.artUri,
    };
