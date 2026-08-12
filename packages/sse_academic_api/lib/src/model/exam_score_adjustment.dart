//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'exam_score_adjustment.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ExamScoreAdjustment {
  /// Returns a new [ExamScoreAdjustment] instance.
  ExamScoreAdjustment({
    required this.id,

    required this.examPeriodId,

    required this.resultId,

    this.reviewRequestId,

    this.oldScore,

    this.newScore,

    required this.reason,

    required this.adjustedAt,

    required this.adjustedBy,
  });

  @JsonKey(name: r'id', required: true, includeIfNull: false)
  final String id;

  @JsonKey(name: r'examPeriodId', required: true, includeIfNull: false)
  final String examPeriodId;

  @JsonKey(name: r'resultId', required: true, includeIfNull: false)
  final String resultId;

  @JsonKey(name: r'reviewRequestId', required: false, includeIfNull: false)
  final String? reviewRequestId;

  // minimum: 0
  // maximum: 10
  @JsonKey(name: r'oldScore', required: false, includeIfNull: false)
  final num? oldScore;

  // minimum: 0
  // maximum: 10
  @JsonKey(name: r'newScore', required: false, includeIfNull: false)
  final num? newScore;

  @JsonKey(name: r'reason', required: true, includeIfNull: false)
  final String reason;

  @JsonKey(name: r'adjustedAt', required: true, includeIfNull: false)
  final DateTime adjustedAt;

  @JsonKey(name: r'adjustedBy', required: true, includeIfNull: false)
  final String adjustedBy;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExamScoreAdjustment &&
          other.id == id &&
          other.examPeriodId == examPeriodId &&
          other.resultId == resultId &&
          other.reviewRequestId == reviewRequestId &&
          other.oldScore == oldScore &&
          other.newScore == newScore &&
          other.reason == reason &&
          other.adjustedAt == adjustedAt &&
          other.adjustedBy == adjustedBy;

  @override
  int get hashCode =>
      id.hashCode +
      examPeriodId.hashCode +
      resultId.hashCode +
      (reviewRequestId == null ? 0 : reviewRequestId.hashCode) +
      (oldScore == null ? 0 : oldScore.hashCode) +
      (newScore == null ? 0 : newScore.hashCode) +
      reason.hashCode +
      adjustedAt.hashCode +
      adjustedBy.hashCode;

  factory ExamScoreAdjustment.fromJson(Map<String, dynamic> json) =>
      _$ExamScoreAdjustmentFromJson(json);

  Map<String, dynamic> toJson() => _$ExamScoreAdjustmentToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
