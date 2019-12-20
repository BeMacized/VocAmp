import 'package:dio/dio.dart';
import 'package:voc_amp/models/vocadb/vocadb-song.dart';

enum FilteringMode {
  popularity,
  newlyPublished,
  newlyAdded,
}

enum Vocalist {
  all,
  vocaloid,
  utau,
  other,
}

class VocaDBSongsApiRepository {
  Future<List<VocaDBSong>> getTopRated({
    Duration duration,
    FilteringMode filteringMode = FilteringMode.popularity,
    Vocalist vocalist = Vocalist.all,
  }) async {
    // Define filter string
    String filterByParam;
    switch (filteringMode) {
      case FilteringMode.popularity:
        filterByParam = 'Popularity';
        break;
      case FilteringMode.newlyPublished:
        filterByParam = 'PublishDate';
        break;
      case FilteringMode.newlyAdded:
        filterByParam = 'CreateDate';
        break;
    }
    // Define vocalist string
    String vocalistParam;
    switch (vocalist) {
      case Vocalist.all:
        vocalistParam = '';
        break;
      case Vocalist.vocaloid:
        vocalistParam = 'Vocaloid';
        break;
      case Vocalist.utau:
        vocalistParam = 'UTAU';
        break;
      case Vocalist.other:
        vocalistParam = 'CeVIO';
        break;
    }
    // Construct url;
    String url = "https://vocadb.net/api/songs/top-rated";
    url += '?fields=PVs,Albums';
    url += '&durationHours=${duration?.inHours ?? ''}';
    url += '&filterBy=$filterByParam';
    url += '&vocalist=$vocalistParam';
    // Fetch data
    Response<List<dynamic>> resp = await Dio().get<List<dynamic>>(url);
    // Map response
    return resp.data.map((d) => VocaDBSong.fromJson(d)).toList();
  }
}
