// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'year_rollover_result.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$YearRolloverResultCWProxy {
  YearRolloverResult closedYearId(String closedYearId);

  YearRolloverResult nextYearId(String nextYearId);

  YearRolloverResult nextYearCode(String nextYearCode);

  YearRolloverResult createdSemesterCount(int createdSemesterCount);

  YearRolloverResult createdClassCount(int createdClassCount);

  YearRolloverResult promotedCount(int promotedCount);

  YearRolloverResult retainedCount(int retainedCount);

  YearRolloverResult graduatedCount(int graduatedCount);

  YearRolloverResult nextYearActivated(bool nextYearActivated);

  YearRolloverResult completedAt(DateTime completedAt);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `YearRolloverResult(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// YearRolloverResult(...).copyWith(id: 12, name: "My name")
  /// ````
  YearRolloverResult call({
    String closedYearId,
    String nextYearId,
    String nextYearCode,
    int createdSemesterCount,
    int createdClassCount,
    int promotedCount,
    int retainedCount,
    int graduatedCount,
    bool nextYearActivated,
    DateTime completedAt,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfYearRolloverResult.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfYearRolloverResult.copyWith.fieldName(...)`
class _$YearRolloverResultCWProxyImpl implements _$YearRolloverResultCWProxy {
  const _$YearRolloverResultCWProxyImpl(this._value);

  final YearRolloverResult _value;

  @override
  YearRolloverResult closedYearId(String closedYearId) =>
      this(closedYearId: closedYearId);

  @override
  YearRolloverResult nextYearId(String nextYearId) =>
      this(nextYearId: nextYearId);

  @override
  YearRolloverResult nextYearCode(String nextYearCode) =>
      this(nextYearCode: nextYearCode);

  @override
  YearRolloverResult createdSemesterCount(int createdSemesterCount) =>
      this(createdSemesterCount: createdSemesterCount);

  @override
  YearRolloverResult createdClassCount(int createdClassCount) =>
      this(createdClassCount: createdClassCount);

  @override
  YearRolloverResult promotedCount(int promotedCount) =>
      this(promotedCount: promotedCount);

  @override
  YearRolloverResult retainedCount(int retainedCount) =>
      this(retainedCount: retainedCount);

  @override
  YearRolloverResult graduatedCount(int graduatedCount) =>
      this(graduatedCount: graduatedCount);

  @override
  YearRolloverResult nextYearActivated(bool nextYearActivated) =>
      this(nextYearActivated: nextYearActivated);

