import 'package:json_annotation/json_annotation.dart';

part 'track-source.g.dart';

@JsonSerializable()
class TrackSource {

  String type;
  String pvType;
  Map<String, String> data;

  TrackSource();

  factory TrackSource.fromJson(Map<String, dynamic> json) =>
      _$TrackSourceFromJson(json);

  Map<String, dynamic> toJson() => _$TrackSourceToJson(this);

}
