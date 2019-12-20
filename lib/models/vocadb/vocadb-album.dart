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
      json['mainPicture'] = {
        "mime": "image/jpeg",
        "urlSmallThumb":
            "https://static.vocadb.net/img/album/mainSmall/${json['id'].toString()}.jpg",
        "urlThumb":
            "https://static.vocadb.net/img/album/mainThumb/${json['id'].toString()}.jpg",
        "urlTinyThumb":
            "https://static.vocadb.net/img/album/mainTiny/${json['id'].toString()}.jpg"
      };
    }
    return _$VocaDBAlbumFromJson(json);
  }

  Map<String, dynamic> toJson() => _$VocaDBAlbumToJson(this);
}
