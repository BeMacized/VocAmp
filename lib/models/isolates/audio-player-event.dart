import 'package:json_annotation/json_annotation.dart';

part 'audio-player-event.g.dart';

@JsonSerializable()
class AudioPlayerEvent {
  String action;
  Map<String, dynamic> payload;

  AudioPlayerEvent();

  factory AudioPlayerEvent.build(String action, [dynamic payload]) =>
      AudioPlayerEvent()
        ..action = action
        ..payload = payload;

  factory AudioPlayerEvent.fromJson(Map<String, dynamic> json) =>
      _$AudioPlayerEventFromJson(json);

  Map<String, dynamic> toJson() => _$AudioPlayerEventToJson(this);
}
