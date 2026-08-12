// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'year_rollover_class_plan.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$YearRolloverClassPlanCWProxy {
  YearRolloverClassPlan sourceClassId(String sourceClassId);

  YearRolloverClassPlan sourceClassCode(String sourceClassCode);

  YearRolloverClassPlan targetClassCode(String targetClassCode);

  YearRolloverClassPlan targetGradeLevel(String targetGradeLevel);

  YearRolloverClassPlan type(String type);

  YearRolloverClassPlan capacity(int capacity);

  YearRolloverClassPlan studyShift(String studyShift);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `YearRolloverClassPlan(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// YearRolloverClassPlan(...).copyWith(id: 12, name: "My name")
  /// ````
  YearRolloverClassPlan call({
    String sourceClassId,
    String sourceClassCode,
    String targetClassCode,
    String targetGradeLevel,
    String type,
    int capacity,
    String studyShift,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfYearRolloverClassPlan.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfYearRolloverClassPlan.copyWith.fieldName(...)`
class _$YearRolloverClassPlanCWProxyImpl
    implements _$YearRolloverClassPlanCWProxy {
  const _$YearRolloverClassPlanCWProxyImpl(this._value);

  final YearRolloverClassPlan _value;

  @override
  YearRolloverClassPlan sourceClassId(String sourceClassId) =>
      this(sourceClassId: sourceClassId);

  @override
  YearRolloverClassPlan sourceClassCode(String sourceClassCode) =>
      this(sourceClassCode: sourceClassCode);

  @override
  YearRolloverClassPlan targetClassCode(String targetClassCode) =>
      this(targetClassCode: targetClassCode);

  @override
  YearRolloverClassPlan targetGradeLevel(String targetGradeLevel) =>
      this(targetGradeLevel: targetGradeLevel);

  @override
  YearRolloverClassPlan type(String type) => this(type: type);

  @override
  YearRolloverClassPlan capacity(int capacity) => this(capacity: capacity);

  @override
  YearRolloverClassPlan studyShift(String studyShift) =>
      this(studyShift: studyShift);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `YearRolloverClassPlan(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// YearRolloverClassPlan(...).copyWith(id: 12, name: "My name")
  /// ````
  YearRolloverClassPlan call({
    Object? sourceClassId = const $CopyWithPlaceholder(),
    Object? sourceClassCode = const $CopyWithPlaceholder(),
    Object? targetClassCode = const $CopyWithPlaceholder(),
    Object? targetGradeLevel = const $CopyWithPlaceholder(),
    Object? type = const $CopyWithPlaceholder(),
    Object? capacity = const $CopyWithPlaceholder(),
    Object? studyShift = const $CopyWithPlaceholder(),
  }) {
    return YearRolloverClassPlan(
      sourceClassId: sourceClassId == const $CopyWithPlaceholder()
          ? _value.sourceClassId
          // ignore: cast_nullable_to_non_nullable
          : sourceClassId as String,
      sourceClassCode: sourceClassCode == const $CopyWithPlaceholder()
          ? _value.sourceClassCode
          // ignore: cast_nullable_to_non_nullable
          : sourceClassCode as String,
      targetClassCode: targetClassCode == const $CopyWithPlaceholder()
          ? _value.targetClassCode
          // ignore: cast_nullable_to_non_nullable
          : targetClassCode as String,
      targetGradeLevel: targetGradeLevel == const $CopyWithPlaceholder()
          ? _value.targetGradeLevel
          // ignore: cast_nullable_to_non_nullable
          : targetGradeLevel as String,
      type: type == const $CopyWithPlaceholder()
          ? _value.type
          // ignore: cast_nullable_to_non_nullable
          : type as String,
      capacity: capacity == const $CopyWithPlaceholder()
          ? _value.capacity
          // ignore: cast_nullable_to_non_nullable
          : capacity as int,
      studyShift: studyShift == const $CopyWithPlaceholder()
          ? _value.studyShift
          // ignore: cast_nullable_to_non_nullable
          : studyShift as String,
    );
  }
}

extension $YearRolloverClassPlanCopyWith on YearRolloverClassPlan {
  /// Returns a callable class that can be used as follows: `instanceOfYearRolloverClassPlan.copyWith(...)` or like so:`instanceOfYearRolloverClassPlan.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$YearRolloverClassPlanCWProxy get copyWith =>
      _$YearRolloverClassPlanCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

YearRolloverClassPlan _$YearRolloverClassPlanFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('YearRolloverClassPlan', json, ($checkedConvert) {
  $checkKeys(
    json,
    requiredKeys: const [
      'sourceClassId',
      'sourceClassCode',
      'targetClassCode',
      'targetGradeLevel',
      'type',
      'capacity',
      'studyShift',
    ],
  );
  final val = YearRolloverClassPlan(
    sourceClassId: $checkedConvert('sourceClassId', (v) => v as String),
    sourceClassCode: $checkedConvert('sourceClassCode', (v) => v as String),
    targetClassCode: $checkedConvert('targetClassCode', (v) => v as String),
    targetGradeLevel: $checkedConvert('targetGradeLevel', (v) => v as String),
    type: $checkedConvert('type', (v) => v as String),
    capacity: $checkedConvert('capacity', (v) => (v as num).toInt()),
    studyShift: $checkedConvert('studyShift', (v) => v as String),
  );
  return val;
});

Map<String, dynamic> _$YearRolloverClassPlanToJson(
  YearRolloverClassPlan instance,
) => <String, dynamic>{
  'sourceClassId': instance.sourceClassId,
  'sourceClassCode': instance.sourceClassCode,
  'targetClassCode': instance.targetClassCode,
  'targetGradeLevel': instance.targetGradeLevel,
  'type': instance.type,
  'capacity': instance.capacity,
  'studyShift': instance.studyShift,
};
