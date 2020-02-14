import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:voc_amp/utils/gradient-utils.dart';

const double _APPBAR_HEIGHT = 56.0;
const double _ACTION_HEIGHT = 44.0;

class DynamicHeader extends StatefulWidget {
  final Widget action;
  final Widget content;
  final Widget title;
  final Color bgColor;
  final Widget barLeading;
  final List<Widget> barActions;

  DynamicHeader({
    this.action,
    this.content,
    this.title,
    this.bgColor = Colors.white,
    this.barLeading,
    this.barActions,
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
        barLeading: widget.barLeading,
        barActions: widget.barActions,
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
  Widget barLeading;
  List<Widget> barActions;
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
    this.barLeading,
    this.barActions,
  });

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
      child: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: barLeading,
        actions: barActions,
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
          child: Stack(
            children: <Widget>[
              Container(color: Colors.black),
              DynamicHeaderBackground(color: bgColor, collapsed: collapsed),
              ClipRect(
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
            ],
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

class DynamicHeaderBackground extends ImplicitlyAnimatedWidget {
  final Color color;
  final double collapsed;

  DynamicHeaderBackground({
    @required this.color,
    @required this.collapsed,
    Duration duration = const Duration(milliseconds: 500),
    Curve curve = Curves.easeInOut,
  }) : super(duration: duration, curve: curve);

  @override
  _DynamicHeaderBackgroundState createState() =>
      _DynamicHeaderBackgroundState();
}

class _DynamicHeaderBackgroundState
    extends AnimatedWidgetBaseState<DynamicHeaderBackground> {
  ColorTween baseColorTween;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: GradientUtils.curved([
            _calculateBGColor(widget.collapsed),
            Colors.black,
          ], curve: Curves.easeInOut),
        ),
      ),
    );
  }

  Color _calculateBGColor(double collapsed) {
    assert(collapsed >= 0 && collapsed <= 1.0);
    HSLColor bgHSL = HSLColor.fromColor(baseColorTween.evaluate(animation));
    double minLightness = 0.2;
    double maxLightness = max(min(bgHSL.lightness, 0.6), minLightness);
    double lightness = bgHSL.lightness == 0
        ? 0
        : (1.0 - collapsed) * (maxLightness - minLightness) + minLightness;
    return bgHSL.withLightness(lightness).toColor();
  }

  @override
  void forEachTween(visitor) {
    baseColorTween = visitor(
      baseColorTween,
      widget.color,
      (value) => ColorTween(begin: value),
    );
  }
}
