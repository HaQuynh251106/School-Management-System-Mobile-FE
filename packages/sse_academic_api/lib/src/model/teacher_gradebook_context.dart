//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:sse_academic_api/src/model/gradebook_subject.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'teacher_gradebook_context.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class TeacherGradebookContext {
  /// Returns a new [TeacherGradebookContext] instance.
  TeacherGradebookContext({
    required this.classId,

    required this.semesterId,

    required this.subjectId,

    required this.subjectName,

    required this.homeroomTeacher,

    required this.canEdit,

    required this.subjects,
  });

  @JsonKey(name: r'classId', required: true, includeIfNull: false)
  final String classId;

  @JsonKey(name: r'semesterId', required: true, includeIfNull: false)
  final String semesterId;

  @JsonKey(name: r'subjectId', required: true, includeIfNull: false)
  final String subjectId;

  @JsonKey(name: r'subjectName', required: true, includeIfNull: false)
  final String subjectName;

  @JsonKey(name: r'homeroomTeacher', required: true, includeIfNull: false)
  final bool homeroomTeacher;

  @JsonKey(name: r'canEdit', required: true, includeIfNull: false)
  final bool canEdit;

  @JsonKey(name: r'subjects', required: true, includeIfNull: false)
  final List<GradebookSubject> subjects;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TeacherGradebookContext &&
          other.classId == classId &&
          other.semesterId == semesterId &&
          other.subjectId == subjectId &&
          other.subjectName == subjectName &&
          other.homeroomTeacher == homeroomTeacher &&
          other.canEdit == canEdit &&
          other.subjects == subjects;

  @override
  int get hashCode =>
      classId.hashCode +
      semesterId.hashCode +
      subjectId.hashCode +
      subjectName.hashCode +
      homeroomTeacher.hashCode +
      canEdit.hashCode +
      subjects.hashCode;

  factory TeacherGradebookContext.fromJson(Map<String, dynamic> json) =>
      _$TeacherGradebookContextFromJson(json);

  Map<String, dynamic> toJson() => _$TeacherGradebookContextToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
