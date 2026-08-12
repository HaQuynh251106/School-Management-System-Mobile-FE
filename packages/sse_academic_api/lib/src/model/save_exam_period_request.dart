//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'save_exam_period_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SaveExamPeriodRequest {
  /// Returns a new [SaveExamPeriodRequest] instance.
  SaveExamPeriodRequest({
    this.id,

    required this.code,

    required this.name,

    required this.academicYearId,

    required this.semesterId,

    this.gradeLevel,

    required this.startDate,

    required this.endDate,
  });

  @JsonKey(name: r'id', required: false, includeIfNull: false)
  final String? id;

  @JsonKey(name: r'code', required: true, includeIfNull: false)
  final String code;

  @JsonKey(name: r'name', required: true, includeIfNull: false)
  final String name;

  @JsonKey(name: r'academicYearId', required: true, includeIfNull: false)
  final String academicYearId;

  @JsonKey(name: r'semesterId', required: true, includeIfNull: false)
  final String semesterId;

  @JsonKey(name: r'gradeLevel', required: false, includeIfNull: false)
  final String? gradeLevel;

  @JsonKey(name: r'startDate', required: true, includeIfNull: false)
  final DateTime startDate;

  @JsonKey(name: r'endDate', required: true, includeIfNull: false)
  final DateTime endDate;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SaveExamPeriodRequest &&
          other.id == id &&
          other.code == code &&
          other.name == name &&
          other.academicYearId == academicYearId &&
          other.semesterId == semesterId &&
          other.gradeLevel == gradeLevel &&
          other.startDate == startDate &&
          other.endDate == endDate;

  @override
  int get hashCode =>
      (id == null ? 0 : id.hashCode) +
      code.hashCode +
      name.hashCode +
      academicYearId.hashCode +
      semesterId.hashCode +
      (gradeLevel == null ? 0 : gradeLevel.hashCode) +
      startDate.hashCode +
      endDate.hashCode;

  factory SaveExamPeriodRequest.fromJson(Map<String, dynamic> json) =>
      _$SaveExamPeriodRequestFromJson(json);

  Map<String, dynamic> toJson() => _$SaveExamPeriodRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
