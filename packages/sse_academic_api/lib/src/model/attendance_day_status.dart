//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'attendance_day_status.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AttendanceDayStatus {
  /// Returns a new [AttendanceDayStatus] instance.
  AttendanceDayStatus({
    required this.attendanceRequired,

    this.announcementId,

    this.title,

    this.reason,

    this.holidayStartDate,

    this.holidayEndDate,
  });

  @JsonKey(name: r'attendanceRequired', required: true, includeIfNull: false)
  final bool attendanceRequired;

  @JsonKey(name: r'announcementId', required: false, includeIfNull: false)
  final String? announcementId;

  @JsonKey(name: r'title', required: false, includeIfNull: false)
  final String? title;

  @JsonKey(name: r'reason', required: false, includeIfNull: false)
  final String? reason;

  @JsonKey(name: r'holidayStartDate', required: false, includeIfNull: false)
  final DateTime? holidayStartDate;

  @JsonKey(name: r'holidayEndDate', required: false, includeIfNull: false)
  final DateTime? holidayEndDate;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AttendanceDayStatus &&
          other.attendanceRequired == attendanceRequired &&
          other.announcementId == announcementId &&
          other.title == title &&
          other.reason == reason &&
          other.holidayStartDate == holidayStartDate &&
          other.holidayEndDate == holidayEndDate;

  @override
  int get hashCode =>
      attendanceRequired.hashCode +
      (announcementId == null ? 0 : announcementId.hashCode) +
      (title == null ? 0 : title.hashCode) +
      (reason == null ? 0 : reason.hashCode) +
      (holidayStartDate == null ? 0 : holidayStartDate.hashCode) +
      (holidayEndDate == null ? 0 : holidayEndDate.hashCode);

  factory AttendanceDayStatus.fromJson(Map<String, dynamic> json) =>
      _$AttendanceDayStatusFromJson(json);

  Map<String, dynamic> toJson() => _$AttendanceDayStatusToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
