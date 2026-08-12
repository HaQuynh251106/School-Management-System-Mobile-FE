// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_reset_password_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$AdminResetPasswordRequestCWProxy {
  AdminResetPasswordRequest newPassword(String? newPassword);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AdminResetPasswordRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AdminResetPasswordRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  AdminResetPasswordRequest call({String? newPassword});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfAdminResetPasswordRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfAdminResetPasswordRequest.copyWith.fieldName(...)`
class _$AdminResetPasswordRequestCWProxyImpl
    implements _$AdminResetPasswordRequestCWProxy {
  const _$AdminResetPasswordRequestCWProxyImpl(this._value);

  final AdminResetPasswordRequest _value;

  @override
  AdminResetPasswordRequest newPassword(String? newPassword) =>
      this(newPassword: newPassword);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `AdminResetPasswordRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// AdminResetPasswordRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  AdminResetPasswordRequest call({
    Object? newPassword = const $CopyWithPlaceholder(),
  }) {
    return AdminResetPasswordRequest(
      newPassword: newPassword == const $CopyWithPlaceholder()
          ? _value.newPassword
          // ignore: cast_nullable_to_non_nullable
          : newPassword as String?,
    );
  }
}

extension $AdminResetPasswordRequestCopyWith on AdminResetPasswordRequest {
  /// Returns a callable class that can be used as follows: `instanceOfAdminResetPasswordRequest.copyWith(...)` or like so:`instanceOfAdminResetPasswordRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$AdminResetPasswordRequestCWProxy get copyWith =>
      _$AdminResetPasswordRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdminResetPasswordRequest _$AdminResetPasswordRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('AdminResetPasswordRequest', json, ($checkedConvert) {
  final val = AdminResetPasswordRequest(
    newPassword: $checkedConvert('newPassword', (v) => v as String?),
  );
  return val;
});

Map<String, dynamic> _$AdminResetPasswordRequestToJson(
  AdminResetPasswordRequest instance,
) => <String, dynamic>{'newPassword': ?instance.newPassword};
