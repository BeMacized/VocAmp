import 'package:json_annotation/json_annotation.dart';

part 'vocadb-pv.g.dart';

@JsonSerializable()
class VocaDBPV {
  int id;
  String pvId;
  String service;
  String pvType;
  String url;
  String thumbUrl;
  String author;
  String name;
  DateTime publishDate;
  bool disabled;

  VocaDBPV();

  factory VocaDBPV.fromJson(Map<String, dynamic> json) =>
      _$VocaDBPVFromJson(json);

  Map<String, dynamic> toJson() => _$VocaDBPVToJson(this);

  @override
  String toString() {
    return 'VocaDBPV{id: $id, publishDate: $publishDate}';
  }


}
