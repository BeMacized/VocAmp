// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vocadb-pv.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VocaDBPV _$VocaDBPVFromJson(Map<String, dynamic> json) {
  return VocaDBPV()
    ..id = json['id'] as int
    ..pvId = json['pvId'] as String
    ..service = json['service'] as String
    ..pvType = json['pvType'] as String
    ..url = json['url'] as String
    ..thumbUrl = json['thumbUrl'] as String
    ..author = json['author'] as String
    ..name = json['name'] as String
    ..publishDate = json['publishDate'] == null
        ? null
        : DateTime.parse(json['publishDate'] as String)
    ..disabled = json['disabled'] as bool;
}

Map<String, dynamic> _$VocaDBPVToJson(VocaDBPV instance) => <String, dynamic>{
      'id': instance.id,
      'pvId': instance.pvId,
      'service': instance.service,
      'pvType': instance.pvType,
      'url': instance.url,
      'thumbUrl': instance.thumbUrl,
      'author': instance.author,
      'name': instance.name,
      'publishDate': instance.publishDate?.toIso8601String(),
      'disabled': instance.disabled,
    };
