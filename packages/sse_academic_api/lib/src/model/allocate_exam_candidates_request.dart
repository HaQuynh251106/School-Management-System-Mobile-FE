//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'allocate_exam_candidates_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AllocateExamCandidatesRequest {
  /// Returns a new [AllocateExamCandidatesRequest] instance.
  AllocateExamCandidatesRequest({required this.classId});

  @JsonKey(name: r'classId', required: true, includeIfNull: false)
  final String classId;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AllocateExamCandidatesRequest && other.classId == classId;

  @override
  int get hashCode => classId.hashCode;

  factory AllocateExamCandidatesRequest.fromJson(Map<String, dynamic> json) =>
      _$AllocateExamCandidatesRequestFromJson(json);

  Map<String, dynamic> toJson() => _$AllocateExamCandidatesRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
