import 'package:meta/meta.dart';

class VocaDBOptionalDateTime {
  final int year;
  final int month;
  final int day;
  final String formatted;
  final bool isEmpty;

  VocaDBOptionalDateTime({
    @required this.year,
    @required this.month,
    @required this.day,
    @required this.formatted,
    @required this.isEmpty,
  });

  DateTime get dateTime => isEmpty ? null : DateTime.utc(year, month, day);

  factory VocaDBOptionalDateTime.fromJson(Map<String, dynamic> json) {
    return json != null
        ? VocaDBOptionalDateTime(
            year: json['year'] as int,
            month: json['month'] as int,
            day: json['day'] as int,
            formatted: json['formatted'] as String,
            isEmpty: json['isEmpty'] as bool,
          )
        : null;
  }
}
