//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'attendance_session_status.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AttendanceSessionStatus {
  /// Returns a new [AttendanceSessionStatus] instance.
  AttendanceSessionStatus({
    required this.state,

    required this.canMark,

    required this.requiresUnlockReason,

    required this.message,

    required this.date,

    this.startTime,

    this.endTime,

    this.unlockReason,

    this.unlockedAt,
  });

  @JsonKey(name: r'state', required: true, includeIfNull: false)
  final String state;

  @JsonKey(name: r'canMark', required: true, includeIfNull: false)
  final bool canMark;

  @JsonKey(name: r'requiresUnlockReason', required: true, includeIfNull: false)
  final bool requiresUnlockReason;

  @JsonKey(name: r'message', required: true, includeIfNull: false)
  final String message;

  @JsonKey(name: r'date', required: true, includeIfNull: false)
  final DateTime date;

  @JsonKey(name: r'startTime', required: false, includeIfNull: false)
  final String? startTime;

  @JsonKey(name: r'endTime', required: false, includeIfNull: false)
  final String? endTime;

  @JsonKey(name: r'unlockReason', required: false, includeIfNull: false)
  final String? unlockReason;

  @JsonKey(name: r'unlockedAt', required: false, includeIfNull: false)
  final DateTime? unlockedAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AttendanceSessionStatus &&
          other.state == state &&
          other.canMark == canMark &&
          other.requiresUnlockReason == requiresUnlockReason &&
          other.message == message &&
          other.date == date &&
          other.startTime == startTime &&
          other.endTime == endTime &&
          other.unlockReason == unlockReason &&
          other.unlockedAt == unlockedAt;

  @override
  int get hashCode =>
      state.hashCode +
      canMark.hashCode +
      requiresUnlockReason.hashCode +
      message.hashCode +
      date.hashCode +
      (startTime == null ? 0 : startTime.hashCode) +
      (endTime == null ? 0 : endTime.hashCode) +
      (unlockReason == null ? 0 : unlockReason.hashCode) +
      (unlockedAt == null ? 0 : unlockedAt.hashCode);

  factory AttendanceSessionStatus.fromJson(Map<String, dynamic> json) =>
      _$AttendanceSessionStatusFromJson(json);

  Map<String, dynamic> toJson() => _$AttendanceSessionStatusToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
