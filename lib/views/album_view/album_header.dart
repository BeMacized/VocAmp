import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:vocaloid_player/globals.dart';
import 'package:vocaloid_player/views/album_view/album_view_model.dart';
import 'package:vocaloid_player/widgets/album_art.dart';

class AlbumHeader extends StatelessWidget {
  final AlbumViewModel vm;

  const AlbumHeader(
    this.vm, {
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double contentHeight = 360;
    return SliverAppBar(
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      brightness: Brightness.dark,
      title: vm.album?.name != null
          ? Text(
              vm.album.name,
              style: TextStyle(color: Colors.white.withAlpha(255)),
            )
          : null,
      leading: Application.navigator.canPop()
          ? IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: Application.navigator.pop,
            )
          : null,
      actions: <Widget>[
        PopupMenuButton<String>(
          onSelected: (item) {
            switch (item) {
              case 'QUEUE':
                vm.queueAlbum(context);
                break;
              case 'PLAY_NEXT':
                vm.playAlbumNext(context);
                break;
            }
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'QUEUE',
                  child: ListTile(
                    title: Text('Queue Album'),
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'PLAY_NEXT',
                  child: ListTile(
                    title: Text('Play Next'),
                  ),
                ),
              ],
        )
      ],
      expandedHeight: contentHeight,
      flexibleSpace: AlbumHeaderContent(contentHeight: contentHeight, vm: vm),
      bottom: vm.loading ? null : HeaderButton(vm),
    );
  }
}

class AlbumHeaderContent extends StatefulWidget {
  final double contentHeight;
  final AlbumViewModel vm;

  AlbumHeaderContent({@required this.contentHeight, @required this.vm});

  static Widget createSettings({
    double toolbarOpacity,
    double minExtent,
    double maxExtent,
    @required double currentExtent,
    @required Widget child,
  }) {
    return FlexibleSpaceBarSettings(
      toolbarOpacity: toolbarOpacity ?? 1.0,
      minExtent: minExtent ?? currentExtent,
      maxExtent: maxExtent ?? currentExtent,
      currentExtent: currentExtent,
      child: child,
    );
  }

  @override
  _AlbumHeaderContentState createState() => _AlbumHeaderContentState();
}

class _AlbumHeaderContentState extends State<AlbumHeaderContent> {
  Color fadeColor;
  PaletteGenerator gen;

  Future<void> _refreshFadeColor({ImageProvider imageProvider}) async {
    if (imageProvider == null) return Colors.grey.shade800;
    await Future.delayed(Duration(milliseconds: 100)); // Wait for imageProvider
    PaletteGenerator gen =
        await PaletteGenerator.fromImageProvider(imageProvider);
    setState(() {
      fadeColor = (gen.vibrantColor ??
                  gen.darkVibrantColor ??
                  gen.lightVibrantColor ??
                  gen.mutedColor ??
                  gen.darkMutedColor ??
                  gen.lightMutedColor ??
                  gen.dominantColor)
              ?.color ??
          Colors.grey.shade800;
      this.gen = gen;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Calculate collapsed state
    final FlexibleSpaceBarSettings settings =
        context.inheritFromWidgetOfExactType(FlexibleSpaceBarSettings);
    final double deltaExtent = settings.maxExtent - settings.minExtent;
    final double collapsed =
        (1.0 - (settings.currentExtent - settings.minExtent) / deltaExtent)
            .clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: ClipRect(
        child: OverflowBox(
          alignment: Alignment.topCenter,
          minHeight: widget.contentHeight,
          maxHeight: widget.contentHeight,
          child: Stack(
            children: <Widget>[
              AnimatedOpacity(
                opacity: fadeColor != null ? 1.0 : 0.0,
                duration: Duration(milliseconds: 1500),
                curve: Curves.ease,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: <Color>[
                        Color.lerp(fadeColor, Colors.black, collapsed / 4),
                        Colors.black
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),
              Transform.translate(
                offset: Offset(0, collapsed * 50),
                child: Opacity(
                  opacity: 1.0 - collapsed,
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: kToolbarHeight + MediaQuery.of(context).padding.top,
                      bottom: 24,
                    ),
                    child: Container(
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Container(
                              width: 150,
                              height: 150,
                              decoration: BoxDecoration(boxShadow: [
                                BoxShadow(
                                    color: Colors.black,
                                    blurRadius: 20,
                                    spreadRadius: 5,
                                    offset: Offset(0, 10))
                              ]),
                              child: Column(
                                children: <Widget>[
                                  AlbumArt(
                                    albumImageUrl: widget.vm.album?.mainPicture?.urlThumb,
                                    size: 150,
                                    loadedCallback: (imageProvider) =>
                                        _refreshFadeColor(
                                            imageProvider: imageProvider),
                                    failedCallback: _refreshFadeColor,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 16, left: 16, right: 16),
                            child: widget.vm.album?.name != null
                                ? Text(
                                    widget.vm.album.name,
                                    softWrap: false,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                : null,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 8, left: 16, right: 16),
                            child: widget.vm.album?.artistString != null
                                ? Text(
                                    "ALBUM BY " + widget.vm.album.artistString,
                                    softWrap: false,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.white.withOpacity(0.75),
                                    ),
                                  )
                                : null,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HeaderButton extends PreferredSize {
  final AlbumViewModel vm;

  const HeaderButton(this.vm, {Key key, Widget child})
      : super(preferredSize: const Size.fromHeight(48), child: child, key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: Center(
        child: RaisedButton(
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 32),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
          onPressed: vm.playAlbum,
          child: Text(
            "PLAY ALL",
            style: TextStyle(
              fontWeight: FontWeight.w900,
              letterSpacing: 2.5,
            ),
          ),
        ),
      ),
    );
  }
}
