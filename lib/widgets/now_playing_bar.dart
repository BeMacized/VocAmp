import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:vocaloid_player/globals.dart';
import 'package:vocaloid_player/redux/app_state.dart';
import 'package:vocaloid_player/widgets/scrolling_text.dart';

class _ViewModel {
  PlayerState playerState;
  Function(dynamic) dispatch;

  _ViewModel(this.playerState, this.dispatch);

  viewCurrentlyPlaying() {}
}

class NowPlayingBar extends StatefulWidget {
  @override
  NowPlayingBarState createState() {
    return new NowPlayingBarState();
  }
}

class NowPlayingBarState extends State<NowPlayingBar> {
  double verticalDrag = 0;
  bool dragging = false;

  IconData _getPlaybackButtonIcon(BasicPlaybackState state) {
    switch (state) {
      case BasicPlaybackState.buffering:
      case BasicPlaybackState.playing:
        return Icons.pause_circle_outline;
      case BasicPlaybackState.paused:
        return Icons.play_circle_outline;
      default:
        return Icons.play_circle_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return new StoreConnector<AppState, _ViewModel>(converter: (store) {
      return _ViewModel(store.state.playerState, store.dispatch);
    }, builder: (context, vm) {
      double progressValue = 0;
      if (vm.playerState.state == BasicPlaybackState.buffering)
        progressValue = null;
      else if (vm.playerState.duration.inMilliseconds > 0)
        progressValue = vm.playerState.position.inMilliseconds /
            vm.playerState.duration.inMilliseconds;

      return vm.playerState.currentSong == null
          ? Container(width: 0.0, height: 0.0)
          : SizedBox(
              width: double.infinity,
              height: 56,
              child: Column(
                children: <Widget>[
                  SizedBox(
                    width: double.infinity,
                    height: 2,
                    child: LinearProgressIndicator(
                      value: progressValue,
                      backgroundColor: Colors.grey.shade800,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      color: Colors.grey.shade900,
                      child: Material(
                        color: Colors.transparent,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onVerticalDragStart: (details) {
                            verticalDrag = 0;
                            dragging = true;
                          },
                          onVerticalDragUpdate: (details) {
                            verticalDrag += details.primaryDelta;
                            if (verticalDrag > -50) return;
                            dragging = false;
                            verticalDrag = 0;
                            Application.navigator.pushNamed('/nowplaying');
                          },
                          onTap: () =>
                              Application.navigator.pushNamed('/nowplaying'),
                          child: Row(
                            children: <Widget>[
                              IconButton(
                                icon: Icon(
                                  Icons.keyboard_arrow_up,
                                  color: Colors.white,
                                ),
                                onPressed: () => Application.navigator
                                    .pushNamed('/nowplaying'),
                              ),
                              Expanded(
                                child: Center(
                                  child: ScrollingText(
                                    TextSpan(
                                      children: [
                                        TextSpan(
                                            text: vm.playerState.currentSong
                                                .song.name),
                                        TextSpan(
                                          text: ' ⸱ ',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        TextSpan(
                                          text: vm.playerState.currentSong.song
                                              .artistString,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                    key: ObjectKey(vm.playerState.currentSong),
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  _getPlaybackButtonIcon(vm.playerState.state),
                                  color: Colors.white,
                                ),
                                onPressed: () =>
                                    Application.audioManager.playPause(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: 1,
                    child: Container(
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            );
    });
  }
}
