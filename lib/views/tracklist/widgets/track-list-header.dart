import 'package:cached_network_image/cached_network_image.dart';
import 'package:color_thief_flutter/color_thief_flutter.dart';
import 'package:flutter/material.dart';
import 'package:voc_amp/models/media/track-list.dart';
import 'package:voc_amp/widgets/dynamic-header.dart';
import 'package:voc_amp/widgets/primary-button.dart';
import 'dart:ui' as ui;

class TrackListHeader extends StatefulWidget {
  final TrackList trackList;
  final VoidCallback onAction;
  final String action;

  TrackListHeader({
    @required this.trackList,
    this.action,
    this.onAction,
  });

  @override
  _TrackListHeaderState createState() => _TrackListHeaderState();
}

class _TrackListHeaderState extends State<TrackListHeader> {
  Color bgColor = Colors.black;

  @override
  void initState() {
    super.initState();
    _updateBgColor();
  }

  @override
  void didUpdateWidget(TrackListHeader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget?.trackList != widget?.trackList) {
      _updateBgColor();
    }
  }

  void _updateBgColor() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      ui.Image img = await getImageFromProvider(
        CachedNetworkImageProvider(widget.trackList.image.url),
      );
      try {
        List<int> rgb = await getColorFromImage(img);
        if (mounted)
          setState(
            () => this.bgColor = Color.fromARGB(255, rgb[0], rgb[1], rgb[2]),
          );
      } catch (e) {
        print(e);
        if (mounted) setState(() => this.bgColor = Colors.grey.shade800);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return DynamicHeader(
      bgColor: bgColor,
      title: Text(
        widget.trackList.title,
        style: Theme.of(context).textTheme.subtitle,
      ),
      action: widget.action != null
          ? PrimaryButton(text: widget.action, onTap: widget.onAction)
          : null,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Material(
            elevation: 16,
            child: SizedBox(
              width: 160,
              height: 160,
              child: widget.trackList.image.buildWidget(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: 20,
              right: 20,
              top: 24,
              bottom: 10,
            ),
            child: Text(
              widget.trackList.title,
              style: Theme.of(context).textTheme.title,
              textAlign: TextAlign.center,
            ),
          ),
          if (widget.trackList.subtitle != null &&
              widget.trackList.subtitle.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(
                left: 20,
                right: 20,
                bottom: 10,
              ),
              child: Text(
                widget.trackList.subtitle,
                style: Theme.of(context).textTheme.subtitle,
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }
}
