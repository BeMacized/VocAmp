import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:voc_amp/background/utils/youtube-utils.dart';
import 'package:voc_amp/models/media/queue-track.dart';
import 'package:voc_amp/models/media/track-source.dart';
import 'package:voc_amp/utils/logger.dart';

class StreamUtils {
  static Logger _log = Logger('StreamUtils');
  static Connectivity _connectivity = Connectivity();

  // Obtain an audio stream url from a track source instance.
  // Returns null if no stream could be found.
  // Can throw UnsupportedTrackSourceException if there is no implementation for this type of track source
  // Can throw SocketException if the audio source could not be reached
  static Future<String> getAudioStreamForTrackSource(TrackSource source) {
    switch (source.type) {
      case 'Youtube':
        String videoId = source.data['id'];
        return YouTubeUtils.getAudioStream(videoId);
      default:
        throw UnsupportedTrackSourceException(source);
    }
  }

  // Obtain an audio stream url from a queue track instance
  // Returns null if no stream could be found.
  // Can throws NoConnectionException if no connection is currently available
  static Future<String> getAudioStreamForQueueTrack(QueueTrack track) async {
    if ((await _connectivity.checkConnectivity()) == ConnectivityResult.none)
      throw NoConnectionException();
    for (TrackSource source in track.track.sources) {
      try {
        String stream = await getAudioStreamForTrackSource(source);
        if (stream == null) continue;
        return stream;
      } catch (e) {
        if (e is UnsupportedTrackSourceException) {
          _log.warn(['An unsupported track source type was encountered', e]);
          continue;
        }
        if (e is SocketException) continue;
        rethrow;
      }
    }
    return null;
  }
}

// Exceptions

class ExtractionException implements Exception {}

class NoConnectionException implements Exception {}

class UnsupportedTrackSourceException implements Exception {
  TrackSource source;

  UnsupportedTrackSourceException(this.source);

  @override
  String toString() {
    return 'UnsupportedTrackSourceException{source: $source}';
  }
}
