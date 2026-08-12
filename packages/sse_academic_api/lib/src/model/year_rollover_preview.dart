//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:sse_academic_api/src/model/year_rollover_class_plan.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'year_rollover_preview.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class YearRolloverPreview {
  /// Returns a new [YearRolloverPreview] instance.
  YearRolloverPreview({
    required this.academicYearId,

    required this.academicYearCode,

    required this.status,

    required this.semesterCount,

    required this.classCount,

    required this.studentCount,

    required this.readyCount,

    required this.incompleteCount,

    required this.expectedPromoted,

    required this.expectedRetained,

    required this.expectedGraduated,

    required this.classPlan,

    required this.blockers,
  });

  @JsonKey(name: r'academicYearId', required: true, includeIfNull: false)
  final String academicYearId;

  @JsonKey(name: r'academicYearCode', required: true, includeIfNull: false)
  final String academicYearCode;

  @JsonKey(name: r'status', required: true, includeIfNull: false)
  final String status;

  @JsonKey(name: r'semesterCount', required: true, includeIfNull: false)
  final int semesterCount;

  @JsonKey(name: r'classCount', required: true, includeIfNull: false)
  final int classCount;

  @JsonKey(name: r'studentCount', required: true, includeIfNull: false)
  final int studentCount;

  @JsonKey(name: r'readyCount', required: true, includeIfNull: false)
  final int readyCount;

  @JsonKey(name: r'incompleteCount', required: true, includeIfNull: false)
  final int incompleteCount;

  @JsonKey(name: r'expectedPromoted', required: true, includeIfNull: false)
  final int expectedPromoted;

  @JsonKey(name: r'expectedRetained', required: true, includeIfNull: false)
  final int expectedRetained;

  @JsonKey(name: r'expectedGraduated', required: true, includeIfNull: false)
  final int expectedGraduated;

  @JsonKey(name: r'classPlan', required: true, includeIfNull: false)
  final List<YearRolloverClassPlan> classPlan;

  @JsonKey(name: r'blockers', required: true, includeIfNull: false)
  final List<String> blockers;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is YearRolloverPreview &&
          other.academicYearId == academicYearId &&
          other.academicYearCode == academicYearCode &&
          other.status == status &&
          other.semesterCount == semesterCount &&
          other.classCount == classCount &&
          other.studentCount == studentCount &&
          other.readyCount == readyCount &&
          other.incompleteCount == incompleteCount &&
          other.expectedPromoted == expectedPromoted &&
          other.expectedRetained == expectedRetained &&
          other.expectedGraduated == expectedGraduated &&
          other.classPlan == classPlan &&
          other.blockers == blockers;

  @override
  int get hashCode =>
      academicYearId.hashCode +
      academicYearCode.hashCode +
      status.hashCode +
      semesterCount.hashCode +
      classCount.hashCode +
      studentCount.hashCode +
      readyCount.hashCode +
      incompleteCount.hashCode +
      expectedPromoted.hashCode +
      expectedRetained.hashCode +
      expectedGraduated.hashCode +
      classPlan.hashCode +
      blockers.hashCode;

  factory YearRolloverPreview.fromJson(Map<String, dynamic> json) =>
      _$YearRolloverPreviewFromJson(json);

  Map<String, dynamic> toJson() => _$YearRolloverPreviewToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
