import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:voc_amp/utils/gradient-utils.dart';

const double _APPBAR_HEIGHT = 56.0;
const double _ACTION_HEIGHT = 44.0;

class DynamicHeader extends StatefulWidget {
  final Widget action;
  final Widget content;
  final Widget title;
  final Color bgColor;

  DynamicHeader({
    this.action,
    this.content,
    this.title,
    this.bgColor = Colors.white,
  });

  @override
  _DynamicHeaderState createState() => _DynamicHeaderState();
}

class _DynamicHeaderState extends State<DynamicHeader> {
  double minExtent = 0;
  double maxExtent = 0;
  GlobalKey<State> contentKey = GlobalKey<State>();

  @override
  initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        recalcExtents();
      });
    });
    super.initState();
  }

  recalcExtents() {
    double contentHeight = contentKey?.currentContext?.size?.height ?? 0;
    minExtent =
        MediaQuery.of(context).padding.top + _APPBAR_HEIGHT + _ACTION_HEIGHT;
    maxExtent = max(minExtent, contentHeight + _ACTION_HEIGHT);
  }

  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      pinned: true,
      floating: false,
      delegate: DynamicHeaderDelegate(
        minExtent: minExtent,
        maxExtent: maxExtent,
        topPadding: MediaQuery.of(context).padding.top,
        contentKey: contentKey,
        content: widget.content,
        action: widget.action,
        bgColor: widget.bgColor,
        title: widget.title,
      ),
    );
  }
}

class DynamicHeaderDelegate extends SliverPersistentHeaderDelegate {
  GlobalKey contentKey;
  double topPadding = 0;
  Widget content;
  Widget action;
  Widget title;
  Color bgColor;
  @override
  double maxExtent = 0;
  @override
  double minExtent = 0;

  DynamicHeaderDelegate({
    @required this.contentKey,
    @required this.minExtent,
    @required this.maxExtent,
    @required this.topPadding,
    @required this.action,
    @required this.content,
    @required this.bgColor,
    @required this.title,
  }) {
    // Cap BG color lightness
    HSLColor bgHSL = HSLColor.fromColor(this.bgColor);
    if (bgHSL.lightness > 0.6) {
      this.bgColor = bgHSL.withLightness(0.6).toColor();
    }
  }

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: <Widget>[
        _buildContents(context, shrinkOffset),
        action ?? Container(),
        _buildBar(context, shrinkOffset),
      ],
    );
  }

  Widget _buildBar(BuildContext context, double shrinkOffset) {
    double collapsed = (maxExtent - minExtent) > 0
        ? (shrinkOffset / (maxExtent - minExtent)).clamp(0.0, 1.0)
        : 0;
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      height: _APPBAR_HEIGHT + topPadding,
      child: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: AnimatedOpacity(
          duration: Duration(
            milliseconds: 150,
          ),
          opacity: collapsed,
          child: title,
        ),
      ),
    );
  }

  Widget _buildContents(BuildContext context, double shrinkOffset) {
    double collapsed = (maxExtent - minExtent) > 0
        ? (shrinkOffset / (maxExtent - minExtent)).clamp(0.0, 1.0)
        : 0;
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: ClipRect(
        child: OverflowBox(
          alignment: Alignment.topCenter,
          minHeight: maxExtent,
          maxHeight: maxExtent,
          child: AnimatedContainer(
            duration: Duration(milliseconds: 1000),
            curve: Curves.easeInOut,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: GradientUtils.curved([
                  bgColor,
                  Colors.black,
                ], curve: Curves.easeInOut),
              ),
            ),
            child: ClipRect(
              child: OverflowBox(
                alignment: Alignment.topCenter,
                maxHeight: double.infinity,
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: <Widget>[
                    Container(
                      key: contentKey,
                      child: Opacity(
                        opacity: 1.0 - collapsed,
                        child: Transform.scale(
                          scale: 1.0 - collapsed * 0.2,
                          child: Transform.translate(
                            offset: Offset(0, collapsed * 48),
                            child: Padding(
                              padding: EdgeInsets.only(
                                top: topPadding + _APPBAR_HEIGHT + 20,
                                bottom: 20,
                              ),
                              child: content ?? Container(),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
