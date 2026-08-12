// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendance_day_status.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$AttendanceDayStatusCWProxy {
  AttendanceDayStatus attendanceRequired(bool attendanceRequired);

  AttendanceDayStatus announcementId(String? announcementId);

  AttendanceDayStatus title(String? title);

  AttendanceDayStatus reason(String? reason);

  AttendanceDayStatus holidayStartDate(DateTime? holidayStartDate);

  AttendanceDayStatus holidayEndDate(DateTime? holidayEndDate);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AttendanceDayStatus(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AttendanceDayStatus(...).copyWith(id: 12, name: "My name")
  /// ````
  AttendanceDayStatus call({
    bool attendanceRequired,
    String? announcementId,
    String? title,
    String? reason,
    DateTime? holidayStartDate,
    DateTime? holidayEndDate,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfAttendanceDayStatus.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfAttendanceDayStatus.copyWith.fieldName(...)`
class _$AttendanceDayStatusCWProxyImpl implements _$AttendanceDayStatusCWProxy {
  const _$AttendanceDayStatusCWProxyImpl(this._value);

  final AttendanceDayStatus _value;

  @override
  AttendanceDayStatus attendanceRequired(bool attendanceRequired) =>
      this(attendanceRequired: attendanceRequired);

  @override
  AttendanceDayStatus announcementId(String? announcementId) =>
      this(announcementId: announcementId);

  @override
  AttendanceDayStatus title(String? title) => this(title: title);

  @override
  AttendanceDayStatus reason(String? reason) => this(reason: reason);

  @override
  AttendanceDayStatus holidayStartDate(DateTime? holidayStartDate) =>
      this(holidayStartDate: holidayStartDate);

  @override
  AttendanceDayStatus holidayEndDate(DateTime? holidayEndDate) =>
      this(holidayEndDate: holidayEndDate);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AttendanceDayStatus(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AttendanceDayStatus(...).copyWith(id: 12, name: "My name")
  /// ````
  AttendanceDayStatus call({
    Object? attendanceRequired = const $CopyWithPlaceholder(),
    Object? announcementId = const $CopyWithPlaceholder(),
    Object? title = const $CopyWithPlaceholder(),
    Object? reason = const $CopyWithPlaceholder(),
    Object? holidayStartDate = const $CopyWithPlaceholder(),
    Object? holidayEndDate = const $CopyWithPlaceholder(),
  }) {
    return AttendanceDayStatus(
      attendanceRequired: attendanceRequired == const $CopyWithPlaceholder()
          ? _value.attendanceRequired
          // ignore: cast_nullable_to_non_nullable
          : attendanceRequired as bool,
      announcementId: announcementId == const $CopyWithPlaceholder()
          ? _value.announcementId
          // ignore: cast_nullable_to_non_nullable
          : announcementId as String?,
      title: title == const $CopyWithPlaceholder()
          ? _value.title
          // ignore: cast_nullable_to_non_nullable
          : title as String?,
      reason: reason == const $CopyWithPlaceholder()
          ? _value.reason
          // ignore: cast_nullable_to_non_nullable
          : reason as String?,
      holidayStartDate: holidayStartDate == const $CopyWithPlaceholder()
          ? _value.holidayStartDate
          // ignore: cast_nullable_to_non_nullable
          : holidayStartDate as DateTime?,
      holidayEndDate: holidayEndDate == const $CopyWithPlaceholder()
          ? _value.holidayEndDate
          // ignore: cast_nullable_to_non_nullable
          : holidayEndDate as DateTime?,
    );
  }
}

extension $AttendanceDayStatusCopyWith on AttendanceDayStatus {
  /// Returns a callable class that can be used as follows: `instanceOfAttendanceDayStatus.copyWith(...)` or like so:`instanceOfAttendanceDayStatus.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$AttendanceDayStatusCWProxy get copyWith =>
      _$AttendanceDayStatusCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AttendanceDayStatus _$AttendanceDayStatusFromJson(Map<String, dynamic> json) =>
    $checkedCreate('AttendanceDayStatus', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['attendanceRequired']);
      final val = AttendanceDayStatus(
        attendanceRequired: $checkedConvert(
          'attendanceRequired',
          (v) => v as bool,
        ),
        announcementId: $checkedConvert('announcementId', (v) => v as String?),
        title: $checkedConvert('title', (v) => v as String?),
        reason: $checkedConvert('reason', (v) => v as String?),
        holidayStartDate: $checkedConvert(
          'holidayStartDate',
          (v) => v == null ? null : DateTime.parse(v as String),
        ),
        holidayEndDate: $checkedConvert(
          'holidayEndDate',
          (v) => v == null ? null : DateTime.parse(v as String),
        ),
      );
      return val;
    });

Map<String, dynamic> _$AttendanceDayStatusToJson(
  AttendanceDayStatus instance,
) => <String, dynamic>{
  'attendanceRequired': instance.attendanceRequired,
  'announcementId': ?instance.announcementId,
  'title': ?instance.title,
  'reason': ?instance.reason,
  'holidayStartDate': ?instance.holidayStartDate?.toIso8601String(),
  'holidayEndDate': ?instance.holidayEndDate?.toIso8601String(),
};
