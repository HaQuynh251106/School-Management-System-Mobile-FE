//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'unlock_attendance_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class UnlockAttendanceRequest {
  /// Returns a new [UnlockAttendanceRequest] instance.
  UnlockAttendanceRequest({
    required this.slotId,

    required this.date,

    required this.reason,
  });

  @JsonKey(name: r'slotId', required: true, includeIfNull: false)
  final String slotId;

  @JsonKey(name: r'date', required: true, includeIfNull: false)
  final DateTime date;

  @JsonKey(name: r'reason', required: true, includeIfNull: false)
  final String reason;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UnlockAttendanceRequest &&
          other.slotId == slotId &&
          other.date == date &&
          other.reason == reason;

  @override
  int get hashCode => slotId.hashCode + date.hashCode + reason.hashCode;

  factory UnlockAttendanceRequest.fromJson(Map<String, dynamic> json) =>
      _$UnlockAttendanceRequestFromJson(json);

  Map<String, dynamic> toJson() => _$UnlockAttendanceRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
