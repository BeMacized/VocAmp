import 'package:json_annotation/json_annotation.dart';
import 'package:voc_amp/models/vocadb/vocadb-album.dart';
import 'package:voc_amp/models/vocadb/vocadb-song.dart';

import 'album-ref.dart';
import 'track-source.dart';

part 'track.g.dart';

@JsonSerializable()
class Track {
  int id;
  String title;
  String artist;
  int duration;
  String artUri;
  AlbumRef album;
  List<TrackSource> sources;

  Track();

  factory Track.fromJson(Map<String, dynamic> json) => _$TrackFromJson(json);

  factory Track.fromVocaDBSong(VocaDBSong song, {AlbumRef album}) {
    // Albums
    if (album == null) {
      List<VocaDBAlbum> albums = List.from(song.albums ?? []);
      var albumRefs = albums.map((a) => AlbumRef.fromVocaDBAlbum(a)).toList();
      albumRefs.sort(
        (a, b) => a.releaseDate == null
            ? 1
            : b.releaseDate == null
                ? -1
                : a.releaseDate.compareTo(b.releaseDate),
      );
      album = albumRefs.isEmpty ? null : albumRefs[0];
    }
    // Sources
    List<TrackSource> sources = (song.pvs ?? [])
        .map((pv) {
          switch (pv.service) {
            case 'Youtube':
              return TrackSource()
                ..type = pv.service
                ..pvType = pv.pvType
                ..data = {
                  'id': pv.pvId,
                  'url': pv.url,
                };
            default:
              return null;
          }
        })
        .where((pv) => pv != null)
        .toList();
    List<String> pvTypeOrder = ['Original', 'Reprint', 'Other'];
    sources.sort(
      (a, b) => (pvTypeOrder.indexOf(a.pvType))
          .compareTo(pvTypeOrder.indexOf(b.pvType)),
    );
    // Build track
    return Track()
      ..id = song.id
      ..title = song.name
      ..artist = song.artistString
      ..duration = song.lengthSeconds
      ..artUri = album?.artUri ?? song?.mainPicture?.urlThumb
      ..album = album
      ..sources = sources;
  }

  Map<String, dynamic> toJson() => _$TrackToJson(this);
}
