// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'forgot_password_response.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ForgotPasswordResponseCWProxy {
  ForgotPasswordResponse ok(bool ok);

  ForgotPasswordResponse message(String message);

  ForgotPasswordResponse devResetToken(String? devResetToken);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ForgotPasswordResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ForgotPasswordResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  ForgotPasswordResponse call({bool ok, String message, String? devResetToken});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfForgotPasswordResponse.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfForgotPasswordResponse.copyWith.fieldName(...)`
class _$ForgotPasswordResponseCWProxyImpl
    implements _$ForgotPasswordResponseCWProxy {
  const _$ForgotPasswordResponseCWProxyImpl(this._value);

  final ForgotPasswordResponse _value;

  @override
  ForgotPasswordResponse ok(bool ok) => this(ok: ok);

  @override
  ForgotPasswordResponse message(String message) => this(message: message);

  @override
  ForgotPasswordResponse devResetToken(String? devResetToken) =>
      this(devResetToken: devResetToken);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ForgotPasswordResponse(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ForgotPasswordResponse(...).copyWith(id: 12, name: "My name")
  /// ````
  ForgotPasswordResponse call({
    Object? ok = const $CopyWithPlaceholder(),
    Object? message = const $CopyWithPlaceholder(),
    Object? devResetToken = const $CopyWithPlaceholder(),
  }) {
    return ForgotPasswordResponse(
      ok: ok == const $CopyWithPlaceholder()
          ? _value.ok
          // ignore: cast_nullable_to_non_nullable
          : ok as bool,
      message: message == const $CopyWithPlaceholder()
          ? _value.message
          // ignore: cast_nullable_to_non_nullable
          : message as String,
      devResetToken: devResetToken == const $CopyWithPlaceholder()
          ? _value.devResetToken
          // ignore: cast_nullable_to_non_nullable
          : devResetToken as String?,
    );
  }
}

extension $ForgotPasswordResponseCopyWith on ForgotPasswordResponse {
  /// Returns a callable class that can be used as follows: `instanceOfForgotPasswordResponse.copyWith(...)` or like so:`instanceOfForgotPasswordResponse.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ForgotPasswordResponseCWProxy get copyWith =>
      _$ForgotPasswordResponseCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ForgotPasswordResponse _$ForgotPasswordResponseFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('ForgotPasswordResponse', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['ok', 'message']);
  final val = ForgotPasswordResponse(
    ok: $checkedConvert('ok', (v) => v as bool),
    message: $checkedConvert('message', (v) => v as String),
    devResetToken: $checkedConvert('devResetToken', (v) => v as String?),
  );
  return val;
});

Map<String, dynamic> _$ForgotPasswordResponseToJson(
  ForgotPasswordResponse instance,
) => <String, dynamic>{
  'ok': instance.ok,
  'message': instance.message,
  'devResetToken': ?instance.devResetToken,
};
