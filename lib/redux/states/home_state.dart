import 'package:meta/meta.dart';

class HomeState {
  int tab;

  HomeState({@required this.tab});

  HomeState copyWith({int tab}) {
    return HomeState(
      tab: tab ?? this.tab,
    );
  }

  factory HomeState.initial() => HomeState(tab: 0);
}
