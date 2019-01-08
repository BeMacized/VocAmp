import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class CenterToast extends StatefulWidget {
  static Future<void> showToast(
    BuildContext context, {
    IconData icon,
    String text,
    Duration duration = const Duration(seconds: 3),
    Duration fadeDuration = const Duration(milliseconds: 500),
  }) async {
    OverlayState overlay = Overlay.of(context);
    OverlayEntry toast = OverlayEntry(
        builder: (BuildContext context) => CenterToast(
            icon: icon,
            text: text,
            duration: duration,
            fadeDuration: fadeDuration));
    overlay.insert(toast);
    await Future.delayed(duration);
    toast.remove();
  }

  final String text;
  final IconData icon;
  final Duration duration;
  final Duration fadeDuration;

  CenterToast({
    this.text,
    this.icon,
    this.duration = const Duration(seconds: 3),
    this.fadeDuration = const Duration(milliseconds: 1000),
  }) {
    assert(fadeDuration.inMilliseconds <= duration.inMilliseconds / 2);
  }

  @override
  _CenterToastState createState() => _CenterToastState();
}

class _CenterToastState extends State<CenterToast> {
  @override
  initState() {
    super.initState();
    init();
  }

  init() async {
    await Future.delayed(Duration(milliseconds: 1));
    setState(() {
      _visible = true;
    });
    await Future.delayed(Duration(
        milliseconds: widget.duration.inMilliseconds -
            widget.fadeDuration.inMilliseconds));
    setState(() {
      _visible = false;
    });
  }

  bool _visible = false;

  @override
  Widget build(BuildContext context) {
    List<Widget> items = [];
    if (widget.icon != null) {
      items.add(Padding(
        padding: const EdgeInsets.all(8.0),
        child: Icon(
          widget.icon,
          size: 70,
        ),
      ));
    }
    if (widget.text != null) {
      items.add(Text(
        widget.text,
        style: TextStyle(),
        textAlign: TextAlign.center,
      ));
    }
    return Center(
      child: AnimatedOpacity(
        child: SizedBox(
          height: 180,
          width: 180,
          child: Card(
            color: Colors.grey.shade900,
            elevation: 5,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: items,
              ),
            ),
          ),
        ),
        duration: widget.fadeDuration,
        opacity: _visible ? 0.9 : 0.0,
      ),
    );
  }
}
