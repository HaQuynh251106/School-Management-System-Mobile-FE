//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'exam_schedule.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ExamSchedule {
  /// Returns a new [ExamSchedule] instance.
  ExamSchedule({
    required this.id,

    required this.examPeriodId,

    required this.subjectId,

    required this.subjectName,

    required this.examDate,

    required this.startTime,

    required this.durationMinutes,

    this.notes,

    required this.classIds,
  });

  @JsonKey(name: r'id', required: true, includeIfNull: false)
  final String id;

  @JsonKey(name: r'examPeriodId', required: true, includeIfNull: false)
  final String examPeriodId;

  @JsonKey(name: r'subjectId', required: true, includeIfNull: false)
  final String subjectId;

  @JsonKey(name: r'subjectName', required: true, includeIfNull: false)
  final String subjectName;

  @JsonKey(name: r'examDate', required: true, includeIfNull: false)
  final DateTime examDate;

  @JsonKey(name: r'startTime', required: true, includeIfNull: false)
  final String startTime;

  // minimum: 15
  // maximum: 480
  @JsonKey(name: r'durationMinutes', required: true, includeIfNull: false)
  final int durationMinutes;

  @JsonKey(name: r'notes', required: false, includeIfNull: false)
  final String? notes;

  @JsonKey(name: r'classIds', required: true, includeIfNull: false)
  final Set<String> classIds;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExamSchedule &&
          other.id == id &&
          other.examPeriodId == examPeriodId &&
          other.subjectId == subjectId &&
          other.subjectName == subjectName &&
          other.examDate == examDate &&
          other.startTime == startTime &&
          other.durationMinutes == durationMinutes &&
          other.notes == notes &&
          other.classIds == classIds;

  @override
  int get hashCode =>
      id.hashCode +
      examPeriodId.hashCode +
      subjectId.hashCode +
      subjectName.hashCode +
      examDate.hashCode +
      startTime.hashCode +
      durationMinutes.hashCode +
      (notes == null ? 0 : notes.hashCode) +
      classIds.hashCode;

  factory ExamSchedule.fromJson(Map<String, dynamic> json) =>
      _$ExamScheduleFromJson(json);

  Map<String, dynamic> toJson() => _$ExamScheduleToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
