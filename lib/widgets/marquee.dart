import 'dart:async';

import 'package:flutter/material.dart';

enum MarqueeAlignment { start, center }

class Marquee extends StatefulWidget {
  final Widget child;
  final double repeatGap;
  final double fadeWidth;
  final double speed;
  final Duration repeatDelay;
  final Duration initialDelay;
  final Duration fadeDuration;
  final MarqueeAlignment alignment;

  Marquee({
    @required this.child,
    this.repeatGap = 24,
    this.fadeWidth = 32,
    this.speed = 1,
    this.repeatDelay = const Duration(seconds: 2),
    this.initialDelay = const Duration(seconds: 2),
    this.fadeDuration = const Duration(milliseconds: 150),
    this.alignment = MarqueeAlignment.center,
  });

  @override
  _MarqueeState createState() => _MarqueeState();
}

class _MarqueeState extends State<Marquee> {
  ScrollController scrollController;
  GlobalKey<State> childKey = new GlobalKey<State>();
  bool scrolling = false;

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();
    Future.delayed(widget.initialDelay).then((_) => startScrollLoop());
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  startScrollLoop() async {
    // Find widths
    double ownWidth =
        (this.context?.findRenderObject() as RenderBox)?.size?.width;
    double childWidth =
        (childKey?.currentContext?.findRenderObject() as RenderBox)
            ?.size
            ?.width;
    // If child is smaller than the scroll area, stop here.
    if (childWidth <= ownWidth) return;
    // Calculate distance and loop time
    double distance = childWidth + widget.repeatGap;
    Duration loopTime = Duration(
      milliseconds: (distance * 10 / widget.speed).ceil(),
    );
    // Start scrolling
    setState(() => scrolling = true);
    scrollController.jumpTo(0);
    await scrollController.animateTo(
      distance,
      duration: loopTime,
      curve: Curves.linear,
    );
    // Reset to start
    if (!mounted) return;
    scrollController.jumpTo(0);
    setState(() => scrolling = false);
    // Repeat
    await Future.delayed(widget.repeatDelay);
    startScrollLoop();
  }

  MainAxisAlignment get alignment {
    switch (widget.alignment) {
      case MarqueeAlignment.start:
        return MainAxisAlignment.start;
      case MarqueeAlignment.center:
      default:
        return MainAxisAlignment.center;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MarqueeFade(
      duration: widget.fadeDuration,
      curve: Curves.linear,
      active: scrolling,
      fadeWidth: widget.fadeWidth,
      child: LayoutBuilder(
        builder: (context, viewConstraints) {
          return SingleChildScrollView(
            controller: scrollController,
            physics: NeverScrollableScrollPhysics(),
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                ConstrainedBox(
                  key: childKey,
                  constraints: BoxConstraints(
                    minWidth: viewConstraints.maxWidth,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: alignment,
                    children: <Widget>[
                      widget.child,
                    ],
                  ),
                ),
                SizedBox(width: widget.repeatGap),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: viewConstraints.maxWidth,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: alignment,
                    children: <Widget>[
                      widget.child,
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class MarqueeFade extends ImplicitlyAnimatedWidget {
  final Widget child;
  final double fadeWidth;
  final bool active;

  MarqueeFade({
    @required this.child,
    @required this.fadeWidth,
    @required this.active,
    @required Duration duration,
    @required Curve curve,
  }) : super(duration: duration, curve: curve);

  @override
  _MarqueeFadeState createState() => _MarqueeFadeState();
}

class _MarqueeFadeState extends AnimatedWidgetBaseState<MarqueeFade> {
  Tween<double> fadeTween;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (Rect bounds) {
        List<double> maskStops = [
          0,
          widget.fadeWidth / bounds.width,
          1 - widget.fadeWidth / bounds.width,
          1
        ];
        return LinearGradient(
          colors: [
            Colors.white.withOpacity(fadeTween.evaluate(animation)),
            Colors.white,
            Colors.white,
            Colors.white.withOpacity(fadeTween.evaluate(animation)),
          ],
          stops: maskStops,
        ).createShader(bounds);
      },
      child: widget.child,
    );
  }

  @override
  void forEachTween(visitor) {
    fadeTween = visitor(
      fadeTween,
      widget.active ? 0.0 : 1.0,
      (value) => Tween<double>(begin: value),
    );
  }
}
