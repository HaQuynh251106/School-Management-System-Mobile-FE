// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'unlock_attendance_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$UnlockAttendanceRequestCWProxy {
  UnlockAttendanceRequest slotId(String slotId);

  UnlockAttendanceRequest date(DateTime date);

  UnlockAttendanceRequest reason(String reason);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `UnlockAttendanceRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// UnlockAttendanceRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  UnlockAttendanceRequest call({String slotId, DateTime date, String reason});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfUnlockAttendanceRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfUnlockAttendanceRequest.copyWith.fieldName(...)`
class _$UnlockAttendanceRequestCWProxyImpl
    implements _$UnlockAttendanceRequestCWProxy {
  const _$UnlockAttendanceRequestCWProxyImpl(this._value);

  final UnlockAttendanceRequest _value;

  @override
  UnlockAttendanceRequest slotId(String slotId) => this(slotId: slotId);

  @override
  UnlockAttendanceRequest date(DateTime date) => this(date: date);

  @override
  UnlockAttendanceRequest reason(String reason) => this(reason: reason);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `UnlockAttendanceRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// UnlockAttendanceRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  UnlockAttendanceRequest call({
    Object? slotId = const $CopyWithPlaceholder(),
    Object? date = const $CopyWithPlaceholder(),
    Object? reason = const $CopyWithPlaceholder(),
  }) {
    return UnlockAttendanceRequest(
      slotId: slotId == const $CopyWithPlaceholder()
          ? _value.slotId
          // ignore: cast_nullable_to_non_nullable
          : slotId as String,
      date: date == const $CopyWithPlaceholder()
          ? _value.date
          // ignore: cast_nullable_to_non_nullable
          : date as DateTime,
      reason: reason == const $CopyWithPlaceholder()
          ? _value.reason
          // ignore: cast_nullable_to_non_nullable
          : reason as String,
    );
  }
}

extension $UnlockAttendanceRequestCopyWith on UnlockAttendanceRequest {
  /// Returns a callable class that can be used as follows: `instanceOfUnlockAttendanceRequest.copyWith(...)` or like so:`instanceOfUnlockAttendanceRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$UnlockAttendanceRequestCWProxy get copyWith =>
      _$UnlockAttendanceRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UnlockAttendanceRequest _$UnlockAttendanceRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('UnlockAttendanceRequest', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['slotId', 'date', 'reason']);
  final val = UnlockAttendanceRequest(
    slotId: $checkedConvert('slotId', (v) => v as String),
    date: $checkedConvert('date', (v) => DateTime.parse(v as String)),
    reason: $checkedConvert('reason', (v) => v as String),
  );
  return val;
});

Map<String, dynamic> _$UnlockAttendanceRequestToJson(
  UnlockAttendanceRequest instance,
) => <String, dynamic>{
  'slotId': instance.slotId,
  'date': instance.date.toIso8601String(),
  'reason': instance.reason,
};
