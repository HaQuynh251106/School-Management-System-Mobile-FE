//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'exam_room.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ExamRoom {
  /// Returns a new [ExamRoom] instance.
  ExamRoom({
    required this.id,

    required this.scheduleId,

    required this.roomCode,

    required this.capacity,

    this.proctorOneId,

    this.proctorOneName,

    this.proctorTwoId,

    this.proctorTwoName,
  });

  @JsonKey(name: r'id', required: true, includeIfNull: false)
  final String id;

  @JsonKey(name: r'scheduleId', required: true, includeIfNull: false)
  final String scheduleId;

  @JsonKey(name: r'roomCode', required: true, includeIfNull: false)
  final String roomCode;

  // minimum: 1
  // maximum: 1000
  @JsonKey(name: r'capacity', required: true, includeIfNull: false)
  final int capacity;

  @JsonKey(name: r'proctorOneId', required: false, includeIfNull: false)
  final String? proctorOneId;

  @JsonKey(name: r'proctorOneName', required: false, includeIfNull: false)
  final String? proctorOneName;

  @JsonKey(name: r'proctorTwoId', required: false, includeIfNull: false)
  final String? proctorTwoId;

  @JsonKey(name: r'proctorTwoName', required: false, includeIfNull: false)
  final String? proctorTwoName;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExamRoom &&
          other.id == id &&
          other.scheduleId == scheduleId &&
          other.roomCode == roomCode &&
          other.capacity == capacity &&
          other.proctorOneId == proctorOneId &&
          other.proctorOneName == proctorOneName &&
          other.proctorTwoId == proctorTwoId &&
          other.proctorTwoName == proctorTwoName;

  @override
  int get hashCode =>
      id.hashCode +
      scheduleId.hashCode +
      roomCode.hashCode +
      capacity.hashCode +
      (proctorOneId == null ? 0 : proctorOneId.hashCode) +
      (proctorOneName == null ? 0 : proctorOneName.hashCode) +
      (proctorTwoId == null ? 0 : proctorTwoId.hashCode) +
      (proctorTwoName == null ? 0 : proctorTwoName.hashCode);

  factory ExamRoom.fromJson(Map<String, dynamic> json) =>
      _$ExamRoomFromJson(json);

  Map<String, dynamic> toJson() => _$ExamRoomToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
