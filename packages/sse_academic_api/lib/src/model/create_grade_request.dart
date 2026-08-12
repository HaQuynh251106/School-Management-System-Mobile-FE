//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'create_grade_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CreateGradeRequest {
  /// Returns a new [CreateGradeRequest] instance.
  CreateGradeRequest({
    required this.studentId,

    this.subjectId,

    required this.semesterId,

    required this.category,

    this.assessmentIndex,

    required this.score,

    this.note,
  });

  @JsonKey(name: r'studentId', required: true, includeIfNull: false)
  final String studentId;

  @JsonKey(name: r'subjectId', required: false, includeIfNull: false)
  final String? subjectId;

  @JsonKey(name: r'semesterId', required: true, includeIfNull: false)
  final String semesterId;

  @JsonKey(name: r'category', required: true, includeIfNull: false)
  final String category;

  // minimum: 1
  @JsonKey(name: r'assessmentIndex', required: false, includeIfNull: false)
  final int? assessmentIndex;

  // minimum: 0
  // maximum: 10
  @JsonKey(name: r'score', required: true, includeIfNull: false)
  final num score;

  @JsonKey(name: r'note', required: false, includeIfNull: false)
  final String? note;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreateGradeRequest &&
          other.studentId == studentId &&
          other.subjectId == subjectId &&
          other.semesterId == semesterId &&
          other.category == category &&
          other.assessmentIndex == assessmentIndex &&
          other.score == score &&
          other.note == note;

  @override
  int get hashCode =>
      studentId.hashCode +
      (subjectId == null ? 0 : subjectId.hashCode) +
      semesterId.hashCode +
      category.hashCode +
      (assessmentIndex == null ? 0 : assessmentIndex.hashCode) +
      score.hashCode +
      (note == null ? 0 : note.hashCode);

  factory CreateGradeRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateGradeRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreateGradeRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
