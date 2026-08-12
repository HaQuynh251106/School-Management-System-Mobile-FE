//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'year_rollover_result.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class YearRolloverResult {
  /// Returns a new [YearRolloverResult] instance.
  YearRolloverResult({
    required this.closedYearId,

    required this.nextYearId,

    required this.nextYearCode,

    required this.createdSemesterCount,

    required this.createdClassCount,

    required this.promotedCount,

    required this.retainedCount,

    required this.graduatedCount,

    required this.nextYearActivated,

    required this.completedAt,
  });

  @JsonKey(name: r'closedYearId', required: true, includeIfNull: false)
  final String closedYearId;

  @JsonKey(name: r'nextYearId', required: true, includeIfNull: false)
  final String nextYearId;

  @JsonKey(name: r'nextYearCode', required: true, includeIfNull: false)
  final String nextYearCode;

  @JsonKey(name: r'createdSemesterCount', required: true, includeIfNull: false)
  final int createdSemesterCount;

  @JsonKey(name: r'createdClassCount', required: true, includeIfNull: false)
  final int createdClassCount;

  @JsonKey(name: r'promotedCount', required: true, includeIfNull: false)
  final int promotedCount;

  @JsonKey(name: r'retainedCount', required: true, includeIfNull: false)
  final int retainedCount;

  @JsonKey(name: r'graduatedCount', required: true, includeIfNull: false)
  final int graduatedCount;

  @JsonKey(name: r'nextYearActivated', required: true, includeIfNull: false)
  final bool nextYearActivated;

  @JsonKey(name: r'completedAt', required: true, includeIfNull: false)
  final DateTime completedAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is YearRolloverResult &&
          other.closedYearId == closedYearId &&
          other.nextYearId == nextYearId &&
          other.nextYearCode == nextYearCode &&
          other.createdSemesterCount == createdSemesterCount &&
          other.createdClassCount == createdClassCount &&
          other.promotedCount == promotedCount &&
          other.retainedCount == retainedCount &&
          other.graduatedCount == graduatedCount &&
          other.nextYearActivated == nextYearActivated &&
          other.completedAt == completedAt;

  @override
  int get hashCode =>
      closedYearId.hashCode +
      nextYearId.hashCode +
      nextYearCode.hashCode +
      createdSemesterCount.hashCode +
      createdClassCount.hashCode +
      promotedCount.hashCode +
      retainedCount.hashCode +
      graduatedCount.hashCode +
      nextYearActivated.hashCode +
      completedAt.hashCode;

  factory YearRolloverResult.fromJson(Map<String, dynamic> json) =>
      _$YearRolloverResultFromJson(json);

  Map<String, dynamic> toJson() => _$YearRolloverResultToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
