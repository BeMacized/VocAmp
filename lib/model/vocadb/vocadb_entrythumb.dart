import 'package:meta/meta.dart';

class VocaDBEntryThumb {
  final String mime;
  final String urlSmallThumb;
  final String urlThumb;
  final String urlTinyThumb;

  VocaDBEntryThumb(
      {@required this.mime,
      @required this.urlSmallThumb,
      @required this.urlThumb,
      @required this.urlTinyThumb});

  factory VocaDBEntryThumb.fromJson(Map<String, dynamic> json) {
    return json != null
        ? VocaDBEntryThumb(
            mime: json['mime'] as String,
            urlSmallThumb: json['urlSmallThumb'] as String,
            urlThumb: json['urlThumb'] as String,
            urlTinyThumb: json['urlTinyThumb'] as String,
          )
        : null;
  }
}
