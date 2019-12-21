import 'package:json_annotation/json_annotation.dart';

part 'vocadb-datetime.g.dart';

@JsonSerializable()
class VocaDBDateTime {
  int day;
  String formatted;
  bool isEmpty;
  int month;
  int year;

  VocaDBDateTime();

  DateTime toDateTime() {
    return isEmpty ? null : DateTime(year, month ?? 1, day ?? 1);
  }

  factory VocaDBDateTime.fromJson(Map<String, dynamic> json) =>
      _$VocaDBDateTimeFromJson(json);

  Map<String, dynamic> toJson() => _$VocaDBDateTimeToJson(this);

  @override
  String toString() {
    return 'VocaDBDateTime{day: $day, formatted: $formatted, isEmpty: $isEmpty, month: $month, year: $year}';
  }
}
