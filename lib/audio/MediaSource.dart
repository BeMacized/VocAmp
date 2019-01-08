import 'package:meta/meta.dart';

enum MediaSourceType { YouTube }

class MediaSource {
  MediaSourceType type;
  String url;

  MediaSource({
    @required this.type,
    @required this.url,
  });

  Map toMap() {
    return {'url': url, 'type': type.toString().split('\.')[1]};
  }

  factory MediaSource.fromMap(Map map) {
    return MediaSource(
      type: MediaSourceType.values.firstWhere(
          (service) =>
              service.toString().split('\.')[1] == (map['type'] as String),
          orElse: () => null),
      url: map['url'],
    );
  }
}
