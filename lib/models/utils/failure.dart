import 'package:flutter/foundation.dart';

enum FailureFlag {
  retry
}

class Failure {
  final String code;
  final String title;
  final String message;
  final List<FailureFlag> flags;

  Failure({
    @required this.message,
    this.code,
    this.title = 'Uh Oh...',
    this.flags = const [],
  });

  @override
  String toString() {
    return 'Failure{code: $code, title: $title, message: $message, flags: $flags}';
  }
}
