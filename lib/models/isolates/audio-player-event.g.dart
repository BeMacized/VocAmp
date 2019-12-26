// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'audio-player-event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AudioPlayerEvent _$AudioPlayerEventFromJson(Map<String, dynamic> json) {
  return AudioPlayerEvent()
    ..action = json['action'] as String
    ..payload = json['payload'] as Map<String, dynamic>;
}

Map<String, dynamic> _$AudioPlayerEventToJson(AudioPlayerEvent instance) =>
    <String, dynamic>{
      'action': instance.action,
      'payload': instance.payload,
    };
