// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vocadb-album.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VocaDBAlbum _$VocaDBAlbumFromJson(Map<String, dynamic> json) {
  return VocaDBAlbum()
    ..id = json['id'] as int
    ..artistString = json['artistString'] as String
    ..createDate = json['createDate'] == null
        ? null
        : DateTime.parse(json['createDate'] as String)
    ..name = json['name'] as String
    ..discType = json['discType'] as String
    ..ratingAverage = (json['ratingAverage'] as num)?.toDouble()
    ..ratingCount = json['ratingCount'] as int
    ..mainPicture = json['mainPicture'] == null
        ? null
        : VocaDBThumb.fromJson(json['mainPicture'] as Map<String, dynamic>)
    ..releaseDate = json['releaseDate'] == null
        ? null
        : VocaDBDateTime.fromJson(json['releaseDate'] as Map<String, dynamic>);
}

Map<String, dynamic> _$VocaDBAlbumToJson(VocaDBAlbum instance) =>
    <String, dynamic>{
      'id': instance.id,
      'artistString': instance.artistString,
      'createDate': instance.createDate?.toIso8601String(),
      'name': instance.name,
      'discType': instance.discType,
      'ratingAverage': instance.ratingAverage,
      'ratingCount': instance.ratingCount,
      'mainPicture': instance.mainPicture,
      'releaseDate': instance.releaseDate,
    };
