import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:dio/dio.dart';
import 'package:dio_http_cache/dio_http_cache.dart';
import 'package:voc_amp/models/utils/failure.dart';
import 'package:voc_amp/models/vocadb/vocadb-song.dart';
import 'package:voc_amp/utils/dio_utils.dart';

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
  Dio _dio = DioUtils.createCaching();

  Future<List<VocaDBSong>> getTopRated({
    Duration duration,
    FilteringMode filteringMode = FilteringMode.popularity,
    Vocalist vocalist = Vocalist.all,
  }) async {
    // Define filter string
    String filterByParam;
    switch (filteringMode) {
      case FilteringMode.newlyPublished:
        filterByParam = 'PublishDate';
        break;
      case FilteringMode.newlyAdded:
        filterByParam = 'CreateDate';
        break;
      case FilteringMode.popularity:
      default:
        filterByParam = 'Popularity';
        break;
    }
    // Define vocalist string
    String vocalistParam;
    switch (vocalist) {
      case Vocalist.vocaloid:
        vocalistParam = 'Vocaloid';
        break;
      case Vocalist.utau:
        vocalistParam = 'UTAU';
        break;
      case Vocalist.other:
        vocalistParam = 'CeVIO';
        break;
      case Vocalist.all:
        break;
    }
    // Construct url;
    String url = "https://vocadb.net/api/songs/top-rated";
    url += '?fields=PVs,Albums,MainPicture';
    if (duration != null) url += '&durationHours=${duration.inHours}';
    if (filterByParam != null) url += '&filterBy=$filterByParam';
    if (vocalistParam != null) url += '&vocalist=$vocalistParam';
    // Fetch data
    Response resp;
    try {
      resp = await _dio.get(
        url,
        options: buildCacheOptions(Duration(hours: 1), maxStale: duration),
      );
    } on DioError catch (e) {
      await _handleDioError(e);
    }
    // Map response
    return (resp.data as List<dynamic>)
        .map((d) => VocaDBSong.fromJson(d))
        .toList();
  }

  _handleDioError(DioError e) async {
    switch (e.type) {
      case DioErrorType.CONNECT_TIMEOUT:
        throw Failure(
          message: 'Could not reach VocaDB!',
          flags: [FailureFlag.retry],
        );
      case DioErrorType.SEND_TIMEOUT:
      case DioErrorType.RECEIVE_TIMEOUT:
        throw Failure(
          message: 'Connection with VocaDB timed out.',
          flags: [FailureFlag.retry],
        );
      case DioErrorType.RESPONSE:
        // TODO: Handle this case.
        break;
      case DioErrorType.CANCEL:
        throw Failure(
          message: 'Data could not be retrieved as the action was cancelled.',
          flags: [FailureFlag.retry],
        );
      case DioErrorType.DEFAULT:
        if (e.error is SocketException &&
            (await (Connectivity().checkConnectivity())) ==
                ConnectivityResult.none) {
          throw Failure(
            message: 'You are not connected to the internet!',
            flags: [FailureFlag.retry],
          );
        }
        throw e.error;
      default:
        throw e.error;
    }
  }
}
