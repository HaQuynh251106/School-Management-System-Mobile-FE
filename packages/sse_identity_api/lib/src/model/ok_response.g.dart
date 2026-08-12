// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ok_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$OkResponseCWProxy {
  OkResponse ok(bool ok);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `OkResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// OkResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  OkResponse call({bool ok});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfOkResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfOkResponse.copyWith.fieldName(...)`
class _$OkResponseCWProxyImpl implements _$OkResponseCWProxy {
  const _$OkResponseCWProxyImpl(this._value);

  final OkResponse _value;

  @override
  OkResponse ok(bool ok) => this(ok: ok);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `OkResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// OkResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  OkResponse call({Object? ok = const $CopyWithPlaceholder()}) {
    return OkResponse(
      ok: ok == const $CopyWithPlaceholder()
          ? _value.ok
          // ignore: cast_nullable_to_non_nullable
          : ok as bool,
    );
  }
}

extension $OkResponseCopyWith on OkResponse {
  /// Returns a callable class that can be used as follows: `instanceOfOkResponse.copyWith(...)` or like so:`instanceOfOkResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$OkResponseCWProxy get copyWith => _$OkResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OkResponse _$OkResponseFromJson(Map<String, dynamic> json) =>
    $checkedCreate('OkResponse', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['ok']);
      final val = OkResponse(ok: $checkedConvert('ok', (v) => v as bool));
      return val;
    });

Map<String, dynamic> _$OkResponseToJson(OkResponse instance) =>
    <String, dynamic>{'ok': instance.ok};
