import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:voc_amp/models/utils/failure.dart';
import 'package:voc_amp/widgets/primary-button.dart';

class FailureBlock extends StatefulWidget {
  final Failure failure;
  final VoidCallback onRetry;

  const FailureBlock({
    Key key,
    @required this.failure,
    this.onRetry,
  }) : super(key: key);

  @override
  _FailureBlockState createState() => _FailureBlockState();
}

class _FailureBlockState extends State<FailureBlock> {
  String image;

  @override
  void initState() {
    super.initState();
    image = 'lib/assets/img/error${Random().nextInt(19)}.png';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(bottom: 24),
          child: SizedBox(
            width: 200,
            child: AspectRatio(
              aspectRatio: 1,
              child: Image(
                image: AssetImage(image),
              ),
            ),
          ),
        ),
        Text(
          widget.failure.title,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.display1,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 24),
          child: Text(
            widget.failure.message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.subhead,
          ),
        ),
        if (widget.failure.flags.contains(FailureFlag.retry) != null)
          Padding(
            padding: const EdgeInsets.only(top: 36),
            child: PrimaryButton(
              text: 'RETRY',
              onTap: widget.onRetry,
            ),
          ),
      ],
    );
  }
}
