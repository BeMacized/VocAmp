// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vocadb-datetime.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VocaDBDateTime _$VocaDBDateTimeFromJson(Map<String, dynamic> json) {
  return VocaDBDateTime()
    ..day = json['day'] as int
    ..formatted = json['formatted'] as String
    ..isEmpty = json['isEmpty'] as bool
    ..month = json['month'] as int
    ..year = json['year'] as int;
}

Map<String, dynamic> _$VocaDBDateTimeToJson(VocaDBDateTime instance) =>
    <String, dynamic>{
      'day': instance.day,
      'formatted': instance.formatted,
      'isEmpty': instance.isEmpty,
      'month': instance.month,
      'year': instance.year,
    };
