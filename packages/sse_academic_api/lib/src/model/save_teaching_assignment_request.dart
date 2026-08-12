//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'save_teaching_assignment_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SaveTeachingAssignmentRequest {
  /// Returns a new [SaveTeachingAssignmentRequest] instance.
  SaveTeachingAssignmentRequest({
    required this.classId,

    required this.subjectId,

    required this.teacherId,

    required this.semesterId,

    required this.weeklyPeriods,
  });

  @JsonKey(name: r'classId', required: true, includeIfNull: false)
  final String classId;

  @JsonKey(name: r'subjectId', required: true, includeIfNull: false)
  final String subjectId;

  @JsonKey(name: r'teacherId', required: true, includeIfNull: false)
  final String teacherId;

  @JsonKey(name: r'semesterId', required: true, includeIfNull: false)
  final String semesterId;

  // minimum: 1
  // maximum: 20
  @JsonKey(name: r'weeklyPeriods', required: true, includeIfNull: false)
  final int weeklyPeriods;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SaveTeachingAssignmentRequest &&
          other.classId == classId &&
          other.subjectId == subjectId &&
          other.teacherId == teacherId &&
          other.semesterId == semesterId &&
          other.weeklyPeriods == weeklyPeriods;

  @override
  int get hashCode =>
      classId.hashCode +
      subjectId.hashCode +
      teacherId.hashCode +
      semesterId.hashCode +
      weeklyPeriods.hashCode;

  factory SaveTeachingAssignmentRequest.fromJson(Map<String, dynamic> json) =>
      _$SaveTeachingAssignmentRequestFromJson(json);

  Map<String, dynamic> toJson() => _$SaveTeachingAssignmentRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
