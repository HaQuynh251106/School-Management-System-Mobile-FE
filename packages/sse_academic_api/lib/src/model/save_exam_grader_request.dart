//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'save_exam_grader_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SaveExamGraderRequest {
  /// Returns a new [SaveExamGraderRequest] instance.
  SaveExamGraderRequest({required this.classId, required this.teacherId});

  @JsonKey(name: r'classId', required: true, includeIfNull: false)
  final String classId;

  @JsonKey(name: r'teacherId', required: true, includeIfNull: false)
  final String teacherId;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SaveExamGraderRequest &&
          other.classId == classId &&
          other.teacherId == teacherId;

  @override
  int get hashCode => classId.hashCode + teacherId.hashCode;

  factory SaveExamGraderRequest.fromJson(Map<String, dynamic> json) =>
      _$SaveExamGraderRequestFromJson(json);

  Map<String, dynamic> toJson() => _$SaveExamGraderRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
