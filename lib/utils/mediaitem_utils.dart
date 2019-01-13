import 'package:audio_service/audio_service.dart';

MediaItem copyMediaItem(MediaItem mediaItem,
    {String id,
    String album,
    String title,
    String artist,
    String genre,
    int duration,
    String artUri}) {
  return MediaItem(
      id: id ?? mediaItem.id,
      album: album ?? mediaItem.album,
      title: title ?? mediaItem.title,
      artist: artist ?? mediaItem.artist,
      genre: genre ?? mediaItem.genre,
      duration: duration ?? mediaItem.duration,
      artUri: artUri ?? mediaItem.artUri);
}

MediaItem raw2mediaItem(Map raw) => MediaItem(
      id: raw['id'],
      album: raw['album'],
      title: raw['title'],
      artist: raw['artist'],
      genre: raw['genre'],
      duration: raw['duration'],
      artUri: raw['artUri'],
    );

Map mediaItem2raw(MediaItem mediaItem) => {
      'id': mediaItem.id,
      'album': mediaItem.album,
      'title': mediaItem.title,
      'artist': mediaItem.artist,
      'genre': mediaItem.genre,
      'duration': mediaItem.duration,
      'artUri': mediaItem.artUri,
      'playable': mediaItem.playable,
    };
