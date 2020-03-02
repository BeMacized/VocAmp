import 'dart:io';

import 'package:voc_amp/background/utils/stream-utils.dart';
import 'package:voc_amp/utils/logger.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class YouTubeUtils {
  static YoutubeExplode _extractor = YoutubeExplode();
  static Logger _log = Logger('YouTubeUtils');

  // Get audio stream url for a youtube video id
  // Returns null if no stream could be found
  // Throws SocketException if youtube could not be reached
  static Future<String> getAudioStream(String videoId) async {
    try {
      _log.debug(['Extracting', videoId]);
      var streamInfo = (await _extractor.getVideoMediaStream(videoId));
      var streamUrl = streamInfo.audio
          .where(
            (stream) =>
                stream.url != null &&
                stream.audioEncoding != AudioEncoding.opus,
          )
          .map((stream) => stream.url.toString())
          .firstWhere((url) => url != null, orElse: () => null);

      _log.debug(['Result', streamUrl]);
      return streamUrl;
    } catch (e) {
      _log.severe([
        'Encountered an extraction exception',
        videoId,
        e,
        if (e is Error) e.stackTrace
      ]);
      throw YouTubeExtractionException(videoId, e);
    }
  }

  // Returns null if unsuccessful
  static String getVideoIdFromURL(String url) {
    return YoutubeExplode.parseVideoId(url);
  }
}

// Exceptions
class YouTubeExtractionException implements ExtractionException {
  String videoId;
  dynamic exception;

  YouTubeExtractionException(this.videoId, this.exception);

  @override
  String toString() {
    return 'YouTubeExtractionException{videoId: $videoId, exception: $exception}';
  }
}
