// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_reset_password_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$AdminResetPasswordResponseCWProxy {
  AdminResetPasswordResponse ok(bool ok);

  AdminResetPasswordResponse password(String password);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AdminResetPasswordResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AdminResetPasswordResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  AdminResetPasswordResponse call({bool ok, String password});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfAdminResetPasswordResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfAdminResetPasswordResponse.copyWith.fieldName(...)`
class _$AdminResetPasswordResponseCWProxyImpl
    implements _$AdminResetPasswordResponseCWProxy {
  const _$AdminResetPasswordResponseCWProxyImpl(this._value);

  final AdminResetPasswordResponse _value;

  @override
  AdminResetPasswordResponse ok(bool ok) => this(ok: ok);

  @override
  AdminResetPasswordResponse password(String password) =>
      this(password: password);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AdminResetPasswordResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AdminResetPasswordResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  AdminResetPasswordResponse call({
    Object? ok = const $CopyWithPlaceholder(),
    Object? password = const $CopyWithPlaceholder(),
  }) {
    return AdminResetPasswordResponse(
      ok: ok == const $CopyWithPlaceholder()
          ? _value.ok
          // ignore: cast_nullable_to_non_nullable
          : ok as bool,
      password: password == const $CopyWithPlaceholder()
          ? _value.password
          // ignore: cast_nullable_to_non_nullable
          : password as String,
    );
  }
}

extension $AdminResetPasswordResponseCopyWith on AdminResetPasswordResponse {
  /// Returns a callable class that can be used as follows: `instanceOfAdminResetPasswordResponse.copyWith(...)` or like so:`instanceOfAdminResetPasswordResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$AdminResetPasswordResponseCWProxy get copyWith =>
      _$AdminResetPasswordResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdminResetPasswordResponse _$AdminResetPasswordResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('AdminResetPasswordResponse', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['ok', 'password']);
  final val = AdminResetPasswordResponse(
    ok: $checkedConvert('ok', (v) => v as bool),
    password: $checkedConvert('password', (v) => v as String),
  );
  return val;
});

Map<String, dynamic> _$AdminResetPasswordResponseToJson(
  AdminResetPasswordResponse instance,
) => <String, dynamic>{'ok': instance.ok, 'password': instance.password};
