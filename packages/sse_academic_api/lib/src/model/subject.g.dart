// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subject.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$SubjectCWProxy {
  Subject id(String id);

  Subject code(String code);

  Subject name(String name);

  Subject coefficient(num coefficient);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Subject(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Subject(...).copyWith(id: 12, name: "My name")
  /// ````
  Subject call({String id, String code, String name, num coefficient});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfSubject.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfSubject.copyWith.fieldName(...)`
class _$SubjectCWProxyImpl implements _$SubjectCWProxy {
  const _$SubjectCWProxyImpl(this._value);

  final Subject _value;

  @override
  Subject id(String id) => this(id: id);

  @override
  Subject code(String code) => this(code: code);

  @override
  Subject name(String name) => this(name: name);

  @override
  Subject coefficient(num coefficient) => this(coefficient: coefficient);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Subject(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Subject(...).copyWith(id: 12, name: "My name")
  /// ````
  Subject call({
    Object? id = const $CopyWithPlaceholder(),
    Object? code = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
    Object? coefficient = const $CopyWithPlaceholder(),
  }) {
    return Subject(
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
      coefficient: coefficient == const $CopyWithPlaceholder()
          ? _value.coefficient
          // ignore: cast_nullable_to_non_nullable
          : coefficient as num,
    );
  }
}

extension $SubjectCopyWith on Subject {
  /// Returns a callable class that can be used as follows: `instanceOfSubject.copyWith(...)` or like so:`instanceOfSubject.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$SubjectCWProxy get copyWith => _$SubjectCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Subject _$SubjectFromJson(Map<String, dynamic> json) => $checkedCreate(
  'Subject',
  json,
  ($checkedConvert) {
    $checkKeys(json, requiredKeys: const ['id', 'code', 'name', 'coefficient']);
    final val = Subject(
      id: $checkedConvert('id', (v) => v as String),
      code: $checkedConvert('code', (v) => v as String),
      name: $checkedConvert('name', (v) => v as String),
      coefficient: $checkedConvert('coefficient', (v) => v as num),
    );
    return val;
  },
);

Map<String, dynamic> _$SubjectToJson(Subject instance) => <String, dynamic>{
  'id': instance.id,
  'code': instance.code,
  'name': instance.name,
  'coefficient': instance.coefficient,
};
