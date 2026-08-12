// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'year_rollover_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$YearRolloverRequestCWProxy {
  YearRolloverRequest nextYearCode(String nextYearCode);

  YearRolloverRequest nextYearName(String? nextYearName);

  YearRolloverRequest startDate(DateTime startDate);

  YearRolloverRequest endDate(DateTime endDate);

  YearRolloverRequest createIntakeClasses(bool? createIntakeClasses);

  YearRolloverRequest activateNextYear(bool? activateNextYear);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `YearRolloverRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// YearRolloverRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  YearRolloverRequest call({
    String nextYearCode,
    String? nextYearName,
    DateTime startDate,
    DateTime endDate,
    bool? createIntakeClasses,
    bool? activateNextYear,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfYearRolloverRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfYearRolloverRequest.copyWith.fieldName(...)`
class _$YearRolloverRequestCWProxyImpl implements _$YearRolloverRequestCWProxy {
  const _$YearRolloverRequestCWProxyImpl(this._value);

  final YearRolloverRequest _value;

  @override
  YearRolloverRequest nextYearCode(String nextYearCode) =>
      this(nextYearCode: nextYearCode);

  @override
  YearRolloverRequest nextYearName(String? nextYearName) =>
      this(nextYearName: nextYearName);

  @override
  YearRolloverRequest startDate(DateTime startDate) =>
      this(startDate: startDate);

  @override
  YearRolloverRequest endDate(DateTime endDate) => this(endDate: endDate);

  @override
  YearRolloverRequest createIntakeClasses(bool? createIntakeClasses) =>
      this(createIntakeClasses: createIntakeClasses);

  @override
  YearRolloverRequest activateNextYear(bool? activateNextYear) =>
      this(activateNextYear: activateNextYear);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `YearRolloverRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// YearRolloverRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  YearRolloverRequest call({
    Object? nextYearCode = const $CopyWithPlaceholder(),
    Object? nextYearName = const $CopyWithPlaceholder(),
    Object? startDate = const $CopyWithPlaceholder(),
    Object? endDate = const $CopyWithPlaceholder(),
    Object? createIntakeClasses = const $CopyWithPlaceholder(),
    Object? activateNextYear = const $CopyWithPlaceholder(),
  }) {
    return YearRolloverRequest(
      nextYearCode: nextYearCode == const $CopyWithPlaceholder()
          ? _value.nextYearCode
          // ignore: cast_nullable_to_non_nullable
          : nextYearCode as String,
      nextYearName: nextYearName == const $CopyWithPlaceholder()
          ? _value.nextYearName
          // ignore: cast_nullable_to_non_nullable
          : nextYearName as String?,
      startDate: startDate == const $CopyWithPlaceholder()
          ? _value.startDate
          // ignore: cast_nullable_to_non_nullable
          : startDate as DateTime,
      endDate: endDate == const $CopyWithPlaceholder()
          ? _value.endDate
          // ignore: cast_nullable_to_non_nullable
          : endDate as DateTime,
      createIntakeClasses: createIntakeClasses == const $CopyWithPlaceholder()
          ? _value.createIntakeClasses
          // ignore: cast_nullable_to_non_nullable
          : createIntakeClasses as bool?,
      activateNextYear: activateNextYear == const $CopyWithPlaceholder()
          ? _value.activateNextYear
          // ignore: cast_nullable_to_non_nullable
          : activateNextYear as bool?,
    );
  }
}

extension $YearRolloverRequestCopyWith on YearRolloverRequest {
  /// Returns a callable class that can be used as follows: `instanceOfYearRolloverRequest.copyWith(...)` or like so:`instanceOfYearRolloverRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$YearRolloverRequestCWProxy get copyWith =>
      _$YearRolloverRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

YearRolloverRequest _$YearRolloverRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('YearRolloverRequest', json, ($checkedConvert) {
  $checkKeys(
    json,
    requiredKeys: const ['nextYearCode', 'startDate', 'endDate'],
  );
  final val = YearRolloverRequest(
    nextYearCode: $checkedConvert('nextYearCode', (v) => v as String),
    nextYearName: $checkedConvert('nextYearName', (v) => v as String?),
    startDate: $checkedConvert('startDate', (v) => DateTime.parse(v as String)),
    endDate: $checkedConvert('endDate', (v) => DateTime.parse(v as String)),
    createIntakeClasses: $checkedConvert(
      'createIntakeClasses',
      (v) => v as bool?,
    ),
    activateNextYear: $checkedConvert('activateNextYear', (v) => v as bool?),
  );
  return val;
});

Map<String, dynamic> _$YearRolloverRequestToJson(
  YearRolloverRequest instance,
) => <String, dynamic>{
  'nextYearCode': instance.nextYearCode,
  'nextYearName': ?instance.nextYearName,
  'startDate': instance.startDate.toIso8601String(),
  'endDate': instance.endDate.toIso8601String(),
  'createIntakeClasses': ?instance.createIntakeClasses,
  'activateNextYear': ?instance.activateNextYear,
};
