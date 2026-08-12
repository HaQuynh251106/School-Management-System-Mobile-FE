//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:sse_academic_api/src/model/attendance_status.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'attendance_mark.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AttendanceMark {
  /// Returns a new [AttendanceMark] instance.
  AttendanceMark({required this.studentId, required this.status, this.note});

  @JsonKey(name: r'studentId', required: true, includeIfNull: false)
  final String studentId;

  @JsonKey(name: r'status', required: true, includeIfNull: false)
  final AttendanceStatus status;

  @JsonKey(name: r'note', required: false, includeIfNull: false)
  final String? note;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AttendanceMark &&
          other.studentId == studentId &&
          other.status == status &&
          other.note == note;

  @override
  int get hashCode =>
      studentId.hashCode + status.hashCode + (note == null ? 0 : note.hashCode);

  factory AttendanceMark.fromJson(Map<String, dynamic> json) =>
      _$AttendanceMarkFromJson(json);

  Map<String, dynamic> toJson() => _$AttendanceMarkToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
