//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'create_room_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CreateRoomRequest {
  /// Returns a new [CreateRoomRequest] instance.
  CreateRoomRequest({
    this.id,

    required this.code,

    this.name,

    this.capacity,

    this.supportsMorning,

    this.supportsAfternoon,
  });

  @JsonKey(name: r'id', required: false, includeIfNull: false)
  final String? id;

  @JsonKey(name: r'code', required: true, includeIfNull: false)
  final String code;

  @JsonKey(name: r'name', required: false, includeIfNull: false)
  final String? name;

  // minimum: 1
  // maximum: 1000
  @JsonKey(name: r'capacity', required: false, includeIfNull: false)
  final int? capacity;

  @JsonKey(name: r'supportsMorning', required: false, includeIfNull: false)
  final bool? supportsMorning;

  @JsonKey(name: r'supportsAfternoon', required: false, includeIfNull: false)
  final bool? supportsAfternoon;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreateRoomRequest &&
          other.id == id &&
          other.code == code &&
          other.name == name &&
          other.capacity == capacity &&
          other.supportsMorning == supportsMorning &&
          other.supportsAfternoon == supportsAfternoon;

  @override
  int get hashCode =>
      (id == null ? 0 : id.hashCode) +
      code.hashCode +
      (name == null ? 0 : name.hashCode) +
      (capacity == null ? 0 : capacity.hashCode) +
      (supportsMorning == null ? 0 : supportsMorning.hashCode) +
      (supportsAfternoon == null ? 0 : supportsAfternoon.hashCode);

  factory CreateRoomRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateRoomRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreateRoomRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
