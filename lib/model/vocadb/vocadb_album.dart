import 'package:meta/meta.dart';
import 'package:vocaloid_player/model/vocadb/vocadb_entrythumb.dart';
import 'package:vocaloid_player/model/vocadb/vocadb_songinalbum.dart';

class VocaDBAlbum {
  final int id;
  final String name;
  final String artistString;
  final VocaDBEntryThumb mainPicture;
  final List<VocaDBSongInAlbum> tracks;

  VocaDBAlbum(
      {@required this.id,
      @required this.name,
      @required this.artistString,
      @required this.mainPicture,
      @required this.tracks});

  factory VocaDBAlbum.fromJson(Map<String, dynamic> json) {
    return json != null
        ? VocaDBAlbum(
            id: json['id'] as int,
            name: json['name'] as String,
            artistString: json['artistString'] as String,
            mainPicture: VocaDBEntryThumb.fromJson(
                json['mainPicture'] as Map<String, dynamic>),
            tracks: json['tracks'] != null
                ? (json['tracks'] as List)
                    .map((e) =>
                        VocaDBSongInAlbum.fromJson(e as Map<String, dynamic>))
                    .toList()
                : [],
          )
        : null;
  }
}
