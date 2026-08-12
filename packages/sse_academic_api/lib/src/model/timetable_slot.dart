//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'timetable_slot.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class TimetableSlot {
  /// Returns a new [TimetableSlot] instance.
  TimetableSlot({
    required this.id,

    required this.classId,

    this.classCode,

    this.studyShift,

    required this.subjectId,

    required this.subjectName,

    required this.teacherId,

    required this.teacherName,

    required this.roomCode,

    required this.dayOfWeek,

    required this.periodNo,

    required this.startTime,

    required this.endTime,

    this.semesterId,

    this.publishedPlanId,

    required this.locked,
  });

  @JsonKey(name: r'id', required: true, includeIfNull: false)
  final String id;

  @JsonKey(name: r'classId', required: true, includeIfNull: false)
  final String classId;

  @JsonKey(name: r'classCode', required: false, includeIfNull: false)
  final String? classCode;

  @JsonKey(name: r'studyShift', required: false, includeIfNull: false)
  final String? studyShift;

  @JsonKey(name: r'subjectId', required: true, includeIfNull: false)
  final String subjectId;

  @JsonKey(name: r'subjectName', required: true, includeIfNull: false)
  final String subjectName;

  @JsonKey(name: r'teacherId', required: true, includeIfNull: false)
  final String teacherId;

  @JsonKey(name: r'teacherName', required: true, includeIfNull: false)
  final String teacherName;

  @JsonKey(name: r'roomCode', required: true, includeIfNull: false)
  final String roomCode;

  @JsonKey(name: r'dayOfWeek', required: true, includeIfNull: false)
  final String dayOfWeek;

  @JsonKey(name: r'periodNo', required: true, includeIfNull: false)
  final int periodNo;

  @JsonKey(name: r'startTime', required: true, includeIfNull: false)
  final String startTime;

  @JsonKey(name: r'endTime', required: true, includeIfNull: false)
  final String endTime;

  @JsonKey(name: r'semesterId', required: false, includeIfNull: false)
  final String? semesterId;

  @JsonKey(name: r'publishedPlanId', required: false, includeIfNull: false)
  final String? publishedPlanId;

  @JsonKey(name: r'locked', required: true, includeIfNull: false)
  final bool locked;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TimetableSlot &&
          other.id == id &&
          other.classId == classId &&
          other.classCode == classCode &&
          other.studyShift == studyShift &&
          other.subjectId == subjectId &&
          other.subjectName == subjectName &&
          other.teacherId == teacherId &&
          other.teacherName == teacherName &&
          other.roomCode == roomCode &&
          other.dayOfWeek == dayOfWeek &&
          other.periodNo == periodNo &&
          other.startTime == startTime &&
          other.endTime == endTime &&
          other.semesterId == semesterId &&
          other.publishedPlanId == publishedPlanId &&
          other.locked == locked;

  @override
  int get hashCode =>
      id.hashCode +
      classId.hashCode +
      (classCode == null ? 0 : classCode.hashCode) +
      (studyShift == null ? 0 : studyShift.hashCode) +
      subjectId.hashCode +
      subjectName.hashCode +
      teacherId.hashCode +
      teacherName.hashCode +
      roomCode.hashCode +
      dayOfWeek.hashCode +
      periodNo.hashCode +
      startTime.hashCode +
      endTime.hashCode +
      (semesterId == null ? 0 : semesterId.hashCode) +
      (publishedPlanId == null ? 0 : publishedPlanId.hashCode) +
      locked.hashCode;

  factory TimetableSlot.fromJson(Map<String, dynamic> json) =>
      _$TimetableSlotFromJson(json);

  Map<String, dynamic> toJson() => _$TimetableSlotToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
