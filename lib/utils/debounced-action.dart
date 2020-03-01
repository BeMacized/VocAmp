import 'package:flutter/widgets.dart';
import 'package:rxdart/rxdart.dart';

class DebouncedAction {
  Subject<void> _subject;
  Stream<void> _debouncedStream;

  DebouncedAction(
      {@required Duration duration, @required VoidCallback action}) {
    _subject = PublishSubject();
    _debouncedStream = _subject.debounceTime(duration).asBroadcastStream();
    _debouncedStream.listen((_) => action());
  }

  dispose() {
    _subject.close();
  }

  Future<void> next() {
    final emission = _debouncedStream.first;
    this._subject.add(null);
    return emission;
  }
}
