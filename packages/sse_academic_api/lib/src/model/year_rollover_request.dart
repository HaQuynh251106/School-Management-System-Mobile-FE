//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'year_rollover_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class YearRolloverRequest {
  /// Returns a new [YearRolloverRequest] instance.
  YearRolloverRequest({
    required this.nextYearCode,

    this.nextYearName,

    required this.startDate,

    required this.endDate,

    this.createIntakeClasses,

    this.activateNextYear,
  });

  @JsonKey(name: r'nextYearCode', required: true, includeIfNull: false)
  final String nextYearCode;

  @JsonKey(name: r'nextYearName', required: false, includeIfNull: false)
  final String? nextYearName;

  @JsonKey(name: r'startDate', required: true, includeIfNull: false)
  final DateTime startDate;

  @JsonKey(name: r'endDate', required: true, includeIfNull: false)
  final DateTime endDate;

  @JsonKey(name: r'createIntakeClasses', required: false, includeIfNull: false)
  final bool? createIntakeClasses;

  @JsonKey(name: r'activateNextYear', required: false, includeIfNull: false)
  final bool? activateNextYear;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is YearRolloverRequest &&
          other.nextYearCode == nextYearCode &&
          other.nextYearName == nextYearName &&
          other.startDate == startDate &&
          other.endDate == endDate &&
          other.createIntakeClasses == createIntakeClasses &&
          other.activateNextYear == activateNextYear;

  @override
  int get hashCode =>
      nextYearCode.hashCode +
      (nextYearName == null ? 0 : nextYearName.hashCode) +
      startDate.hashCode +
      endDate.hashCode +
      (createIntakeClasses == null ? 0 : createIntakeClasses.hashCode) +
      (activateNextYear == null ? 0 : activateNextYear.hashCode);

  factory YearRolloverRequest.fromJson(Map<String, dynamic> json) =>
      _$YearRolloverRequestFromJson(json);

  Map<String, dynamic> toJson() => _$YearRolloverRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
