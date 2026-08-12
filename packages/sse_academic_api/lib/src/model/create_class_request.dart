//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'create_class_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CreateClassRequest {
  /// Returns a new [CreateClassRequest] instance.
  CreateClassRequest({
    this.id,

    required this.code,

    this.name,

    required this.gradeLevel,

    this.academicYearId,

    this.homeroomTeacherId,

    this.studyShift,

    this.capacity,

    this.roomId,
  });

  @JsonKey(name: r'id', required: false, includeIfNull: false)
  final String? id;

  @JsonKey(name: r'code', required: true, includeIfNull: false)
  final String code;

  @JsonKey(name: r'name', required: false, includeIfNull: false)
  final String? name;

  @JsonKey(name: r'gradeLevel', required: true, includeIfNull: false)
  final String gradeLevel;

  @JsonKey(name: r'academicYearId', required: false, includeIfNull: false)
  final String? academicYearId;

  @JsonKey(name: r'homeroomTeacherId', required: false, includeIfNull: false)
  final String? homeroomTeacherId;

  @JsonKey(name: r'studyShift', required: false, includeIfNull: false)
  final CreateClassRequestStudyShiftEnum? studyShift;

  // minimum: 1
  // maximum: 100
  @JsonKey(name: r'capacity', required: false, includeIfNull: false)
  final int? capacity;

  @JsonKey(name: r'roomId', required: false, includeIfNull: false)
  final String? roomId;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreateClassRequest &&
          other.id == id &&
          other.code == code &&
          other.name == name &&
          other.gradeLevel == gradeLevel &&
          other.academicYearId == academicYearId &&
          other.homeroomTeacherId == homeroomTeacherId &&
          other.studyShift == studyShift &&
          other.capacity == capacity &&
          other.roomId == roomId;

  @override
  int get hashCode =>
      (id == null ? 0 : id.hashCode) +
      code.hashCode +
      (name == null ? 0 : name.hashCode) +
      gradeLevel.hashCode +
      (academicYearId == null ? 0 : academicYearId.hashCode) +
      (homeroomTeacherId == null ? 0 : homeroomTeacherId.hashCode) +
      (studyShift == null ? 0 : studyShift.hashCode) +
      (capacity == null ? 0 : capacity.hashCode) +
      (roomId == null ? 0 : roomId.hashCode);

  factory CreateClassRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateClassRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreateClassRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum CreateClassRequestStudyShiftEnum {
  @JsonValue(r'MORNING')
  MORNING(r'MORNING'),
  @JsonValue(r'AFTERNOON')
  AFTERNOON(r'AFTERNOON');

  const CreateClassRequestStudyShiftEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
