import 'package:json_annotation/json_annotation.dart';
import 'package:voc_amp/models/vocadb/vocadb-album.dart';
import 'package:voc_amp/models/vocadb/vocadb-pv.dart';
import 'package:voc_amp/models/vocadb/vocadb-thumb.dart';

part 'vocadb-song.g.dart';

@JsonSerializable()
class VocaDBSong {
  int id;
  String name;
  int lengthSeconds;
  String artistString;
  DateTime createDate;
  String defaultName;
  String defaultNameLanguage;
  int favoritedTimes;
  DateTime publishDate;
  String pvServices;
  int ratingScore;
  String songType;
  String status;
  int version;
  List<VocaDBPV> pvs;
  VocaDBThumb mainPicture;
  List<VocaDBAlbum> albums;

  VocaDBSong();

  factory VocaDBSong.fromJson(Map<String, dynamic> json) =>
      _$VocaDBSongFromJson(json);

  Map<String, dynamic> toJson() => _$VocaDBSongToJson(this);

}
