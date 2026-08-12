//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'gradebook_subject.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class GradebookSubject {
  /// Returns a new [GradebookSubject] instance.
  GradebookSubject({
    required this.subjectId,

    required this.subjectName,

    this.teacherName,

    required this.editable,
  });

  @JsonKey(name: r'subjectId', required: true, includeIfNull: false)
  final String subjectId;

  @JsonKey(name: r'subjectName', required: true, includeIfNull: false)
  final String subjectName;

  @JsonKey(name: r'teacherName', required: false, includeIfNull: false)
  final String? teacherName;

  @JsonKey(name: r'editable', required: true, includeIfNull: false)
  final bool editable;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GradebookSubject &&
          other.subjectId == subjectId &&
          other.subjectName == subjectName &&
          other.teacherName == teacherName &&
          other.editable == editable;

  @override
  int get hashCode =>
      subjectId.hashCode +
      subjectName.hashCode +
      (teacherName == null ? 0 : teacherName.hashCode) +
      editable.hashCode;

  factory GradebookSubject.fromJson(Map<String, dynamic> json) =>
      _$GradebookSubjectFromJson(json);

  Map<String, dynamic> toJson() => _$GradebookSubjectToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
