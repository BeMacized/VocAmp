
import 'package:flutter/widgets.dart';

class PressAnimation extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  PressAnimation({
    @required this.child,
    this.onTap,
  });

  @override
  _PressAnimationState createState() => _PressAnimationState();
}

class _PressAnimationState extends State<PressAnimation>
    with TickerProviderStateMixin {
  Animation<double> _animation;
  AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    final CurvedAnimation curve = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
    _animation = Tween(begin: 0.0, end: 1.0).animate(curve);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown:
          widget.onTap != null ? (details) => _controller.forward() : null,
      onTapUp: widget.onTap != null
          ? (details) async {
              await Future.delayed(Duration(milliseconds: 100));
              _controller.reverse();
            }
          : null,
      onTapCancel: _controller.reverse,
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (BuildContext context, Widget child) {
          return Opacity(
            opacity: 1.0 - _animation.value * 0.4,
            child: Transform.scale(
              scale: 1.0 - _animation.value * 0.1,
              child: widget.child,
              alignment: Alignment.center,
            ),
          );
        },
      ),
    );
  }
}