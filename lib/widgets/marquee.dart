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
    this.fadeWidth = 24,
    this.speed = 1,
    this.repeatDelay = const Duration(seconds: 2),
    this.initialDelay = const Duration(seconds: 2),
    this.fadeDuration = const Duration(milliseconds: 150),
    this.alignment = MarqueeAlignment.center,
  });

  @override
  _MarqueeState createState() => _MarqueeState();
}

class _MarqueeState extends State<Marquee> with WidgetsBindingObserver {
  ScrollController scrollController;
  GlobalKey<State> childKey = new GlobalKey<State>();
  bool scrolling = false;
  bool willScroll = false;
  bool _firstScroll = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    scrollController = ScrollController();
    startScrollLoop();
  }

  @override
  void dispose() {
    scrollController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    this.startScrollLoop();
  }

  startScrollLoop() async {
    await Future.delayed(Duration(milliseconds: 0));
    // Find widths
    double ownWidth =
        (this.context?.findRenderObject() as RenderBox)?.size?.width;
    double childWidth =
        (childKey?.currentContext?.findRenderObject() as RenderBox)
            ?.size
            ?.width;
    // If child is smaller than the scroll area, stop here.
    if (childWidth <= ownWidth) {
      if (willScroll) setState(() => willScroll = false);
      return;
    }
    if (!willScroll) setState(() => willScroll = true);
    // Initial delay
    if (_firstScroll) {
      _firstScroll = false;
      await Future.delayed(widget.initialDelay);
    }
    // Calculate distance and loop time
    double distance = childWidth + widget.repeatGap;
    Duration loopTime = Duration(
      milliseconds: (distance * 20 / widget.speed).ceil(),
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
      leftActive: scrolling,
      rightActive: willScroll,
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
  final bool leftActive;
  final bool rightActive;

  MarqueeFade({
    @required this.child,
    @required this.fadeWidth,
    @required this.leftActive,
    @required this.rightActive,
    @required Duration duration,
    @required Curve curve,
  }) : super(duration: duration, curve: curve);

  @override
  _MarqueeFadeState createState() => _MarqueeFadeState();
}

class _MarqueeFadeState extends AnimatedWidgetBaseState<MarqueeFade> {
  Tween<double> rightFadeTween;
  Tween<double> leftFadeTween;

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
            Colors.white.withOpacity(leftFadeTween.evaluate(animation)),
            Colors.white,
            Colors.white,
            Colors.white.withOpacity(rightFadeTween.evaluate(animation)),
          ],
          stops: maskStops,
        ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height));
      },
      child: widget.child,
    );
  }

  @override
  void forEachTween(visitor) {
    rightFadeTween = visitor(
      rightFadeTween,
      widget.rightActive ? 0.0 : 1.0,
      (value) => Tween<double>(begin: value),
    );
    leftFadeTween = visitor(
      leftFadeTween,
      widget.leftActive ? 0.0 : 1.0,
      (value) => Tween<double>(begin: value),
    );
  }
}
