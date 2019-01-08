import 'package:meta/meta.dart';
import 'package:vocaloid_player/model/vocadb/vocadb_song.dart';

class VocaDBSongInAlbum {
  final int discNumber;
  final int id;
  final String name;
  final int trackNumber;
  final VocaDBSong song;

  VocaDBSongInAlbum(
      {@required this.discNumber,
      @required this.id,
      @required this.name,
      @required this.trackNumber,
      @required this.song});

  factory VocaDBSongInAlbum.fromJson(Map<String, dynamic> json) {
    return json != null
        ? VocaDBSongInAlbum(
            discNumber: json['discNumber'] as int,
            id: json['id'] as int,
            name: json['name'] as String,
            trackNumber: json['trackNumber'] as int,
            song: VocaDBSong.fromJson(json['song'] as Map<String, dynamic>),
          )
        : null;
  }
}
