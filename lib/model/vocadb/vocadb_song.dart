import 'package:meta/meta.dart';
import 'package:vocaloid_player/audio/MediaSource.dart';
import 'package:vocaloid_player/model/vocadb/vocadb_entrythumb.dart';
import 'package:vocaloid_player/model/vocadb/vocadb_pv.dart';

class VocaDBSong {
  final int id;
  final String name;
  final String artistString;
  final int lengthSeconds;
  final VocaDBEntryThumb mainPicture;
  final List<VocaDBPV> pvs;

  VocaDBSong(
      {@required this.id,
      @required this.name,
      @required this.artistString,
      @required this.lengthSeconds,
      @required this.mainPicture,
      @required this.pvs});

  bool get isAvailable {
    return isStreamable;
  }

  bool get isStreamable {
    VocaDBPV pv = pvs.firstWhere((pv) => pv.service == PVService.Youtube && !pv.disabled,
        orElse: () => null);
    return pv != null;
  }

  MediaSource get mediaSource {
    VocaDBPV pv = pvs.firstWhere((pv) => pv.service == PVService.Youtube && !pv.disabled,
        orElse: () => null);
    if (pv == null) return null;
    return MediaSource(type: MediaSourceType.YouTube, url: pv.url);
  }

  factory VocaDBSong.fromJson(Map<String, dynamic> json) {
    return json != null
        ? VocaDBSong(
            id: json['id'] as int,
            name: json['name'] as String,
            artistString: json['artistString'] as String,
            lengthSeconds: json['lengthSeconds'] as int,
            mainPicture: VocaDBEntryThumb.fromJson(
                json['mainPicture'] as Map<String, dynamic>),
            pvs: json['pvs'] != null
                ? (json['pvs'] as List)
                    .map<VocaDBPV>(
                        (e) => VocaDBPV.fromJson(e as Map<String, dynamic>))
                    .toList()
                : [],
          )
        : null;
  }
}
