import 'package:vocaloid_player/api/api_exceptions.dart';
import 'package:vocaloid_player/model/vocadb/vocadb_album.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:connectivity/connectivity.dart';

Future<VocaDBAlbum> getAlbum(int id) async {
  // Check connection
  var connectivityResult = await (new Connectivity().checkConnectivity());
  if (connectivityResult == ConnectivityResult.none)
    throw NotConnectedException();

  try {
    final resp = await http.get(
        'https://vocadb.net/api/albums/${id}?fields=MainPicture,Tracks&songFields=MainPicture,PVs');
    switch (resp.statusCode) {
      case 200:
        return VocaDBAlbum.fromJson(
            json.decode(resp.body) as Map<String, dynamic>);
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
