// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exam_category.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ExamCategoryCWProxy {
  ExamCategory id(String id);

  ExamCategory code(String code);

  ExamCategory name(String name);

  ExamCategory weight(num weight);

  ExamCategory requiredCount(int requiredCount);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ExamCategory(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ExamCategory(...).copyWith(id: 12, name: "My name")
  /// ````
  ExamCategory call({
    String id,
    String code,
    String name,
    num weight,
    int requiredCount,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfExamCategory.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfExamCategory.copyWith.fieldName(...)`
class _$ExamCategoryCWProxyImpl implements _$ExamCategoryCWProxy {
  const _$ExamCategoryCWProxyImpl(this._value);

  final ExamCategory _value;

  @override
  ExamCategory id(String id) => this(id: id);

  @override
  ExamCategory code(String code) => this(code: code);

  @override
  ExamCategory name(String name) => this(name: name);

  @override
  ExamCategory weight(num weight) => this(weight: weight);

  @override
  ExamCategory requiredCount(int requiredCount) =>
      this(requiredCount: requiredCount);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ExamCategory(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ExamCategory(...).copyWith(id: 12, name: "My name")
  /// ````
  ExamCategory call({
    Object? id = const $CopyWithPlaceholder(),
    Object? code = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
    Object? weight = const $CopyWithPlaceholder(),
    Object? requiredCount = const $CopyWithPlaceholder(),
  }) {
    return ExamCategory(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
      code: code == const $CopyWithPlaceholder()
          ? _value.code
          // ignore: cast_nullable_to_non_nullable
          : code as String,
      name: name == const $CopyWithPlaceholder()
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String,
      weight: weight == const $CopyWithPlaceholder()
          ? _value.weight
          // ignore: cast_nullable_to_non_nullable
          : weight as num,
      requiredCount: requiredCount == const $CopyWithPlaceholder()
          ? _value.requiredCount
          // ignore: cast_nullable_to_non_nullable
          : requiredCount as int,
    );
  }
}

extension $ExamCategoryCopyWith on ExamCategory {
  /// Returns a callable class that can be used as follows: `instanceOfExamCategory.copyWith(...)` or like so:`instanceOfExamCategory.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ExamCategoryCWProxy get copyWith => _$ExamCategoryCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExamCategory _$ExamCategoryFromJson(Map<String, dynamic> json) =>
    $checkedCreate('ExamCategory', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const ['id', 'code', 'name', 'weight', 'requiredCount'],
      );
      final val = ExamCategory(
        id: $checkedConvert('id', (v) => v as String),
        code: $checkedConvert('code', (v) => v as String),
        name: $checkedConvert('name', (v) => v as String),
        weight: $checkedConvert('weight', (v) => v as num),
        requiredCount: $checkedConvert(
          'requiredCount',
          (v) => (v as num).toInt(),
        ),
      );
      return val;
    });

Map<String, dynamic> _$ExamCategoryToJson(ExamCategory instance) =>
    <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'name': instance.name,
      'weight': instance.weight,
      'requiredCount': instance.requiredCount,
    };
