import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class ScrollingText extends StatefulWidget {
  // The speed of the scrolling animation
  final double speed;

  // The width of the spacer in between the two instances of text
  final double spacerWidth;

  // The length of the fadeouts on the sides when scrolling
  final double fadeLength;

  // The delay between each scoll. Set to 0 to continuously scroll
  final Duration repeatDelay;

  // The TextSpan to animate
  final TextSpan text;

  // The alignment for text that is too short to animate
  final Alignment alignment;

  ScrollingText(
    this.text, {
    Key key,
    this.speed = 1,
    this.spacerWidth = 48,
    this.repeatDelay = const Duration(seconds: 2),
    this.fadeLength = 15.0,
    this.alignment = Alignment.center,
  }) : super(key: key);

  @override
  _ScrollingTextState createState() => _ScrollingTextState();
}

class _ScrollingTextState extends State<ScrollingText>
    with SingleTickerProviderStateMixin {
  AnimationController animationController;
  Animation animation;
  double textWidth;
  bool kickstarted = false;
  bool shouldAnimate;

  @override
  void initState() {
    super.initState();
    // Initialize the animation controller
    animationController = AnimationController(vsync: this);
    // Add listener to repeat the animation upon completion
    animationController.addStatusListener((status) async {
      if (status == AnimationStatus.completed) {
        // Add repeat delay
        await Future.delayed(widget.repeatDelay);
        // Replay animation
        if (this.mounted) {
          animationController.value = 0;
          animationController.forward();
        }
      }
    });
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  void kickstart() async {
    // If we've already kickstarted the animation, don't do it again
    if (kickstarted) return;
    kickstarted = true;
    // Await repeat delay
    await Future.delayed(widget.repeatDelay);
    // Play animation
    if (this.mounted) animationController.forward();
  }

  Shader _fadeOffShaderCallback(Rect bounds) {
    bounds = Rect.fromLTWH(0, 0, bounds.width, bounds.height);
    // Static "gradient"
    if (!shouldAnimate) {
      return LinearGradient(
        colors: [Colors.transparent, Colors.transparent],
      ).createShader(bounds);
    }
    // Scrolling gradient
    double fadeFracLength = (widget.fadeLength / bounds.width);
    return LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        tileMode: TileMode.repeated,
        colors: [
          Colors.white.withOpacity(_getShaderOpacity()),
          Colors.transparent,
          Colors.transparent,
          Colors.white
        ],
        stops: [
          0.0,
          0.0 + fadeFracLength,
          1.0 - fadeFracLength,
          1.0,
        ]).createShader(bounds);
  }

  double _getShaderOpacity() {
    int duration = animationController.duration.inMilliseconds;
    double cutoff = 100 / duration;
    double value = animationController.value;
    if (value <= cutoff)
      return value / cutoff;
    else if (value >= 1.0 - cutoff)
      return (-(value - 1)) / cutoff;
    else
      return 1;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: LayoutBuilder(
        builder: _buildAll,
      ),
    );
  }

  Widget _buildAll(BuildContext context, BoxConstraints constraints) {
    // Calculate text width
    textWidth = _calculateTextWidth(constraints);
    // Determine if we should animate for this text width
    shouldAnimate = textWidth >= constraints.maxWidth;

    // Generate animation & duration, & kickstart animation if we should
    if (shouldAnimate) {
      animation =
          Tween<double>(begin: 0, end: (textWidth + widget.spacerWidth) * -1)
              .animate(animationController);
      animationController.duration = Duration(
          milliseconds: (textWidth / (50 * widget.speed) * 1000).floor());
      kickstart();
    }

    return Container(
      child: ShaderMask(
        shaderCallback: _fadeOffShaderCallback,
        blendMode: BlendMode.dstOut,
        child: Container(
          width: shouldAnimate ? constraints.maxWidth : null,
          child: ClipRect(
            child: OverflowBox(
              alignment:
                  shouldAnimate ? Alignment.centerLeft : widget.alignment,
              maxWidth: double.infinity,
              child: shouldAnimate
                  ? AnimatedBuilder(
                      builder: _buildAnimation,
                      animation: animation,
                    )
                  : _buildAnimation(context, null),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimation(BuildContext context, Widget child) {
    // Define text widget, two needed for animation
    Widget text = Text.rich(
      widget.text,
      softWrap: false,
    );
    // Define row children, at least one text
    List<Widget> rowChildren = [text];
    // If we are animating, we add a spacer and another text object
    if (shouldAnimate) {
      rowChildren.addAll([
        Container(width: widget.spacerWidth),
        text,
      ]);
    }
    // Return the row with the proper translation based on the animation progression
    return Transform.translate(
      offset: Offset(shouldAnimate ? animation.value as double : 0.0, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: rowChildren,
      ),
    );
  }

  double _calculateTextWidth(BoxConstraints constraints) {
    // Build rich text widget
    RichText text =
        Text.rich(widget.text, softWrap: false).build(context) as RichText;
    // Obtain render object for built widget
    final textRenderObject = text.createRenderObject(context);
    // Layout the render object with no constraints imposed
    textRenderObject.layout(
        BoxConstraints(maxWidth: double.infinity, maxHeight: double.infinity));
    // "Select" the entire text to obtain boxes for each line
    // Only one should be returned as the text object does not wrap.
    // The "right" property of the only box returned should reflect the length of the text object.
    return textRenderObject
        .getBoxesForSelection(TextSelection(
            baseOffset: 0, extentOffset: widget.text.toPlainText().length))
        .last
        .right;
  }
}
