// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendance_session_status.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$AttendanceSessionStatusCWProxy {
  AttendanceSessionStatus state(String state);

  AttendanceSessionStatus canMark(bool canMark);

  AttendanceSessionStatus requiresUnlockReason(bool requiresUnlockReason);

  AttendanceSessionStatus message(String message);

  AttendanceSessionStatus date(DateTime date);

  AttendanceSessionStatus startTime(String? startTime);

  AttendanceSessionStatus endTime(String? endTime);

  AttendanceSessionStatus unlockReason(String? unlockReason);

  AttendanceSessionStatus unlockedAt(DateTime? unlockedAt);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AttendanceSessionStatus(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AttendanceSessionStatus(...).copyWith(id: 12, name: "My name")
  /// ````
  AttendanceSessionStatus call({
    String state,
    bool canMark,
    bool requiresUnlockReason,
    String message,
    DateTime date,
    String? startTime,
    String? endTime,
    String? unlockReason,
    DateTime? unlockedAt,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfAttendanceSessionStatus.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfAttendanceSessionStatus.copyWith.fieldName(...)`
class _$AttendanceSessionStatusCWProxyImpl
    implements _$AttendanceSessionStatusCWProxy {
  const _$AttendanceSessionStatusCWProxyImpl(this._value);

  final AttendanceSessionStatus _value;

  @override
  AttendanceSessionStatus state(String state) => this(state: state);

  @override
  AttendanceSessionStatus canMark(bool canMark) => this(canMark: canMark);

  @override
  AttendanceSessionStatus requiresUnlockReason(bool requiresUnlockReason) =>
      this(requiresUnlockReason: requiresUnlockReason);

  @override
  AttendanceSessionStatus message(String message) => this(message: message);

  @override
  AttendanceSessionStatus date(DateTime date) => this(date: date);

  @override
  AttendanceSessionStatus startTime(String? startTime) =>
      this(startTime: startTime);

  @override
  AttendanceSessionStatus endTime(String? endTime) => this(endTime: endTime);

  @override
  AttendanceSessionStatus unlockReason(String? unlockReason) =>
      this(unlockReason: unlockReason);

  @override
  AttendanceSessionStatus unlockedAt(DateTime? unlockedAt) =>
      this(unlockedAt: unlockedAt);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AttendanceSessionStatus(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AttendanceSessionStatus(...).copyWith(id: 12, name: "My name")
  /// ````
  AttendanceSessionStatus call({
    Object? state = const $CopyWithPlaceholder(),
    Object? canMark = const $CopyWithPlaceholder(),
    Object? requiresUnlockReason = const $CopyWithPlaceholder(),
    Object? message = const $CopyWithPlaceholder(),
    Object? date = const $CopyWithPlaceholder(),
    Object? startTime = const $CopyWithPlaceholder(),
    Object? endTime = const $CopyWithPlaceholder(),
    Object? unlockReason = const $CopyWithPlaceholder(),
    Object? unlockedAt = const $CopyWithPlaceholder(),
  }) {
    return AttendanceSessionStatus(
      state: state == const $CopyWithPlaceholder()
          ? _value.state
          // ignore: cast_nullable_to_non_nullable
          : state as String,
      canMark: canMark == const $CopyWithPlaceholder()
          ? _value.canMark
          // ignore: cast_nullable_to_non_nullable
          : canMark as bool,
      requiresUnlockReason: requiresUnlockReason == const $CopyWithPlaceholder()
          ? _value.requiresUnlockReason
          // ignore: cast_nullable_to_non_nullable
          : requiresUnlockReason as bool,
      message: message == const $CopyWithPlaceholder()
          ? _value.message
          // ignore: cast_nullable_to_non_nullable
          : message as String,
      date: date == const $CopyWithPlaceholder()
          ? _value.date
          // ignore: cast_nullable_to_non_nullable
          : date as DateTime,
      startTime: startTime == const $CopyWithPlaceholder()
          ? _value.startTime
          // ignore: cast_nullable_to_non_nullable
          : startTime as String?,
      endTime: endTime == const $CopyWithPlaceholder()
          ? _value.endTime
          // ignore: cast_nullable_to_non_nullable
          : endTime as String?,
      unlockReason: unlockReason == const $CopyWithPlaceholder()
          ? _value.unlockReason
          // ignore: cast_nullable_to_non_nullable
          : unlockReason as String?,
      unlockedAt: unlockedAt == const $CopyWithPlaceholder()
          ? _value.unlockedAt
          // ignore: cast_nullable_to_non_nullable
          : unlockedAt as DateTime?,
    );
  }
}

extension $AttendanceSessionStatusCopyWith on AttendanceSessionStatus {
  /// Returns a callable class that can be used as follows: `instanceOfAttendanceSessionStatus.copyWith(...)` or like so:`instanceOfAttendanceSessionStatus.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$AttendanceSessionStatusCWProxy get copyWith =>
      _$AttendanceSessionStatusCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AttendanceSessionStatus _$AttendanceSessionStatusFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('AttendanceSessionStatus', json, ($checkedConvert) {
  $checkKeys(
    json,
    requiredKeys: const [
      'state',
      'canMark',
      'requiresUnlockReason',
      'message',
      'date',
    ],
  );
  final val = AttendanceSessionStatus(
    state: $checkedConvert('state', (v) => v as String),
    canMark: $checkedConvert('canMark', (v) => v as bool),
    requiresUnlockReason: $checkedConvert(
      'requiresUnlockReason',
      (v) => v as bool,
    ),
    message: $checkedConvert('message', (v) => v as String),
    date: $checkedConvert('date', (v) => DateTime.parse(v as String)),
    startTime: $checkedConvert('startTime', (v) => v as String?),
    endTime: $checkedConvert('endTime', (v) => v as String?),
    unlockReason: $checkedConvert('unlockReason', (v) => v as String?),
    unlockedAt: $checkedConvert(
      'unlockedAt',
      (v) => v == null ? null : DateTime.parse(v as String),
    ),
  );
  return val;
});

Map<String, dynamic> _$AttendanceSessionStatusToJson(
  AttendanceSessionStatus instance,
) => <String, dynamic>{
  'state': instance.state,
  'canMark': instance.canMark,
  'requiresUnlockReason': instance.requiresUnlockReason,
  'message': instance.message,
  'date': instance.date.toIso8601String(),
  'startTime': ?instance.startTime,
  'endTime': ?instance.endTime,
  'unlockReason': ?instance.unlockReason,
  'unlockedAt': ?instance.unlockedAt?.toIso8601String(),
};
