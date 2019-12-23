import 'package:flutter/material.dart';
import 'package:voc_amp/models/media/track-list-image.dart';
import 'package:voc_amp/models/media/track-list.dart';
import 'package:voc_amp/repositories/track-list.repository.dart';
import 'package:voc_amp/repositories/vocadb-songs-api.repository.dart';

class TrackListProvider {
  final TrackListRepository _trackListRepository;

  TrackList tracksTopOverall;
  TrackList tracksTopYearly;
  TrackList tracksTopMonthly;
  TrackList tracksTopWeekly;
  TrackList tracksTopDaily;

  TrackList tracksNewReleases;
  TrackList tracksNewlyAdded;

  TrackListProvider(this._trackListRepository) {
    tracksTopOverall = TrackList(
      title: 'Top Tracks Overall',
      subtitle: 'The absolute best',
      image: TrackListImage(
        url: 'https://i.imgur.com/Y3MjVGI.png',
        text: ['Top Tracks', 'All Time'],
      ),
      fetchTracks: () {
        return _trackListRepository.getTopTracks(
          filteringMode: FilteringMode.popularity,
        );
      },
    );

    tracksTopYearly = TrackList(
      title: 'Tracks of the Year',
      subtitle: 'This year\'s hits',
      image: TrackListImage(
        url:
            'https://preview.redd.it/yjh482s8maa31.jpg?width=613&auto=webp&s=ae559021de74cf3e134f703e6f78af074f8cdbd9',
        text: ['Top Tracks', 'Yearly'],
      ),
      fetchTracks: () {
        return _trackListRepository.getTopTracks(
          filteringMode: FilteringMode.popularity,
          duration: Duration(days: 365),
        );
      },
    );

    tracksTopMonthly = TrackList(
      title: 'Top Monthly Tracks',
      subtitle: 'Popular right now',
      image: TrackListImage(
        url: 'https://i.imgur.com/GzcljUi.png',
        text: ['Top Tracks', 'Monthly'],
      ),
      fetchTracks: () {
        return _trackListRepository.getTopTracks(
          filteringMode: FilteringMode.popularity,
          duration: Duration(days: 31),
        );
      },
    );

    tracksTopWeekly = TrackList(
      title: 'Top Weekly Tracks',
      subtitle: 'Tracks of the week',
      image: TrackListImage(
        url: 'https://i.redd.it/fb5r6koqsja21.png',
        text: ['Top Tracks', 'Weekly'],
      ),
      fetchTracks: () {
        return _trackListRepository.getTopTracks(
          filteringMode: FilteringMode.popularity,
          duration: Duration(days: 7),
        );
      },
    );

    tracksTopDaily = TrackList(
      title: 'Top of Today',
      subtitle: 'What\'s popular today?',
      image: TrackListImage(
        url: 'https://i.redd.it/9zp4oh3w4e041.jpg',
        text: ['Top Tracks', 'Daily'],
      ),
      fetchTracks: () {
        return _trackListRepository.getTopTracks(
          filteringMode: FilteringMode.popularity,
          duration: Duration(days: 1),
        );
      },
    );

    tracksNewReleases = TrackList(
      title: 'Newly Released',
      subtitle: 'Freshly baked tunes',
      image: TrackListImage(
        url: 'https://i.imgur.com/QytVrdo.png',
        text: ['New', 'Releases'],
      ),
      fetchTracks: () {
        return _trackListRepository.getTopTracks(
          filteringMode: FilteringMode.newlyPublished,
        );
      },
    );

    tracksNewlyAdded = TrackList(
      title: 'Newly Added Tracks',
      subtitle: 'Recently made available',
      image: TrackListImage(
        url: 'https://i.imgur.com/srDrnof.png',
        text: ['Newly', 'Added'],
        gradientColor: Color.lerp(Colors.blue.shade900, Colors.black, 0.7)
            .withOpacity(0.8),
        textColor: Colors.white,
      ),
      fetchTracks: () {
        return _trackListRepository.getTopTracks(
          filteringMode: FilteringMode.newlyAdded,
        );
      },
    );
  }
}
