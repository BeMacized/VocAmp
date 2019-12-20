// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vocadb-thumb.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VocaDBThumb _$VocaDBThumbFromJson(Map<String, dynamic> json) {
  return VocaDBThumb()
    ..mime = json['mime'] as String
    ..urlSmallThumb = json['urlSmallThumb'] as String
    ..urlThumb = json['urlThumb'] as String
    ..urlTinyThumb = json['urlTinyThumb'] as String;
}

Map<String, dynamic> _$VocaDBThumbToJson(VocaDBThumb instance) =>
    <String, dynamic>{
      'mime': instance.mime,
      'urlSmallThumb': instance.urlSmallThumb,
      'urlThumb': instance.urlThumb,
      'urlTinyThumb': instance.urlTinyThumb,
    };
