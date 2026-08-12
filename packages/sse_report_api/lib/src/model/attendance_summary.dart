//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'attendance_summary.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AttendanceSummary {
  /// Returns a new [AttendanceSummary] instance.
  AttendanceSummary({
    required this.present,

    required this.late_,

    required this.absentExcused,

    required this.absentUnexcused,

    required this.total,

    required this.attendanceRate,
  });

  @JsonKey(name: r'present', required: true, includeIfNull: false)
  final int present;

  @JsonKey(name: r'late', required: true, includeIfNull: false)
  final int late_;

  @JsonKey(name: r'absentExcused', required: true, includeIfNull: false)
  final int absentExcused;

  @JsonKey(name: r'absentUnexcused', required: true, includeIfNull: false)
  final int absentUnexcused;

  @JsonKey(name: r'total', required: true, includeIfNull: false)
  final int total;

  @JsonKey(name: r'attendanceRate', required: true, includeIfNull: false)
  final num attendanceRate;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AttendanceSummary &&
          other.present == present &&
          other.late_ == late_ &&
          other.absentExcused == absentExcused &&
          other.absentUnexcused == absentUnexcused &&
          other.total == total &&
          other.attendanceRate == attendanceRate;

  @override
  int get hashCode =>
      present.hashCode +
      late_.hashCode +
      absentExcused.hashCode +
      absentUnexcused.hashCode +
      total.hashCode +
      attendanceRate.hashCode;

  factory AttendanceSummary.fromJson(Map<String, dynamic> json) =>
      _$AttendanceSummaryFromJson(json);

  Map<String, dynamic> toJson() => _$AttendanceSummaryToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
