//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'save_timetable_slot_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SaveTimetableSlotRequest {
  /// Returns a new [SaveTimetableSlotRequest] instance.
  SaveTimetableSlotRequest({
    this.id,

    required this.classId,

    required this.subjectId,

    required this.teacherId,

    this.roomCode,

    required this.dayOfWeek,

    required this.periodNo,

    required this.startTime,

    required this.endTime,

    required this.semesterId,
  });

  @JsonKey(name: r'id', required: false, includeIfNull: false)
  final String? id;

  @JsonKey(name: r'classId', required: true, includeIfNull: false)
  final String classId;

  @JsonKey(name: r'subjectId', required: true, includeIfNull: false)
  final String subjectId;

  @JsonKey(name: r'teacherId', required: true, includeIfNull: false)
  final String teacherId;

  @JsonKey(name: r'roomCode', required: false, includeIfNull: false)
  final String? roomCode;

  @JsonKey(name: r'dayOfWeek', required: true, includeIfNull: false)
  final String dayOfWeek;

  // minimum: 1
  // maximum: 12
  @JsonKey(name: r'periodNo', required: true, includeIfNull: false)
  final int periodNo;

  @JsonKey(name: r'startTime', required: true, includeIfNull: false)
  final String startTime;

  @JsonKey(name: r'endTime', required: true, includeIfNull: false)
  final String endTime;

  @JsonKey(name: r'semesterId', required: true, includeIfNull: false)
  final String semesterId;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SaveTimetableSlotRequest &&
          other.id == id &&
          other.classId == classId &&
          other.subjectId == subjectId &&
          other.teacherId == teacherId &&
          other.roomCode == roomCode &&
          other.dayOfWeek == dayOfWeek &&
          other.periodNo == periodNo &&
          other.startTime == startTime &&
          other.endTime == endTime &&
          other.semesterId == semesterId;

  @override
  int get hashCode =>
      (id == null ? 0 : id.hashCode) +
      classId.hashCode +
      subjectId.hashCode +
      teacherId.hashCode +
      (roomCode == null ? 0 : roomCode.hashCode) +
      dayOfWeek.hashCode +
      periodNo.hashCode +
      startTime.hashCode +
      endTime.hashCode +
      semesterId.hashCode;

  factory SaveTimetableSlotRequest.fromJson(Map<String, dynamic> json) =>
      _$SaveTimetableSlotRequestFromJson(json);

  Map<String, dynamic> toJson() => _$SaveTimetableSlotRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
