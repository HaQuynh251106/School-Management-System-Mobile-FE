//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'room.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class Room {
  /// Returns a new [Room] instance.
  Room({
    required this.id,

    required this.code,

    required this.name,

    this.capacity,

    required this.supportsMorning,

    required this.supportsAfternoon,
  });

  @JsonKey(name: r'id', required: true, includeIfNull: false)
  final String id;

  @JsonKey(name: r'code', required: true, includeIfNull: false)
  final String code;

  @JsonKey(name: r'name', required: true, includeIfNull: false)
  final String name;

  @JsonKey(name: r'capacity', required: false, includeIfNull: false)
  final int? capacity;

  @JsonKey(name: r'supportsMorning', required: true, includeIfNull: false)
  final bool supportsMorning;

  @JsonKey(name: r'supportsAfternoon', required: true, includeIfNull: false)
  final bool supportsAfternoon;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Room &&
          other.id == id &&
          other.code == code &&
          other.name == name &&
          other.capacity == capacity &&
          other.supportsMorning == supportsMorning &&
          other.supportsAfternoon == supportsAfternoon;

  @override
  int get hashCode =>
      id.hashCode +
      code.hashCode +
      name.hashCode +
      (capacity == null ? 0 : capacity.hashCode) +
      supportsMorning.hashCode +
      supportsAfternoon.hashCode;

  factory Room.fromJson(Map<String, dynamic> json) => _$RoomFromJson(json);

  Map<String, dynamic> toJson() => _$RoomToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
