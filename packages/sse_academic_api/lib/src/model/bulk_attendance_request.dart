//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:sse_academic_api/src/model/attendance_mark.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'bulk_attendance_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class BulkAttendanceRequest {
  /// Returns a new [BulkAttendanceRequest] instance.
  BulkAttendanceRequest({
    required this.slotId,

    this.classId,

    required this.date,

    this.subjectName,

    this.periodNo,

    required this.marks,
  });

  @JsonKey(name: r'slotId', required: true, includeIfNull: false)
  final String slotId;

  @JsonKey(name: r'classId', required: false, includeIfNull: false)
  final String? classId;

  @JsonKey(name: r'date', required: true, includeIfNull: false)
  final DateTime date;

  @JsonKey(name: r'subjectName', required: false, includeIfNull: false)
  final String? subjectName;

  @JsonKey(name: r'periodNo', required: false, includeIfNull: false)
  final int? periodNo;

  @JsonKey(name: r'marks', required: true, includeIfNull: false)
  final List<AttendanceMark> marks;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BulkAttendanceRequest &&
          other.slotId == slotId &&
          other.classId == classId &&
          other.date == date &&
          other.subjectName == subjectName &&
          other.periodNo == periodNo &&
          other.marks == marks;

  @override
  int get hashCode =>
      slotId.hashCode +
      (classId == null ? 0 : classId.hashCode) +
      date.hashCode +
      (subjectName == null ? 0 : subjectName.hashCode) +
      (periodNo == null ? 0 : periodNo.hashCode) +
      marks.hashCode;

  factory BulkAttendanceRequest.fromJson(Map<String, dynamic> json) =>
      _$BulkAttendanceRequestFromJson(json);

  Map<String, dynamic> toJson() => _$BulkAttendanceRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
