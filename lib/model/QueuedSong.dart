import 'package:audio_service/audio_service.dart';
import 'package:vocaloid_player/globals.dart';
import 'package:vocaloid_player/model/vocadb/vocadb_song.dart';
import 'package:uuid/uuid.dart';

class QueuedSong {
  VocaDBSong song;
  MediaItem mediaItem;
  String contextId;

  String get id => mediaItem.id;

  int get index => Application.store.state.playerState.queue
      .indexWhere((song) => song.id == id);

  QueuedSong(this.song, this.mediaItem, {this.contextId});

  QueuedSong clone() {
    return QueuedSong.fromSong(
      song,
      albumName: mediaItem.album,
      albumArtUrl: mediaItem.artUri,
      contextId: this.contextId,
    );
  }

  factory QueuedSong.fromSong(VocaDBSong song,
      {String albumName = 'NONEMPTY', String albumArtUrl, String contextId}) {
    return new QueuedSong(
      song,
      MediaItem(
        id: Uuid().v4(),
        title: song.name,
        album: albumName,
        artist: song.artistString,
        artUri: albumArtUrl,
      ),
      contextId: contextId,
    );
  }
}
