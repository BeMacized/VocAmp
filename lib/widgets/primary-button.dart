import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:voc_amp/widgets/pressable.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final Color color;
  final Color textColor;

  PrimaryButton({
    @required this.text,
    this.onTap,
    this.color,
    this.textColor,
  }) : assert(text != null);

  @override
  Widget build(BuildContext context) {
    Color _bgColor = color ?? Theme.of(context).primaryColor;
    Color _textColor =
        textColor ?? Theme.of(context).primaryColor.computeLuminance() >= 0.5
            ? Colors.black
            : Colors.white;
    return Pressable(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: 44,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: _bgColor,
            borderRadius: BorderRadius.circular(40),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
            child: Text(
              'SHUFFLE',
              style: Theme.of(context)
                  .textTheme
                  .button
                  .copyWith(color: _textColor, height: 1.5),
            ),
          ),
        ),
      ),
    );
  }
}
