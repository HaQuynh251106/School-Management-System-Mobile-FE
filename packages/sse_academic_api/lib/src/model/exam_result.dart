//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'exam_result.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ExamResult {
  /// Returns a new [ExamResult] instance.
  ExamResult({
    required this.id,

    required this.examPeriodId,

    required this.scheduleId,

    required this.studentId,

    required this.subjectId,

    this.score,

    required this.status,

    this.note,

    this.recordedAt,

    this.recordedBy,

    this.updatedAt,

    this.updatedBy,

    required this.version,
  });

  @JsonKey(name: r'id', required: true, includeIfNull: false)
  final String id;

  @JsonKey(name: r'examPeriodId', required: true, includeIfNull: false)
  final String examPeriodId;

  @JsonKey(name: r'scheduleId', required: true, includeIfNull: false)
  final String scheduleId;

  @JsonKey(name: r'studentId', required: true, includeIfNull: false)
  final String studentId;

  @JsonKey(name: r'subjectId', required: true, includeIfNull: false)
  final String subjectId;

  // minimum: 0
  // maximum: 10
  @JsonKey(name: r'score', required: false, includeIfNull: false)
  final num? score;

  @JsonKey(name: r'status', required: true, includeIfNull: false)
  final String status;

  @JsonKey(name: r'note', required: false, includeIfNull: false)
  final String? note;

  @JsonKey(name: r'recordedAt', required: false, includeIfNull: false)
  final DateTime? recordedAt;

  @JsonKey(name: r'recordedBy', required: false, includeIfNull: false)
  final String? recordedBy;

  @JsonKey(name: r'updatedAt', required: false, includeIfNull: false)
  final DateTime? updatedAt;

  @JsonKey(name: r'updatedBy', required: false, includeIfNull: false)
  final String? updatedBy;

  @JsonKey(name: r'version', required: true, includeIfNull: false)
  final int version;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExamResult &&
          other.id == id &&
          other.examPeriodId == examPeriodId &&
          other.scheduleId == scheduleId &&
          other.studentId == studentId &&
          other.subjectId == subjectId &&
          other.score == score &&
          other.status == status &&
          other.note == note &&
          other.recordedAt == recordedAt &&
          other.recordedBy == recordedBy &&
          other.updatedAt == updatedAt &&
          other.updatedBy == updatedBy &&
          other.version == version;

  @override
  int get hashCode =>
      id.hashCode +
      examPeriodId.hashCode +
      scheduleId.hashCode +
      studentId.hashCode +
      subjectId.hashCode +
      (score == null ? 0 : score.hashCode) +
      status.hashCode +
      (note == null ? 0 : note.hashCode) +
      (recordedAt == null ? 0 : recordedAt.hashCode) +
      (recordedBy == null ? 0 : recordedBy.hashCode) +
      (updatedAt == null ? 0 : updatedAt.hashCode) +
      (updatedBy == null ? 0 : updatedBy.hashCode) +
      version.hashCode;

  factory ExamResult.fromJson(Map<String, dynamic> json) =>
      _$ExamResultFromJson(json);

  Map<String, dynamic> toJson() => _$ExamResultToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
