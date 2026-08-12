//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'teaching_assignment.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class TeachingAssignment {
  /// Returns a new [TeachingAssignment] instance.
  TeachingAssignment({
    required this.id,

    required this.classId,

    this.classCode,

    required this.subjectId,

    this.subjectName,

    required this.teacherId,

    this.teacherName,

    required this.semesterId,

    required this.weeklyPeriods,

    required this.scheduledPeriods,

    required this.remainingPeriods,

    required this.teacherClassCount,

    required this.teacherWeeklyPeriods,

    required this.teacherScheduledPeriods,

    required this.fullyScheduled,

    required this.teacherBusy,

    required this.canSchedule,

    this.availabilityMessage,

    this.assignedAt,

    this.assignedBy,

    this.updatedAt,
  });

  @JsonKey(name: r'id', required: true, includeIfNull: false)
  final String id;

  @JsonKey(name: r'classId', required: true, includeIfNull: false)
  final String classId;

  @JsonKey(name: r'classCode', required: false, includeIfNull: false)
  final String? classCode;

  @JsonKey(name: r'subjectId', required: true, includeIfNull: false)
  final String subjectId;

  @JsonKey(name: r'subjectName', required: false, includeIfNull: false)
  final String? subjectName;

  @JsonKey(name: r'teacherId', required: true, includeIfNull: false)
  final String teacherId;

  @JsonKey(name: r'teacherName', required: false, includeIfNull: false)
  final String? teacherName;

  @JsonKey(name: r'semesterId', required: true, includeIfNull: false)
  final String semesterId;

  @JsonKey(name: r'weeklyPeriods', required: true, includeIfNull: false)
  final int weeklyPeriods;

  @JsonKey(name: r'scheduledPeriods', required: true, includeIfNull: false)
  final int scheduledPeriods;

  @JsonKey(name: r'remainingPeriods', required: true, includeIfNull: false)
  final int remainingPeriods;

  @JsonKey(name: r'teacherClassCount', required: true, includeIfNull: false)
  final int teacherClassCount;

  @JsonKey(name: r'teacherWeeklyPeriods', required: true, includeIfNull: false)
  final int teacherWeeklyPeriods;

  @JsonKey(
    name: r'teacherScheduledPeriods',
    required: true,
    includeIfNull: false,
  )
  final int teacherScheduledPeriods;

  @JsonKey(name: r'fullyScheduled', required: true, includeIfNull: false)
  final bool fullyScheduled;

  @JsonKey(name: r'teacherBusy', required: true, includeIfNull: false)
  final bool teacherBusy;

  @JsonKey(name: r'canSchedule', required: true, includeIfNull: false)
  final bool canSchedule;

  @JsonKey(name: r'availabilityMessage', required: false, includeIfNull: false)
  final String? availabilityMessage;

  @JsonKey(name: r'assignedAt', required: false, includeIfNull: false)
  final DateTime? assignedAt;

  @JsonKey(name: r'assignedBy', required: false, includeIfNull: false)
  final String? assignedBy;

  @JsonKey(name: r'updatedAt', required: false, includeIfNull: false)
  final DateTime? updatedAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TeachingAssignment &&
          other.id == id &&
          other.classId == classId &&
          other.classCode == classCode &&
          other.subjectId == subjectId &&
          other.subjectName == subjectName &&
          other.teacherId == teacherId &&
          other.teacherName == teacherName &&
          other.semesterId == semesterId &&
          other.weeklyPeriods == weeklyPeriods &&
          other.scheduledPeriods == scheduledPeriods &&
          other.remainingPeriods == remainingPeriods &&
          other.teacherClassCount == teacherClassCount &&
          other.teacherWeeklyPeriods == teacherWeeklyPeriods &&
          other.teacherScheduledPeriods == teacherScheduledPeriods &&
          other.fullyScheduled == fullyScheduled &&
          other.teacherBusy == teacherBusy &&
          other.canSchedule == canSchedule &&
          other.availabilityMessage == availabilityMessage &&
          other.assignedAt == assignedAt &&
          other.assignedBy == assignedBy &&
          other.updatedAt == updatedAt;

  @override
  int get hashCode =>
      id.hashCode +
      classId.hashCode +
      (classCode == null ? 0 : classCode.hashCode) +
      subjectId.hashCode +
      (subjectName == null ? 0 : subjectName.hashCode) +
      teacherId.hashCode +
      (teacherName == null ? 0 : teacherName.hashCode) +
      semesterId.hashCode +
      weeklyPeriods.hashCode +
      scheduledPeriods.hashCode +
      remainingPeriods.hashCode +
      teacherClassCount.hashCode +
      teacherWeeklyPeriods.hashCode +
      teacherScheduledPeriods.hashCode +
      fullyScheduled.hashCode +
      teacherBusy.hashCode +
      canSchedule.hashCode +
      (availabilityMessage == null ? 0 : availabilityMessage.hashCode) +
      (assignedAt == null ? 0 : assignedAt.hashCode) +
      (assignedBy == null ? 0 : assignedBy.hashCode) +
      (updatedAt == null ? 0 : updatedAt.hashCode);

  factory TeachingAssignment.fromJson(Map<String, dynamic> json) =>
      _$TeachingAssignmentFromJson(json);

  Map<String, dynamic> toJson() => _$TeachingAssignmentToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
