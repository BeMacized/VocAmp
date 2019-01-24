import 'package:collection/collection.dart';
import 'package:meta/meta.dart';
import 'package:vocaloid_player/model/queued_song.dart';
import 'package:vocaloid_player/model/vocadb/vocadb_optional_datetime.dart';
import 'package:vocaloid_player/model/vocadb/vocadb_song.dart';
import 'package:vocaloid_player/model/vocadb/vocadb_songinalbum.dart';

typedef String MapSongToContextId(VocaDBSong song);

class VocaDBAlbum {
  final int id;
  final String name;
  final String artistString;
  final List<VocaDBSongInAlbum> tracks;
  final VocaDBOptionalDateTime releaseDate;

  VocaDBAlbum(
      {@required this.id,
      @required this.name,
      @required this.artistString,
      @required this.tracks,
      @required this.releaseDate});

  String get albumArtUrl =>
      "https://static.vocadb.net/img/album/mainThumb/$id.jpg";

  List<QueuedSong> buildQueuedSongs(MapSongToContextId mapToContextId) {
    Map<int, List<VocaDBSongInAlbum>> discs = groupBy<VocaDBSongInAlbum, int>(
      tracks,
      (VocaDBSongInAlbum song) => song.discNumber,
    );

    // Merge discs && filter to playable tracks
    List<VocaDBSong> items = discs.values
        .expand((songs) => songs)
        .where((song) => song.song != null && song.song.isAvailable)
        .map((song) => song.song)
        .toList();
    // Generate songs for queueing
    List<QueuedSong> queue = items
        .map<QueuedSong>(
          (song) => QueuedSong.fromSong(
                song,
                this,
                contextId: mapToContextId(song),
              ),
        )
        .toList();

    return queue;
  }

  factory VocaDBAlbum.fromJson(Map<String, dynamic> json) {
    return json != null
        ? VocaDBAlbum(
            id: json['id'] as int,
            name: json['name'] as String,
            artistString: json['artistString'] as String,
            tracks: json['tracks'] != null
                ? (json['tracks'] as List)
                    .map((e) =>
                        VocaDBSongInAlbum.fromJson(e as Map<String, dynamic>))
                    .toList()
                : [],
            releaseDate: json['releaseDate'] != null
                ? VocaDBOptionalDateTime.fromJson(json['releaseDate'])
                : null,
          )
        : null;
  }
}
