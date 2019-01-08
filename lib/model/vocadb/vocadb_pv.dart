import 'package:meta/meta.dart';

enum PVService {
  NicoNicoDouga,
  Youtube,
  SoundCloud,
  Vimeo,
  Piapro,
  Bilibili,
  File,
  LocalFile,
  Creofuga
}

enum PVType { Original, Reprint, Other }

class VocaDBPV {
  final int id;
  final PVService service;
  final Duration length;
  final String url;
  final String publishDate;
  final String name;
  final PVType type;
  final String thumbUrl;
  final String author;
  final bool disabled;

  VocaDBPV(
      {@required this.id,
      @required this.service,
      @required this.length,
      @required this.url,
      @required this.publishDate,
      @required this.name,
      @required this.type,
      @required this.thumbUrl,
      @required this.author,
      @required this.disabled});

  factory VocaDBPV.fromJson(Map<String, dynamic> json) {
    return json != null
        ? VocaDBPV(
            id: json['id'] as int,
            service: PVService.values.firstWhere(
                (service) =>
                    service.toString().split('\.')[1] ==
                    (json['service'] as String),
                orElse: () => null),
            length: (json['seconds'] != null
                ? Duration(seconds: json['seconds'] as int)
                : null),
            url: json['url'] as String,
            publishDate: json['publishDate'] as String,
            name: json['name'] as String,
            type: PVType.values.firstWhere(
                (type) =>
                    type.toString().split('\.')[1] == (json['type'] as String),
                orElse: () => null),
            thumbUrl: json['thumbUrl'] as String,
            author: json['author'] as String,
            disabled: json['disabled'] as bool,
          )
        : null;
  }
}
