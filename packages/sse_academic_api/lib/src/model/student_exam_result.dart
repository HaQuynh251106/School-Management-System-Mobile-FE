//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'student_exam_result.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class StudentExamResult {
  /// Returns a new [StudentExamResult] instance.
  StudentExamResult({
    required this.resultId,

    required this.examPeriodId,

    required this.examPeriodName,

    required this.scheduleId,

    required this.subjectId,

    required this.subjectName,

    this.score,

    this.note,

    required this.resultStatus,

    this.reviewId,

    this.reviewStatus,

    this.reviewReason,

    this.reviewResolution,

    this.resolvedScore,
  });

  @JsonKey(name: r'resultId', required: true, includeIfNull: false)
  final String resultId;

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

  // minimum: 0
  // maximum: 10
  @JsonKey(name: r'score', required: false, includeIfNull: false)
  final num? score;

  @JsonKey(name: r'note', required: false, includeIfNull: false)
  final String? note;

  @JsonKey(name: r'resultStatus', required: true, includeIfNull: false)
  final String resultStatus;

  @JsonKey(name: r'reviewId', required: false, includeIfNull: false)
  final String? reviewId;

  @JsonKey(name: r'reviewStatus', required: false, includeIfNull: false)
  final String? reviewStatus;

  @JsonKey(name: r'reviewReason', required: false, includeIfNull: false)
  final String? reviewReason;

  @JsonKey(name: r'reviewResolution', required: false, includeIfNull: false)
  final String? reviewResolution;

  // minimum: 0
  // maximum: 10
  @JsonKey(name: r'resolvedScore', required: false, includeIfNull: false)
  final num? resolvedScore;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StudentExamResult &&
          other.resultId == resultId &&
          other.examPeriodId == examPeriodId &&
          other.examPeriodName == examPeriodName &&
          other.scheduleId == scheduleId &&
          other.subjectId == subjectId &&
          other.subjectName == subjectName &&
          other.score == score &&
          other.note == note &&
          other.resultStatus == resultStatus &&
          other.reviewId == reviewId &&
          other.reviewStatus == reviewStatus &&
          other.reviewReason == reviewReason &&
          other.reviewResolution == reviewResolution &&
          other.resolvedScore == resolvedScore;

  @override
  int get hashCode =>
      resultId.hashCode +
      examPeriodId.hashCode +
      examPeriodName.hashCode +
      scheduleId.hashCode +
      subjectId.hashCode +
      subjectName.hashCode +
      (score == null ? 0 : score.hashCode) +
      (note == null ? 0 : note.hashCode) +
      resultStatus.hashCode +
      (reviewId == null ? 0 : reviewId.hashCode) +
      (reviewStatus == null ? 0 : reviewStatus.hashCode) +
      (reviewReason == null ? 0 : reviewReason.hashCode) +
      (reviewResolution == null ? 0 : reviewResolution.hashCode) +
      (resolvedScore == null ? 0 : resolvedScore.hashCode);

  factory StudentExamResult.fromJson(Map<String, dynamic> json) =>
      _$StudentExamResultFromJson(json);

  Map<String, dynamic> toJson() => _$StudentExamResultToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
