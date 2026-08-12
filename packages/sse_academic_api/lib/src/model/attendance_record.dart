//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:sse_academic_api/src/model/attendance_status.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'attendance_record.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AttendanceRecord {
  /// Returns a new [AttendanceRecord] instance.
  AttendanceRecord({
    required this.id,

    required this.studentId,

    required this.classId,

    required this.slotId,

    required this.date,

    required this.status,

    this.note,

    this.subjectName,

    this.periodNo,
  });

  @JsonKey(name: r'id', required: true, includeIfNull: false)
  final String id;

  @JsonKey(name: r'studentId', required: true, includeIfNull: false)
  final String studentId;

  @JsonKey(name: r'classId', required: true, includeIfNull: false)
  final String classId;

  @JsonKey(name: r'slotId', required: true, includeIfNull: false)
  final String slotId;

  @JsonKey(name: r'date', required: true, includeIfNull: false)
  final DateTime date;

  @JsonKey(name: r'status', required: true, includeIfNull: false)
  final AttendanceStatus status;

  @JsonKey(name: r'note', required: false, includeIfNull: false)
  final String? note;

  @JsonKey(name: r'subjectName', required: false, includeIfNull: false)
  final String? subjectName;

  @JsonKey(name: r'periodNo', required: false, includeIfNull: false)
  final int? periodNo;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AttendanceRecord &&
          other.id == id &&
          other.studentId == studentId &&
          other.classId == classId &&
          other.slotId == slotId &&
          other.date == date &&
          other.status == status &&
          other.note == note &&
          other.subjectName == subjectName &&
          other.periodNo == periodNo;

  @override
  int get hashCode =>
      id.hashCode +
      studentId.hashCode +
      classId.hashCode +
      slotId.hashCode +
      date.hashCode +
      status.hashCode +
      (note == null ? 0 : note.hashCode) +
      (subjectName == null ? 0 : subjectName.hashCode) +
      (periodNo == null ? 0 : periodNo.hashCode);

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) =>
      _$AttendanceRecordFromJson(json);

  Map<String, dynamic> toJson() => _$AttendanceRecordToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
