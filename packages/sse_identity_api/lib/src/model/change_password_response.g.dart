// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'change_password_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ChangePasswordResponseCWProxy {
  ChangePasswordResponse ok(bool ok);

  ChangePasswordResponse reauthenticationRequired(
    bool reauthenticationRequired,
  );

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ChangePasswordResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ChangePasswordResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  ChangePasswordResponse call({bool ok, bool reauthenticationRequired});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfChangePasswordResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfChangePasswordResponse.copyWith.fieldName(...)`
class _$ChangePasswordResponseCWProxyImpl
    implements _$ChangePasswordResponseCWProxy {
  const _$ChangePasswordResponseCWProxyImpl(this._value);

  final ChangePasswordResponse _value;

  @override
  ChangePasswordResponse ok(bool ok) => this(ok: ok);

  @override
  ChangePasswordResponse reauthenticationRequired(
    bool reauthenticationRequired,
  ) => this(reauthenticationRequired: reauthenticationRequired);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ChangePasswordResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ChangePasswordResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  ChangePasswordResponse call({
    Object? ok = const $CopyWithPlaceholder(),
    Object? reauthenticationRequired = const $CopyWithPlaceholder(),
  }) {
    return ChangePasswordResponse(
      ok: ok == const $CopyWithPlaceholder()
          ? _value.ok
          // ignore: cast_nullable_to_non_nullable
          : ok as bool,
      reauthenticationRequired:
          reauthenticationRequired == const $CopyWithPlaceholder()
          ? _value.reauthenticationRequired
          // ignore: cast_nullable_to_non_nullable
          : reauthenticationRequired as bool,
    );
  }
}

extension $ChangePasswordResponseCopyWith on ChangePasswordResponse {
  /// Returns a callable class that can be used as follows: `instanceOfChangePasswordResponse.copyWith(...)` or like so:`instanceOfChangePasswordResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ChangePasswordResponseCWProxy get copyWith =>
      _$ChangePasswordResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChangePasswordResponse _$ChangePasswordResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('ChangePasswordResponse', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['ok', 'reauthenticationRequired']);
  final val = ChangePasswordResponse(
    ok: $checkedConvert('ok', (v) => v as bool),
    reauthenticationRequired: $checkedConvert(
      'reauthenticationRequired',
      (v) => v as bool,
    ),
  );
  return val;
});

Map<String, dynamic> _$ChangePasswordResponseToJson(
  ChangePasswordResponse instance,
) => <String, dynamic>{
  'ok': instance.ok,
  'reauthenticationRequired': instance.reauthenticationRequired,
};
