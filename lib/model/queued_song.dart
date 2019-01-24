import 'package:audio_service/audio_service.dart';
import 'package:vocaloid_player/globals.dart';
import 'package:vocaloid_player/model/vocadb/vocadb_album.dart';
import 'package:vocaloid_player/model/vocadb/vocadb_song.dart';
import 'package:uuid/uuid.dart';

class QueuedSong {
  VocaDBSong song;
  VocaDBAlbum album;
  MediaItem mediaItem;
  String contextId;

  String get id => mediaItem.id;

  int get index => Application.store.state.player.queue
      .indexWhere((song) => song.id == id);

  QueuedSong(this.song, this.album, this.mediaItem, {this.contextId});

  QueuedSong clone() {
    return QueuedSong.fromSong(
      song,
      album,
      contextId: this.contextId,
    );
  }

  factory QueuedSong.fromSong(VocaDBSong song, VocaDBAlbum album,
      {String contextId}) {
    return QueuedSong(
      song,
      album,
      MediaItem(
        id: Uuid().v4(),
        title: song.name,
        album: album?.name ?? '',
        artist: song.artistString,
        artUri: album?.albumArtUrl ?? '',
      ),
      contextId: contextId,
    );
  }
}
