//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'grade.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class Grade {
  /// Returns a new [Grade] instance.
  Grade({
    required this.id,

    required this.studentId,

    required this.subjectId,

    required this.subjectName,

    required this.semesterId,

    required this.category,

    required this.categoryName,

    required this.assessmentIndex,

    required this.score,

    this.note,

    this.recordedAt,

    this.createdAt,

    this.createdBy,

    this.updatedAt,

    this.updatedBy,

    required this.version,
  });

  @JsonKey(name: r'id', required: true, includeIfNull: false)
  final String id;

  @JsonKey(name: r'studentId', required: true, includeIfNull: false)
  final String studentId;

  @JsonKey(name: r'subjectId', required: true, includeIfNull: false)
  final String subjectId;

  @JsonKey(name: r'subjectName', required: true, includeIfNull: false)
  final String subjectName;

  @JsonKey(name: r'semesterId', required: true, includeIfNull: false)
  final String semesterId;

  @JsonKey(name: r'category', required: true, includeIfNull: false)
  final String category;

  @JsonKey(name: r'categoryName', required: true, includeIfNull: false)
  final String categoryName;

  // minimum: 1
  @JsonKey(name: r'assessmentIndex', required: true, includeIfNull: false)
  final int assessmentIndex;

  // minimum: 0
  // maximum: 10
  @JsonKey(name: r'score', required: true, includeIfNull: false)
  final num score;

  @JsonKey(name: r'note', required: false, includeIfNull: false)
  final String? note;

  @JsonKey(name: r'recordedAt', required: false, includeIfNull: false)
  final DateTime? recordedAt;

  @JsonKey(name: r'createdAt', required: false, includeIfNull: false)
  final DateTime? createdAt;

  @JsonKey(name: r'createdBy', required: false, includeIfNull: false)
  final String? createdBy;

  @JsonKey(name: r'updatedAt', required: false, includeIfNull: false)
  final DateTime? updatedAt;

  @JsonKey(name: r'updatedBy', required: false, includeIfNull: false)
  final String? updatedBy;

  // minimum: 0
  @JsonKey(name: r'version', required: true, includeIfNull: false)
  final int version;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Grade &&
          other.id == id &&
          other.studentId == studentId &&
          other.subjectId == subjectId &&
          other.subjectName == subjectName &&
          other.semesterId == semesterId &&
          other.category == category &&
          other.categoryName == categoryName &&
          other.assessmentIndex == assessmentIndex &&
          other.score == score &&
          other.note == note &&
          other.recordedAt == recordedAt &&
          other.createdAt == createdAt &&
          other.createdBy == createdBy &&
          other.updatedAt == updatedAt &&
          other.updatedBy == updatedBy &&
          other.version == version;

  @override
  int get hashCode =>
      id.hashCode +
      studentId.hashCode +
      subjectId.hashCode +
      subjectName.hashCode +
      semesterId.hashCode +
      category.hashCode +
      categoryName.hashCode +
      assessmentIndex.hashCode +
      score.hashCode +
      (note == null ? 0 : note.hashCode) +
      (recordedAt == null ? 0 : recordedAt.hashCode) +
      (createdAt == null ? 0 : createdAt.hashCode) +
      (createdBy == null ? 0 : createdBy.hashCode) +
      (updatedAt == null ? 0 : updatedAt.hashCode) +
      (updatedBy == null ? 0 : updatedBy.hashCode) +
      version.hashCode;

  factory Grade.fromJson(Map<String, dynamic> json) => _$GradeFromJson(json);

  Map<String, dynamic> toJson() => _$GradeToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
