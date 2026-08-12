//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'school_class.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SchoolClass {
  /// Returns a new [SchoolClass] instance.
  SchoolClass({
    required this.id,

    required this.code,

    required this.name,

    required this.gradeLevel,

    required this.studyShift,

    this.academicYearId,

    this.cohortId,

    this.homeroomTeacherId,

    this.homeroomTeacherName,

    this.homeroomAssignedAt,

    this.homeroomAssignedBy,

    this.roomId,

    this.roomCode,

    required this.capacity,

    required this.studentCount,
  });

  @JsonKey(name: r'id', required: true, includeIfNull: false)
  final String id;

  @JsonKey(name: r'code', required: true, includeIfNull: false)
  final String code;

  @JsonKey(name: r'name', required: true, includeIfNull: false)
  final String name;

  @JsonKey(name: r'gradeLevel', required: true, includeIfNull: false)
  final String gradeLevel;

  @JsonKey(name: r'studyShift', required: true, includeIfNull: false)
  final String studyShift;

  @JsonKey(name: r'academicYearId', required: false, includeIfNull: false)
  final String? academicYearId;

  @JsonKey(name: r'cohortId', required: false, includeIfNull: false)
  final String? cohortId;

  @JsonKey(name: r'homeroomTeacherId', required: false, includeIfNull: false)
  final String? homeroomTeacherId;

  @JsonKey(name: r'homeroomTeacherName', required: false, includeIfNull: false)
  final String? homeroomTeacherName;

  @JsonKey(name: r'homeroomAssignedAt', required: false, includeIfNull: false)
  final DateTime? homeroomAssignedAt;

  @JsonKey(name: r'homeroomAssignedBy', required: false, includeIfNull: false)
  final String? homeroomAssignedBy;

  @JsonKey(name: r'roomId', required: false, includeIfNull: false)
  final String? roomId;

  @JsonKey(name: r'roomCode', required: false, includeIfNull: false)
  final String? roomCode;

  @JsonKey(name: r'capacity', required: true, includeIfNull: false)
  final int capacity;

  @JsonKey(name: r'studentCount', required: true, includeIfNull: false)
  final int studentCount;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SchoolClass &&
          other.id == id &&
          other.code == code &&
          other.name == name &&
          other.gradeLevel == gradeLevel &&
          other.studyShift == studyShift &&
          other.academicYearId == academicYearId &&
          other.cohortId == cohortId &&
          other.homeroomTeacherId == homeroomTeacherId &&
          other.homeroomTeacherName == homeroomTeacherName &&
          other.homeroomAssignedAt == homeroomAssignedAt &&
          other.homeroomAssignedBy == homeroomAssignedBy &&
          other.roomId == roomId &&
          other.roomCode == roomCode &&
          other.capacity == capacity &&
          other.studentCount == studentCount;

  @override
  int get hashCode =>
      id.hashCode +
      code.hashCode +
      name.hashCode +
      gradeLevel.hashCode +
      studyShift.hashCode +
      (academicYearId == null ? 0 : academicYearId.hashCode) +
      (cohortId == null ? 0 : cohortId.hashCode) +
      (homeroomTeacherId == null ? 0 : homeroomTeacherId.hashCode) +
      (homeroomTeacherName == null ? 0 : homeroomTeacherName.hashCode) +
      (homeroomAssignedAt == null ? 0 : homeroomAssignedAt.hashCode) +
      (homeroomAssignedBy == null ? 0 : homeroomAssignedBy.hashCode) +
      (roomId == null ? 0 : roomId.hashCode) +
      (roomCode == null ? 0 : roomCode.hashCode) +
      capacity.hashCode +
      studentCount.hashCode;

  factory SchoolClass.fromJson(Map<String, dynamic> json) =>
      _$SchoolClassFromJson(json);

  Map<String, dynamic> toJson() => _$SchoolClassToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
