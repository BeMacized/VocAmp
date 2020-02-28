class Logger {
  String tag;

  Logger(this.tag);

  debug(dynamic messages) {
    _log(this.tag, 'DEBUG', messages);
  }

  info(dynamic messages) {
    _log(this.tag, 'INFO', messages);
  }

  warn(dynamic messages) {
    _log(this.tag, 'WARN', messages);
  }

  severe(dynamic messages) {
    _log(this.tag, 'SEVERE', messages);
  }

  _log(String tag, String level, dynamic messages) {
    if (messages is List) messages = messages.join(' ');
    print('$level [$tag] $messages');
  }
}
