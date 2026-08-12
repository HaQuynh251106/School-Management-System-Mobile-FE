//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'approved_leave.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ApprovedLeave {
  /// Returns a new [ApprovedLeave] instance.
  ApprovedLeave({
    required this.id,

    required this.studentId,

    this.studentName,

    required this.classId,

    this.classCode,

    required this.startDate,

    required this.endDate,

    required this.reason,

    required this.status,

    this.parentId,

    this.parentName,

    this.parentConfirmedAt,

    this.homeroomTeacherId,

    this.homeroomTeacherName,

    this.decidedAt,

    this.decisionNote,

    required this.createdAt,

    this.updatedAt,
  });

  @JsonKey(name: r'id', required: true, includeIfNull: false)
  final String id;

  @JsonKey(name: r'studentId', required: true, includeIfNull: false)
  final String studentId;

  @JsonKey(name: r'studentName', required: false, includeIfNull: false)
  final String? studentName;

  @JsonKey(name: r'classId', required: true, includeIfNull: false)
  final String classId;

  @JsonKey(name: r'classCode', required: false, includeIfNull: false)
  final String? classCode;

  @JsonKey(name: r'startDate', required: true, includeIfNull: false)
  final DateTime startDate;

  @JsonKey(name: r'endDate', required: true, includeIfNull: false)
  final DateTime endDate;

  @JsonKey(name: r'reason', required: true, includeIfNull: false)
  final String reason;

  @JsonKey(name: r'status', required: true, includeIfNull: false)
  final String status;

  @JsonKey(name: r'parentId', required: false, includeIfNull: false)
  final String? parentId;

  @JsonKey(name: r'parentName', required: false, includeIfNull: false)
  final String? parentName;

  @JsonKey(name: r'parentConfirmedAt', required: false, includeIfNull: false)
  final DateTime? parentConfirmedAt;

  @JsonKey(name: r'homeroomTeacherId', required: false, includeIfNull: false)
  final String? homeroomTeacherId;

  @JsonKey(name: r'homeroomTeacherName', required: false, includeIfNull: false)
  final String? homeroomTeacherName;

  @JsonKey(name: r'decidedAt', required: false, includeIfNull: false)
  final DateTime? decidedAt;

  @JsonKey(name: r'decisionNote', required: false, includeIfNull: false)
  final String? decisionNote;

  @JsonKey(name: r'createdAt', required: true, includeIfNull: false)
  final DateTime createdAt;

  @JsonKey(name: r'updatedAt', required: false, includeIfNull: false)
  final DateTime? updatedAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ApprovedLeave &&
          other.id == id &&
          other.studentId == studentId &&
          other.studentName == studentName &&
          other.classId == classId &&
          other.classCode == classCode &&
          other.startDate == startDate &&
          other.endDate == endDate &&
          other.reason == reason &&
          other.status == status &&
          other.parentId == parentId &&
          other.parentName == parentName &&
          other.parentConfirmedAt == parentConfirmedAt &&
          other.homeroomTeacherId == homeroomTeacherId &&
          other.homeroomTeacherName == homeroomTeacherName &&
          other.decidedAt == decidedAt &&
          other.decisionNote == decisionNote &&
          other.createdAt == createdAt &&
          other.updatedAt == updatedAt;

  @override
  int get hashCode =>
      id.hashCode +
      studentId.hashCode +
      (studentName == null ? 0 : studentName.hashCode) +
      classId.hashCode +
      (classCode == null ? 0 : classCode.hashCode) +
      startDate.hashCode +
      endDate.hashCode +
      reason.hashCode +
      status.hashCode +
      (parentId == null ? 0 : parentId.hashCode) +
      (parentName == null ? 0 : parentName.hashCode) +
      (parentConfirmedAt == null ? 0 : parentConfirmedAt.hashCode) +
      (homeroomTeacherId == null ? 0 : homeroomTeacherId.hashCode) +
      (homeroomTeacherName == null ? 0 : homeroomTeacherName.hashCode) +
      (decidedAt == null ? 0 : decidedAt.hashCode) +
      (decisionNote == null ? 0 : decisionNote.hashCode) +
      createdAt.hashCode +
      (updatedAt == null ? 0 : updatedAt.hashCode);

  factory ApprovedLeave.fromJson(Map<String, dynamic> json) =>
      _$ApprovedLeaveFromJson(json);

  Map<String, dynamic> toJson() => _$ApprovedLeaveToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
