//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'exam_review.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ExamReview {
  /// Returns a new [ExamReview] instance.
  ExamReview({
    required this.id,

    required this.examPeriodId,

    required this.resultId,

    required this.studentId,

    required this.studentName,

    required this.subjectId,

    required this.subjectName,

    this.originalScore,

    required this.reason,

    required this.status,

    this.resolution,

    this.resolvedScore,

    required this.requestedAt,

    required this.requestedBy,

    this.resolvedAt,

    this.resolvedBy,
  });

  @JsonKey(name: r'id', required: true, includeIfNull: false)
  final String id;

  @JsonKey(name: r'examPeriodId', required: true, includeIfNull: false)
  final String examPeriodId;

  @JsonKey(name: r'resultId', required: true, includeIfNull: false)
  final String resultId;

  @JsonKey(name: r'studentId', required: true, includeIfNull: false)
  final String studentId;

  @JsonKey(name: r'studentName', required: true, includeIfNull: false)
  final String studentName;

  @JsonKey(name: r'subjectId', required: true, includeIfNull: false)
  final String subjectId;

  @JsonKey(name: r'subjectName', required: true, includeIfNull: false)
  final String subjectName;

  @JsonKey(name: r'originalScore', required: false, includeIfNull: false)
  final num? originalScore;

  @JsonKey(name: r'reason', required: true, includeIfNull: false)
  final String reason;

  @JsonKey(name: r'status', required: true, includeIfNull: false)
  final String status;

  @JsonKey(name: r'resolution', required: false, includeIfNull: false)
  final String? resolution;

  @JsonKey(name: r'resolvedScore', required: false, includeIfNull: false)
  final num? resolvedScore;

  @JsonKey(name: r'requestedAt', required: true, includeIfNull: false)
  final DateTime requestedAt;

  @JsonKey(name: r'requestedBy', required: true, includeIfNull: false)
  final String requestedBy;

  @JsonKey(name: r'resolvedAt', required: false, includeIfNull: false)
  final DateTime? resolvedAt;

  @JsonKey(name: r'resolvedBy', required: false, includeIfNull: false)
  final String? resolvedBy;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExamReview &&
          other.id == id &&
          other.examPeriodId == examPeriodId &&
          other.resultId == resultId &&
          other.studentId == studentId &&
          other.studentName == studentName &&
          other.subjectId == subjectId &&
          other.subjectName == subjectName &&
          other.originalScore == originalScore &&
          other.reason == reason &&
          other.status == status &&
          other.resolution == resolution &&
          other.resolvedScore == resolvedScore &&
          other.requestedAt == requestedAt &&
          other.requestedBy == requestedBy &&
          other.resolvedAt == resolvedAt &&
          other.resolvedBy == resolvedBy;

  @override
  int get hashCode =>
      id.hashCode +
      examPeriodId.hashCode +
      resultId.hashCode +
      studentId.hashCode +
      studentName.hashCode +
      subjectId.hashCode +
      subjectName.hashCode +
      (originalScore == null ? 0 : originalScore.hashCode) +
      reason.hashCode +
      status.hashCode +
      (resolution == null ? 0 : resolution.hashCode) +
      (resolvedScore == null ? 0 : resolvedScore.hashCode) +
      requestedAt.hashCode +
      requestedBy.hashCode +
      (resolvedAt == null ? 0 : resolvedAt.hashCode) +
      (resolvedBy == null ? 0 : resolvedBy.hashCode);

  factory ExamReview.fromJson(Map<String, dynamic> json) =>
      _$ExamReviewFromJson(json);

  Map<String, dynamic> toJson() => _$ExamReviewToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
