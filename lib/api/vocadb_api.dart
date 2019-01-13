import 'package:vocaloid_player/api/api_exceptions.dart';
import 'package:vocaloid_player/model/vocadb/vocadb_album.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:connectivity/connectivity.dart';
import 'package:vocaloid_player/model/vocadb/vocadb_song.dart';

final String BASE_URL = 'https://vocadb.net/api';

Future<http.Response> _handleErrors(Function request) async {
  // Check connection
  var connectivityResult = await (Connectivity().checkConnectivity());
  if (connectivityResult == ConnectivityResult.none)
    throw NotConnectedException();

  try {
    final http.Response resp = await request();
    switch (resp.statusCode) {
      case 200:
        return resp;
      case 404:
        throw NotFoundException();
      default:
        {
          if (resp.statusCode >= 400 && resp.statusCode < 500)
            throw BadRequestException(statusCode: resp.statusCode);
          if (resp.statusCode >= 500 && resp.statusCode < 600)
            throw InternalServerErrorException();
          throw UnknownAPIErrorException(
              statusCode: resp.statusCode, data: resp.body);
        }
    }
  } catch (e) {
    throw CantReachException();
  }
}

Future<List<VocaDBAlbum>> getRandomTopAlbums() async {
  final String url =
      '${BASE_URL}/albums/top?fields=MainPicture,Tracks&sort=RatingScore';
  final http.Response resp = await _handleErrors(() => http.get(url));
  return List<Map<String, dynamic>>.from(json.decode(resp.body))
      .map<VocaDBAlbum>((rawAlbum) => VocaDBAlbum.fromJson(rawAlbum))
      .toList()..shuffle();
}

Future<VocaDBAlbum> getAlbum(int id) async {
  final String url =
      '${BASE_URL}/albums/${id}?fields=MainPicture,Tracks&songFields=MainPicture,PVs';
  final http.Response resp = await _handleErrors(() => http.get(url));
  return VocaDBAlbum.fromJson(json.decode(resp.body) as Map<String, dynamic>);
}

Future<List<VocaDBAlbum>> searchAlbums(String query,
    {int maxResults = 10}) async {
  final String url =
      '${BASE_URL}/albums?query=${Uri.encodeComponent(query)}&maxResults=${maxResults.clamp(1, 50)}&nameMatchMode=Auto&fields=MainPicture,Tracks&sort=RatingScore';
  final http.Response resp = await _handleErrors(() => http.get(url));
  Map<String, dynamic> jsonData =
      json.decode(resp.body) as Map<String, dynamic>;
  return List<Map<String, dynamic>>.from(jsonData['items'] ?? [])
      .map<VocaDBAlbum>((rawAlbum) => VocaDBAlbum.fromJson(rawAlbum))
      .toList();
}

Future<List<VocaDBSong>> searchSongs(String query,
    {int maxResults = 10}) async {
  final String url =
      '${BASE_URL}/songs?query=${Uri.encodeComponent(query)}&maxResults=${maxResults.clamp(1, 50)}&nameMatchMode=Auto&fields=MainPicture,PVs&sort=RatingScore&onlyWithPvs=true';
  final http.Response resp = await _handleErrors(() => http.get(url));
  Map<String, dynamic> jsonData =
      json.decode(resp.body) as Map<String, dynamic>;
  return List<Map<String, dynamic>>.from(jsonData['items'] ?? [])
      .map<VocaDBSong>((rawSong) => VocaDBSong.fromJson(rawSong))
      .toList();
}
