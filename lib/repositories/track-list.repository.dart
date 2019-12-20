import 'package:voc_amp/models/media/track.dart';
import 'package:voc_amp/repositories/vocadb-songs-api.repository.dart';

class TrackListRepository {
  VocaDBSongsApiRepository _vocaDBSongsApiRepository;

  TrackListRepository(this._vocaDBSongsApiRepository);

  Future<List<Track>> getTopTracks({
    Duration duration,
    FilteringMode filteringMode,
    Vocalist vocalist,
  }) async {
    return await _vocaDBSongsApiRepository
        .getTopRated(
          duration: duration,
          filteringMode: filteringMode,
          vocalist: vocalist,
        )
        .then((songs) => songs.map((s) => Track.fromVocaDBSong(s)).toList());
  }
}
