// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'save_exam_category_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$SaveExamCategoryRequestCWProxy {
  SaveExamCategoryRequest id(String? id);

  SaveExamCategoryRequest code(String code);

  SaveExamCategoryRequest name(String name);

  SaveExamCategoryRequest weight(num? weight);

  SaveExamCategoryRequest requiredCount(int? requiredCount);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SaveExamCategoryRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SaveExamCategoryRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  SaveExamCategoryRequest call({
    String? id,
    String code,
    String name,
    num? weight,
    int? requiredCount,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfSaveExamCategoryRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfSaveExamCategoryRequest.copyWith.fieldName(...)`
class _$SaveExamCategoryRequestCWProxyImpl
    implements _$SaveExamCategoryRequestCWProxy {
  const _$SaveExamCategoryRequestCWProxyImpl(this._value);

  final SaveExamCategoryRequest _value;

  @override
  SaveExamCategoryRequest id(String? id) => this(id: id);

  @override
  SaveExamCategoryRequest code(String code) => this(code: code);

  @override
  SaveExamCategoryRequest name(String name) => this(name: name);

  @override
  SaveExamCategoryRequest weight(num? weight) => this(weight: weight);

  @override
  SaveExamCategoryRequest requiredCount(int? requiredCount) =>
      this(requiredCount: requiredCount);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `SaveExamCategoryRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// SaveExamCategoryRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  SaveExamCategoryRequest call({
    Object? id = const $CopyWithPlaceholder(),
    Object? code = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
    Object? weight = const $CopyWithPlaceholder(),
    Object? requiredCount = const $CopyWithPlaceholder(),
  }) {
    return SaveExamCategoryRequest(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String?,
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
          : weight as num?,
      requiredCount: requiredCount == const $CopyWithPlaceholder()
          ? _value.requiredCount
          // ignore: cast_nullable_to_non_nullable
          : requiredCount as int?,
    );
  }
}

extension $SaveExamCategoryRequestCopyWith on SaveExamCategoryRequest {
  /// Returns a callable class that can be used as follows: `instanceOfSaveExamCategoryRequest.copyWith(...)` or like so:`instanceOfSaveExamCategoryRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$SaveExamCategoryRequestCWProxy get copyWith =>
      _$SaveExamCategoryRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SaveExamCategoryRequest _$SaveExamCategoryRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('SaveExamCategoryRequest', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['code', 'name']);
  final val = SaveExamCategoryRequest(
    id: $checkedConvert('id', (v) => v as String?),
    code: $checkedConvert('code', (v) => v as String),
    name: $checkedConvert('name', (v) => v as String),
    weight: $checkedConvert('weight', (v) => v as num?),
    requiredCount: $checkedConvert(
      'requiredCount',
      (v) => (v as num?)?.toInt(),
    ),
  );
  return val;
});

Map<String, dynamic> _$SaveExamCategoryRequestToJson(
  SaveExamCategoryRequest instance,
) => <String, dynamic>{
  'id': ?instance.id,
  'code': instance.code,
  'name': instance.name,
  'weight': ?instance.weight,
  'requiredCount': ?instance.requiredCount,
};
