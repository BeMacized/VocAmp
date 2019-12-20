import 'package:json_annotation/json_annotation.dart';
import 'package:voc_amp/models/vocadb/vocadb-album.dart';

part 'album-ref.g.dart';

@JsonSerializable()
class AlbumRef {
  int albumId;
  String albumName;
  DateTime releaseDate;
  String artUri;

  AlbumRef();

  factory AlbumRef.fromJson(Map<String, dynamic> json) =>
      _$AlbumRefFromJson(json);

  factory AlbumRef.fromVocaDBAlbum(VocaDBAlbum a) {
    return AlbumRef()
      ..albumId = a.id
      ..albumName = a.name
      ..releaseDate = a.releaseDate?.toDateTime()
      ..artUri = a.mainPicture?.urlThumb;
  }

  Map<String, dynamic> toJson() => _$AlbumRefToJson(this);
}
