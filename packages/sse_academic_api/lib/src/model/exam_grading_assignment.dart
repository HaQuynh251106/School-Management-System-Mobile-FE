//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'exam_grading_assignment.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ExamGradingAssignment {
  /// Returns a new [ExamGradingAssignment] instance.
  ExamGradingAssignment({
    required this.id,

    required this.examPeriodId,

    required this.scheduleId,

    required this.classId,

    required this.classCode,

    required this.subjectId,

    required this.subjectName,

    required this.teacherId,

    required this.teacherName,

    required this.assignedAt,

    this.assignedBy,
  });

  @JsonKey(name: r'id', required: true, includeIfNull: false)
  final String id;

  @JsonKey(name: r'examPeriodId', required: true, includeIfNull: false)
  final String examPeriodId;

  @JsonKey(name: r'scheduleId', required: true, includeIfNull: false)
  final String scheduleId;

  @JsonKey(name: r'classId', required: true, includeIfNull: false)
  final String classId;

  @JsonKey(name: r'classCode', required: true, includeIfNull: false)
  final String classCode;

  @JsonKey(name: r'subjectId', required: true, includeIfNull: false)
  final String subjectId;

  @JsonKey(name: r'subjectName', required: true, includeIfNull: false)
  final String subjectName;

  @JsonKey(name: r'teacherId', required: true, includeIfNull: false)
  final String teacherId;

  @JsonKey(name: r'teacherName', required: true, includeIfNull: false)
  final String teacherName;

  @JsonKey(name: r'assignedAt', required: true, includeIfNull: false)
  final DateTime assignedAt;

  @JsonKey(name: r'assignedBy', required: false, includeIfNull: false)
  final String? assignedBy;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExamGradingAssignment &&
          other.id == id &&
          other.examPeriodId == examPeriodId &&
          other.scheduleId == scheduleId &&
          other.classId == classId &&
          other.classCode == classCode &&
          other.subjectId == subjectId &&
          other.subjectName == subjectName &&
          other.teacherId == teacherId &&
          other.teacherName == teacherName &&
          other.assignedAt == assignedAt &&
          other.assignedBy == assignedBy;

  @override
  int get hashCode =>
      id.hashCode +
      examPeriodId.hashCode +
      scheduleId.hashCode +
      classId.hashCode +
      classCode.hashCode +
      subjectId.hashCode +
      subjectName.hashCode +
      teacherId.hashCode +
      teacherName.hashCode +
      assignedAt.hashCode +
      (assignedBy == null ? 0 : assignedBy.hashCode);

  factory ExamGradingAssignment.fromJson(Map<String, dynamic> json) =>
      _$ExamGradingAssignmentFromJson(json);

  Map<String, dynamic> toJson() => _$ExamGradingAssignmentToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
