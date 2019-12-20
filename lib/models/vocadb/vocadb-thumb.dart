import 'package:json_annotation/json_annotation.dart';

part 'vocadb-thumb.g.dart';

@JsonSerializable()
class VocaDBThumb {

  String mime;
  String urlSmallThumb;
  String urlThumb;
  String urlTinyThumb;

  VocaDBThumb();

  factory VocaDBThumb.fromJson(Map<String, dynamic> json) =>
      _$VocaDBThumbFromJson(json);

  Map<String, dynamic> toJson() => _$VocaDBThumbToJson(this);

}
