//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:sse_academic_api/src/model/teacher_exam_candidate.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'teacher_grading_task.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class TeacherGradingTask {
  /// Returns a new [TeacherGradingTask] instance.
  TeacherGradingTask({
    required this.examPeriodId,

    required this.examPeriodName,

    required this.scheduleId,

    required this.subjectId,

    required this.subjectName,

    required this.classId,

    required this.classCode,

    required this.examDate,

    required this.startTime,

    this.scoreEntryOpensAt,

    required this.scoreEntryAvailable,

    required this.scoreEntryLocked,

    required this.candidates,
  });

  @JsonKey(name: r'examPeriodId', required: true, includeIfNull: false)
  final String examPeriodId;

  @JsonKey(name: r'examPeriodName', required: true, includeIfNull: false)
  final String examPeriodName;

  @JsonKey(name: r'scheduleId', required: true, includeIfNull: false)
  final String scheduleId;

  @JsonKey(name: r'subjectId', required: true, includeIfNull: false)
  final String subjectId;

  @JsonKey(name: r'subjectName', required: true, includeIfNull: false)
  final String subjectName;

  @JsonKey(name: r'classId', required: true, includeIfNull: false)
  final String classId;

  @JsonKey(name: r'classCode', required: true, includeIfNull: false)
  final String classCode;

  @JsonKey(name: r'examDate', required: true, includeIfNull: false)
  final DateTime examDate;

  @JsonKey(name: r'startTime', required: true, includeIfNull: false)
  final String startTime;

  @JsonKey(name: r'scoreEntryOpensAt', required: false, includeIfNull: false)
  final DateTime? scoreEntryOpensAt;

  @JsonKey(name: r'scoreEntryAvailable', required: true, includeIfNull: false)
  final bool scoreEntryAvailable;

  @JsonKey(name: r'scoreEntryLocked', required: true, includeIfNull: false)
  final bool scoreEntryLocked;

  @JsonKey(name: r'candidates', required: true, includeIfNull: false)
  final List<TeacherExamCandidate> candidates;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TeacherGradingTask &&
          other.examPeriodId == examPeriodId &&
          other.examPeriodName == examPeriodName &&
          other.scheduleId == scheduleId &&
          other.subjectId == subjectId &&
          other.subjectName == subjectName &&
          other.classId == classId &&
          other.classCode == classCode &&
          other.examDate == examDate &&
          other.startTime == startTime &&
          other.scoreEntryOpensAt == scoreEntryOpensAt &&
          other.scoreEntryAvailable == scoreEntryAvailable &&
          other.scoreEntryLocked == scoreEntryLocked &&
          other.candidates == candidates;

  @override
  int get hashCode =>
      examPeriodId.hashCode +
      examPeriodName.hashCode +
      scheduleId.hashCode +
      subjectId.hashCode +
      subjectName.hashCode +
      classId.hashCode +
      classCode.hashCode +
      examDate.hashCode +
      startTime.hashCode +
      (scoreEntryOpensAt == null ? 0 : scoreEntryOpensAt.hashCode) +
      scoreEntryAvailable.hashCode +
      scoreEntryLocked.hashCode +
      candidates.hashCode;

  factory TeacherGradingTask.fromJson(Map<String, dynamic> json) =>
      _$TeacherGradingTaskFromJson(json);

  Map<String, dynamic> toJson() => _$TeacherGradingTaskToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
