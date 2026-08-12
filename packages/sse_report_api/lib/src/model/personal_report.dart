//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:sse_report_api/src/model/finance_summary.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'personal_report.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PersonalReport {
  /// Returns a new [PersonalReport] instance.
  PersonalReport({
    required this.role,

    required this.studentCount,

    required this.classCount,

    required this.gradeCount,

    required this.averageScore,

    required this.subjectAverages,

    required this.attendanceTotal,

    required this.present,

    required this.late_,

    required this.absentExcused,

    required this.absentUnexcused,

    required this.attendanceRate,

    required this.submissionCount,

    required this.gradedSubmissionCount,

    this.finance,
  });

  @JsonKey(name: r'role', required: true, includeIfNull: false)
  final String role;

  @JsonKey(name: r'studentCount', required: true, includeIfNull: false)
  final int studentCount;

  @JsonKey(name: r'classCount', required: true, includeIfNull: false)
  final int classCount;

  @JsonKey(name: r'gradeCount', required: true, includeIfNull: false)
  final int gradeCount;

  @JsonKey(name: r'averageScore', required: true, includeIfNull: false)
  final num averageScore;

  @JsonKey(name: r'subjectAverages', required: true, includeIfNull: false)
  final Map<String, num> subjectAverages;

  @JsonKey(name: r'attendanceTotal', required: true, includeIfNull: false)
  final int attendanceTotal;

  @JsonKey(name: r'present', required: true, includeIfNull: false)
  final int present;

  @JsonKey(name: r'late', required: true, includeIfNull: false)
  final int late_;

  @JsonKey(name: r'absentExcused', required: true, includeIfNull: false)
  final int absentExcused;

  @JsonKey(name: r'absentUnexcused', required: true, includeIfNull: false)
  final int absentUnexcused;

  @JsonKey(name: r'attendanceRate', required: true, includeIfNull: false)
  final num attendanceRate;

  @JsonKey(name: r'submissionCount', required: true, includeIfNull: false)
  final int submissionCount;

  @JsonKey(name: r'gradedSubmissionCount', required: true, includeIfNull: false)
  final int gradedSubmissionCount;

  @JsonKey(name: r'finance', required: false, includeIfNull: false)
  final FinanceSummary? finance;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PersonalReport &&
          other.role == role &&
          other.studentCount == studentCount &&
          other.classCount == classCount &&
          other.gradeCount == gradeCount &&
          other.averageScore == averageScore &&
          other.subjectAverages == subjectAverages &&
          other.attendanceTotal == attendanceTotal &&
          other.present == present &&
          other.late_ == late_ &&
          other.absentExcused == absentExcused &&
          other.absentUnexcused == absentUnexcused &&
          other.attendanceRate == attendanceRate &&
          other.submissionCount == submissionCount &&
          other.gradedSubmissionCount == gradedSubmissionCount &&
          other.finance == finance;

  @override
  int get hashCode =>
      role.hashCode +
      studentCount.hashCode +
      classCount.hashCode +
      gradeCount.hashCode +
      averageScore.hashCode +
      subjectAverages.hashCode +
      attendanceTotal.hashCode +
      present.hashCode +
      late_.hashCode +
      absentExcused.hashCode +
      absentUnexcused.hashCode +
      attendanceRate.hashCode +
      submissionCount.hashCode +
      gradedSubmissionCount.hashCode +
      finance.hashCode;

  factory PersonalReport.fromJson(Map<String, dynamic> json) =>
      _$PersonalReportFromJson(json);

  Map<String, dynamic> toJson() => _$PersonalReportToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
