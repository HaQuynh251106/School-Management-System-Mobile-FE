// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_subject_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$CreateSubjectRequestCWProxy {
  CreateSubjectRequest id(String? id);

  CreateSubjectRequest code(String code);

  CreateSubjectRequest name(String name);

  CreateSubjectRequest coefficient(num? coefficient);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CreateSubjectRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CreateSubjectRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  CreateSubjectRequest call({
    String? id,
    String code,
    String name,
    num? coefficient,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCreateSubjectRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCreateSubjectRequest.copyWith.fieldName(...)`
class _$CreateSubjectRequestCWProxyImpl
    implements _$CreateSubjectRequestCWProxy {
  const _$CreateSubjectRequestCWProxyImpl(this._value);

  final CreateSubjectRequest _value;

  @override
  CreateSubjectRequest id(String? id) => this(id: id);

  @override
  CreateSubjectRequest code(String code) => this(code: code);

  @override
  CreateSubjectRequest name(String name) => this(name: name);

  @override
  CreateSubjectRequest coefficient(num? coefficient) =>
      this(coefficient: coefficient);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CreateSubjectRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CreateSubjectRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  CreateSubjectRequest call({
    Object? id = const $CopyWithPlaceholder(),
    Object? code = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
    Object? coefficient = const $CopyWithPlaceholder(),
  }) {
    return CreateSubjectRequest(
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
      coefficient: coefficient == const $CopyWithPlaceholder()
          ? _value.coefficient
          // ignore: cast_nullable_to_non_nullable
          : coefficient as num?,
    );
  }
}

extension $CreateSubjectRequestCopyWith on CreateSubjectRequest {
  /// Returns a callable class that can be used as follows: `instanceOfCreateSubjectRequest.copyWith(...)` or like so:`instanceOfCreateSubjectRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CreateSubjectRequestCWProxy get copyWith =>
      _$CreateSubjectRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateSubjectRequest _$CreateSubjectRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('CreateSubjectRequest', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['code', 'name']);
  final val = CreateSubjectRequest(
    id: $checkedConvert('id', (v) => v as String?),
    code: $checkedConvert('code', (v) => v as String),
    name: $checkedConvert('name', (v) => v as String),
    coefficient: $checkedConvert('coefficient', (v) => v as num?),
  );
  return val;
});

Map<String, dynamic> _$CreateSubjectRequestToJson(
  CreateSubjectRequest instance,
) => <String, dynamic>{
  'id': ?instance.id,
  'code': instance.code,
  'name': instance.name,
  'coefficient': ?instance.coefficient,
};
