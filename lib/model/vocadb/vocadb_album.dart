import 'package:collection/collection.dart';
import 'package:meta/meta.dart';
import 'package:vocaloid_player/model/queued_song.dart';
import 'package:vocaloid_player/model/vocadb/vocadb_entrythumb.dart';
import 'package:vocaloid_player/model/vocadb/vocadb_song.dart';
import 'package:vocaloid_player/model/vocadb/vocadb_songinalbum.dart';

typedef String MapSongToContextId(VocaDBSong song);

class VocaDBAlbum {
  int id;
  String name;
  String artistString;
  VocaDBEntryThumb mainPicture;
  List<VocaDBSongInAlbum> tracks;

  VocaDBAlbum(
      {@required this.id,
      @required this.name,
      @required this.artistString,
      @required this.mainPicture,
      @required this.tracks});

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
                albumName: name,
                albumArtUrl: mainPicture?.urlThumb,
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
