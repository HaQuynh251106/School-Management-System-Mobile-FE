//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:sse_academic_api/src/model/exam_period.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'exam_period_summary.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ExamPeriodSummary {
  /// Returns a new [ExamPeriodSummary] instance.
  ExamPeriodSummary({
    required this.period,

    required this.scheduleCount,

    required this.roomCount,

    required this.candidateCount,

    required this.resultCount,

    required this.pendingReviewCount,
  });

  @JsonKey(name: r'period', required: true, includeIfNull: false)
  final ExamPeriod period;

  @JsonKey(name: r'scheduleCount', required: true, includeIfNull: false)
  final int scheduleCount;

  @JsonKey(name: r'roomCount', required: true, includeIfNull: false)
  final int roomCount;

  @JsonKey(name: r'candidateCount', required: true, includeIfNull: false)
  final int candidateCount;

  @JsonKey(name: r'resultCount', required: true, includeIfNull: false)
  final int resultCount;

  @JsonKey(name: r'pendingReviewCount', required: true, includeIfNull: false)
  final int pendingReviewCount;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExamPeriodSummary &&
          other.period == period &&
          other.scheduleCount == scheduleCount &&
          other.roomCount == roomCount &&
          other.candidateCount == candidateCount &&
          other.resultCount == resultCount &&
          other.pendingReviewCount == pendingReviewCount;

  @override
  int get hashCode =>
      period.hashCode +
      scheduleCount.hashCode +
      roomCount.hashCode +
      candidateCount.hashCode +
      resultCount.hashCode +
      pendingReviewCount.hashCode;

  factory ExamPeriodSummary.fromJson(Map<String, dynamic> json) =>
      _$ExamPeriodSummaryFromJson(json);

  Map<String, dynamic> toJson() => _$ExamPeriodSummaryToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
