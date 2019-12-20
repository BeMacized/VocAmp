import 'dart:math';

import 'package:flutter/widgets.dart';

class Pressable extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final Duration duration;
  final Curve curve;

  Pressable({
    @required this.child,
    this.onTap,
    this.duration = const Duration(milliseconds: 150),
    this.curve = Curves.easeOutCubic,
  }) : assert(child != null);

  @override
  _PressableState createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool pressed = false;
  DateTime lastPressed = DateTime.fromMicrosecondsSinceEpoch(0);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onTap == null
          ? null
          : (_) => setState(() {
                pressed = true;
                lastPressed = DateTime.now();
              }),
      onTapCancel: () {
        Future.delayed(_calcMinTimeUntilDepress()).then((_) {
          setState(() => pressed = false);
        });
      },
      onTapUp: (_) {
        Future.delayed(_calcMinTimeUntilDepress()).then((_) {
          setState(() => pressed = false);
        });
      },
      onTap: widget.onTap,
      child: _AnimatedPressable(
        child: widget.child,
        duration: widget.duration,
        curve: widget.curve,
        pressed: pressed,
      ),
    );
  }

  Duration _calcMinTimeUntilDepress() {
    return Duration(
      milliseconds: max(
        500 -
            (DateTime.now().millisecondsSinceEpoch -
                lastPressed.millisecondsSinceEpoch),
        0,
      ),
    );
  }
}

class _AnimatedPressable extends ImplicitlyAnimatedWidget {
  final bool pressed;
  final Widget child;

  _AnimatedPressable({
    @required this.child,
    @required Duration duration,
    Curve curve = Curves.linear,
    this.pressed,
  }) : super(duration: duration, curve: curve);

  @override
  ImplicitlyAnimatedWidgetState<ImplicitlyAnimatedWidget> createState() {
    return _AnimatedPressableState();
  }
}

class _AnimatedPressableState
    extends AnimatedWidgetBaseState<_AnimatedPressable> {
  Tween _scaleTween;
  Tween _opacityTween;

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: _scaleTween.evaluate(animation),
      child: Opacity(
        opacity: _opacityTween.evaluate(animation),
        child: widget.child,
      ),
    );
  }

  @override
  void forEachTween(visitor) {
    _scaleTween = visitor(_scaleTween, widget.pressed ? 0.9 : 1.0,
        (dynamic value) => Tween(begin: value));
    _opacityTween = visitor(_opacityTween, widget.pressed ? 0.5 : 1.0,
        (dynamic value) => Tween(begin: value));
  }
}
