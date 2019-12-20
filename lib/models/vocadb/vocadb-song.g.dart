// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vocadb-song.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VocaDBSong _$VocaDBSongFromJson(Map<String, dynamic> json) {
  return VocaDBSong()
    ..id = json['id'] as int
    ..name = json['name'] as String
    ..lengthSeconds = json['lengthSeconds'] as int
    ..artistString = json['artistString'] as String
    ..createDate = json['createDate'] == null
        ? null
        : DateTime.parse(json['createDate'] as String)
    ..defaultName = json['defaultName'] as String
    ..defaultNameLanguage = json['defaultNameLanguage'] as String
    ..favoritedTimes = json['favoritedTimes'] as int
    ..publishDate = json['publishDate'] == null
        ? null
        : DateTime.parse(json['publishDate'] as String)
    ..pvServices = json['pvServices'] as String
    ..ratingScore = json['ratingScore'] as int
    ..songType = json['songType'] as String
    ..status = json['status'] as String
    ..version = json['version'] as int
    ..pvs = (json['pvs'] as List)
        ?.map((e) =>
            e == null ? null : VocaDBPV.fromJson(e as Map<String, dynamic>))
        ?.toList()
    ..mainPicture = json['mainPicture'] == null
        ? null
        : VocaDBThumb.fromJson(json['mainPicture'] as Map<String, dynamic>)
    ..albums = (json['albums'] as List)
        ?.map((e) =>
            e == null ? null : VocaDBAlbum.fromJson(e as Map<String, dynamic>))
        ?.toList();
}

Map<String, dynamic> _$VocaDBSongToJson(VocaDBSong instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'lengthSeconds': instance.lengthSeconds,
      'artistString': instance.artistString,
      'createDate': instance.createDate?.toIso8601String(),
      'defaultName': instance.defaultName,
      'defaultNameLanguage': instance.defaultNameLanguage,
      'favoritedTimes': instance.favoritedTimes,
      'publishDate': instance.publishDate?.toIso8601String(),
      'pvServices': instance.pvServices,
      'ratingScore': instance.ratingScore,
      'songType': instance.songType,
      'status': instance.status,
      'version': instance.version,
      'pvs': instance.pvs,
      'mainPicture': instance.mainPicture,
      'albums': instance.albums,
    };
