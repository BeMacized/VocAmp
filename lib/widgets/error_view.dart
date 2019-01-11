import 'package:flutter/widgets.dart';
import 'package:vocaloid_player/redux/app_state.dart';

class ErrorView extends StatelessWidget {
  ErrorState errorState;

  ErrorView(this.errorState);

  @override
  Widget build(BuildContext context) {
    List<Widget> content = [];

    if (errorState.icon != null)
      content.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0),
          child: Icon(
            errorState.icon,
            size: 96,
          ),
        ),
      );

    if (errorState.title != null)
      content.add(
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            errorState.title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 25
            ),
          ),
        ),
      );

    if (errorState.subtitle != null)
      content.add(
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            errorState.subtitle,
          ),
        ),
      );

    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: content,
      ),
    );
  }
}
