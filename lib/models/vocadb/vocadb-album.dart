import 'package:json_annotation/json_annotation.dart';
import 'package:voc_amp/models/vocadb/vocadb-thumb.dart';

import 'vocadb-datetime.dart';

part 'vocadb-album.g.dart';

@JsonSerializable()
class VocaDBAlbum {
  int id;
  String artistString;
  DateTime createDate;
  String name;
  String discType;
  double ratingAverage;
  int ratingCount;
  VocaDBThumb mainPicture;
  VocaDBDateTime releaseDate;

  VocaDBAlbum();

  factory VocaDBAlbum.fromJson(Map<String, dynamic> json) {
    // If no picture present, insert it
    if (!json.containsKey('mainPicture')) {
      String mime = json.containsKey('coverPictureMime')
          ? json['coverPictureMime']
          : "image/jpeg";
      String ext = 'jpg';
      if (mime.startsWith('image/')) {
        ext = mime.substring('image/'.length);
        if (ext == 'jpeg') ext = 'jpg';
      }
      json['mainPicture'] = {
        "mime": mime,
        "urlSmallThumb":
            "https://static.vocadb.net/img/album/mainSmall/${json['id'].toString()}.$ext",
        "urlThumb":
            "https://static.vocadb.net/img/album/mainThumb/${json['id'].toString()}.$ext",
        "urlTinyThumb":
            "https://static.vocadb.net/img/album/mainTiny/${json['id'].toString()}.$ext"
      };
    }
    return _$VocaDBAlbumFromJson(json);
  }

  Map<String, dynamic> toJson() => _$VocaDBAlbumToJson(this);
}
