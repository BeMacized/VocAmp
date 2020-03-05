import 'package:json_annotation/json_annotation.dart';

part 'repeat-mode.g.dart';

@JsonSerializable()
class RepeatMode {
  static final NONE = RepeatMode._internal('NONE');
  static final SINGLE = RepeatMode._internal('SINGLE');
  static final ALL = RepeatMode._internal('ALL');

  String mode;

  RepeatMode() : mode = 'NONE';

  RepeatMode._internal(this.mode);

  factory RepeatMode.fromJson(Map<String, dynamic> json) =>
      _$RepeatModeFromJson(json);

  Map<String, dynamic> toJson() => _$RepeatModeToJson(this);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RepeatMode &&
          runtimeType == other.runtimeType &&
          mode == other.mode;

  @override
  int get hashCode => mode.hashCode;
}
