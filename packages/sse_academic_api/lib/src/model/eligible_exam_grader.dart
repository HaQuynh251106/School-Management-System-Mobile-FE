//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'eligible_exam_grader.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class EligibleExamGrader {
  /// Returns a new [EligibleExamGrader] instance.
  EligibleExamGrader({
    required this.teacherId,

    this.teacherCode,

    required this.teacherName,
  });

  @JsonKey(name: r'teacherId', required: true, includeIfNull: false)
  final String teacherId;

  @JsonKey(name: r'teacherCode', required: false, includeIfNull: false)
  final String? teacherCode;

  @JsonKey(name: r'teacherName', required: true, includeIfNull: false)
  final String teacherName;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EligibleExamGrader &&
          other.teacherId == teacherId &&
          other.teacherCode == teacherCode &&
          other.teacherName == teacherName;

  @override
  int get hashCode =>
      teacherId.hashCode +
      (teacherCode == null ? 0 : teacherCode.hashCode) +
      teacherName.hashCode;

  factory EligibleExamGrader.fromJson(Map<String, dynamic> json) =>
      _$EligibleExamGraderFromJson(json);

  Map<String, dynamic> toJson() => _$EligibleExamGraderToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
