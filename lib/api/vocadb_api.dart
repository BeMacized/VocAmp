
import 'package:vocaloid_player/model/vocadb/vocadb_album.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

Future<VocaDBAlbum> getAlbum(int id) async {

  final resp = await http.get('https://vocadb.net/api/albums/${id}?fields=MainPicture,Tracks&songFields=MainPicture,PVs');
  if (resp.statusCode == 200) {
    return VocaDBAlbum.fromJson(json.decode(resp.body) as Map<String, dynamic>);
  } else {
    throw Exception('Failed to load album');
  }

}