  @override
  YearRolloverResult completedAt(DateTime completedAt) =>
      this(completedAt: completedAt);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `YearRolloverResult(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// YearRolloverResult(...).copyWith(id: 12, name: "My name")
  /// ````
  YearRolloverResult call({
    Object? closedYearId = const $CopyWithPlaceholder(),
    Object? nextYearId = const $CopyWithPlaceholder(),
    Object? nextYearCode = const $CopyWithPlaceholder(),
    Object? createdSemesterCount = const $CopyWithPlaceholder(),
    Object? createdClassCount = const $CopyWithPlaceholder(),
    Object? promotedCount = const $CopyWithPlaceholder(),
    Object? retainedCount = const $CopyWithPlaceholder(),
    Object? graduatedCount = const $CopyWithPlaceholder(),
    Object? nextYearActivated = const $CopyWithPlaceholder(),
    Object? completedAt = const $CopyWithPlaceholder(),
  }) {
    return YearRolloverResult(
      closedYearId: closedYearId == const $CopyWithPlaceholder()
          ? _value.closedYearId
          // ignore: cast_nullable_to_non_nullable
          : closedYearId as String,
      nextYearId: nextYearId == const $CopyWithPlaceholder()
          ? _value.nextYearId
          // ignore: cast_nullable_to_non_nullable
          : nextYearId as String,
      nextYearCode: nextYearCode == const $CopyWithPlaceholder()
          ? _value.nextYearCode
          // ignore: cast_nullable_to_non_nullable
          : nextYearCode as String,
      createdSemesterCount: createdSemesterCount == const $CopyWithPlaceholder()
          ? _value.createdSemesterCount
          // ignore: cast_nullable_to_non_nullable
          : createdSemesterCount as int,
      createdClassCount: createdClassCount == const $CopyWithPlaceholder()
          ? _value.createdClassCount
          // ignore: cast_nullable_to_non_nullable
          : createdClassCount as int,
      promotedCount: promotedCount == const $CopyWithPlaceholder()
          ? _value.promotedCount
          // ignore: cast_nullable_to_non_nullable
          : promotedCount as int,
      retainedCount: retainedCount == const $CopyWithPlaceholder()
          ? _value.retainedCount
          // ignore: cast_nullable_to_non_nullable
          : retainedCount as int,
      graduatedCount: graduatedCount == const $CopyWithPlaceholder()
          ? _value.graduatedCount
          // ignore: cast_nullable_to_non_nullable
          : graduatedCount as int,
      nextYearActivated: nextYearActivated == const $CopyWithPlaceholder()
          ? _value.nextYearActivated
          // ignore: cast_nullable_to_non_nullable
          : nextYearActivated as bool,
      completedAt: completedAt == const $CopyWithPlaceholder()
          ? _value.completedAt
          // ignore: cast_nullable_to_non_nullable
          : completedAt as DateTime,
    );
  }
}

extension $YearRolloverResultCopyWith on YearRolloverResult {
  /// Returns a callable class that can be used as follows: `instanceOfYearRolloverResult.copyWith(...)` or like so:`instanceOfYearRolloverResult.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$YearRolloverResultCWProxy get copyWith =>
      _$YearRolloverResultCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

YearRolloverResult _$YearRolloverResultFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('YearRolloverResult', json, ($checkedConvert) {
  $checkKeys(
    json,
    requiredKeys: const [
      'closedYearId',
      'nextYearId',
      'nextYearCode',
      'createdSemesterCount',
      'createdClassCount',
      'promotedCount',
      'retainedCount',
      'graduatedCount',
      'nextYearActivated',
      'completedAt',
    ],
  );
  final val = YearRolloverResult(
    closedYearId: $checkedConvert('closedYearId', (v) => v as String),
    nextYearId: $checkedConvert('nextYearId', (v) => v as String),
    nextYearCode: $checkedConvert('nextYearCode', (v) => v as String),
    createdSemesterCount: $checkedConvert(
      'createdSemesterCount',
      (v) => (v as num).toInt(),
    ),
    createdClassCount: $checkedConvert(
      'createdClassCount',
      (v) => (v as num).toInt(),
    ),
    promotedCount: $checkedConvert('promotedCount', (v) => (v as num).toInt()),
    retainedCount: $checkedConvert('retainedCount', (v) => (v as num).toInt()),
    graduatedCount: $checkedConvert(
      'graduatedCount',
      (v) => (v as num).toInt(),
    ),
    nextYearActivated: $checkedConvert('nextYearActivated', (v) => v as bool),
    completedAt: $checkedConvert(
      'completedAt',
      (v) => DateTime.parse(v as String),
    ),
  );
  return val;
});

Map<String, dynamic> _$YearRolloverResultToJson(YearRolloverResult instance) =>
    <String, dynamic>{
      'closedYearId': instance.closedYearId,
      'nextYearId': instance.nextYearId,
      'nextYearCode': instance.nextYearCode,
      'createdSemesterCount': instance.createdSemesterCount,
      'createdClassCount': instance.createdClassCount,
      'promotedCount': instance.promotedCount,
      'retainedCount': instance.retainedCount,
      'graduatedCount': instance.graduatedCount,
      'nextYearActivated': instance.nextYearActivated,
      'completedAt': instance.completedAt.toIso8601String(),
    };
