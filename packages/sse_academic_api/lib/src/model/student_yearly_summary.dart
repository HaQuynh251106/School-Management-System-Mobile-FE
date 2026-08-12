//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'student_yearly_summary.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class StudentYearlySummary {
  /// Returns a new [StudentYearlySummary] instance.
  StudentYearlySummary({
    required this.id,

    required this.academicYearId,

    required this.studentId,

    required this.studentName,

    required this.classId,

    this.semesterOneAverage,

    this.semesterTwoAverage,

    this.averageScore,

    this.conductGrade,

    required this.promotionStatus,

    this.missingRequirements,

    this.nextClassId,

    required this.updatedAt,

    this.finalizedAt,

    this.finalizedBy,
  });

  @JsonKey(name: r'id', required: true, includeIfNull: false)
  final String id;

  @JsonKey(name: r'academicYearId', required: true, includeIfNull: false)
  final String academicYearId;

  @JsonKey(name: r'studentId', required: true, includeIfNull: false)
  final String studentId;

  @JsonKey(name: r'studentName', required: true, includeIfNull: false)
  final String studentName;

  @JsonKey(name: r'classId', required: true, includeIfNull: false)
  final String classId;

  @JsonKey(name: r'semesterOneAverage', required: false, includeIfNull: false)
  final num? semesterOneAverage;

  @JsonKey(name: r'semesterTwoAverage', required: false, includeIfNull: false)
  final num? semesterTwoAverage;

  @JsonKey(name: r'averageScore', required: false, includeIfNull: false)
  final num? averageScore;

  @JsonKey(name: r'conductGrade', required: false, includeIfNull: false)
  final StudentYearlySummaryConductGradeEnum? conductGrade;

  @JsonKey(name: r'promotionStatus', required: true, includeIfNull: false)
  final String promotionStatus;

  @JsonKey(name: r'missingRequirements', required: false, includeIfNull: false)
  final String? missingRequirements;

  @JsonKey(name: r'nextClassId', required: false, includeIfNull: false)
  final String? nextClassId;

  @JsonKey(name: r'updatedAt', required: true, includeIfNull: false)
  final DateTime updatedAt;

  @JsonKey(name: r'finalizedAt', required: false, includeIfNull: false)
  final DateTime? finalizedAt;

  @JsonKey(name: r'finalizedBy', required: false, includeIfNull: false)
  final String? finalizedBy;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StudentYearlySummary &&
          other.id == id &&
          other.academicYearId == academicYearId &&
          other.studentId == studentId &&
          other.studentName == studentName &&
          other.classId == classId &&
          other.semesterOneAverage == semesterOneAverage &&
          other.semesterTwoAverage == semesterTwoAverage &&
          other.averageScore == averageScore &&
          other.conductGrade == conductGrade &&
          other.promotionStatus == promotionStatus &&
          other.missingRequirements == missingRequirements &&
          other.nextClassId == nextClassId &&
          other.updatedAt == updatedAt &&
          other.finalizedAt == finalizedAt &&
          other.finalizedBy == finalizedBy;

  @override
  int get hashCode =>
      id.hashCode +
      academicYearId.hashCode +
      studentId.hashCode +
      studentName.hashCode +
      classId.hashCode +
      (semesterOneAverage == null ? 0 : semesterOneAverage.hashCode) +
      (semesterTwoAverage == null ? 0 : semesterTwoAverage.hashCode) +
      (averageScore == null ? 0 : averageScore.hashCode) +
      (conductGrade == null ? 0 : conductGrade.hashCode) +
      promotionStatus.hashCode +
      (missingRequirements == null ? 0 : missingRequirements.hashCode) +
      (nextClassId == null ? 0 : nextClassId.hashCode) +
      updatedAt.hashCode +
      (finalizedAt == null ? 0 : finalizedAt.hashCode) +
      (finalizedBy == null ? 0 : finalizedBy.hashCode);

  factory StudentYearlySummary.fromJson(Map<String, dynamic> json) =>
      _$StudentYearlySummaryFromJson(json);

  Map<String, dynamic> toJson() => _$StudentYearlySummaryToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum StudentYearlySummaryConductGradeEnum {
  @JsonValue(r'GOOD')
  GOOD(r'GOOD'),
  @JsonValue(r'FAIR')
  FAIR(r'FAIR'),
  @JsonValue(r'AVERAGE')
  AVERAGE(r'AVERAGE'),
  @JsonValue(r'WEAK')
  WEAK(r'WEAK');

  const StudentYearlySummaryConductGradeEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
