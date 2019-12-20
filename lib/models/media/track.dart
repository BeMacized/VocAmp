import 'package:audio_service/audio_service.dart';
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
  TrackSource trackSource;
  List<AlbumRef> albums;

  Track();

  MediaItem buildMediaItem() {
    return MediaItem(
      // required
      id: id.toString(),
      album: albums.isEmpty ? 'No Album' : albums[0].albumName,
      title: title,
      // non-required
      artist: artist,
      duration: duration,
      artUri: artUri,
    );
  }

  factory Track.fromJson(Map<String, dynamic> json) => _$TrackFromJson(json);

  factory Track.fromVocaDBSong(VocaDBSong song) {
    List<VocaDBAlbum> albums = List.from(song.albums ?? []);
    var albumRefs = albums.map((a) => AlbumRef.fromVocaDBAlbum(a)).toList();
    albumRefs.sort(
      (a, b) => a.releaseDate == null
          ? 1
          : b.releaseDate == null ? -1 : a.releaseDate.compareTo(b.releaseDate),
    );
    return Track()
      ..id = song.id
      ..title = song.name
      ..artist = song.artistString
      ..duration = song.lengthSeconds
      ..albums = albumRefs
      ..artUri = song?.mainPicture?.urlThumb;
  }

  Map<String, dynamic> toJson() => _$TrackToJson(this);
}
