// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_my_profile_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$UpdateMyProfileRequestCWProxy {
  UpdateMyProfileRequest email(String? email);

  UpdateMyProfileRequest phone(String? phone);

  UpdateMyProfileRequest avatarUrl(String? avatarUrl);

  UpdateMyProfileRequest address(String? address);

  UpdateMyProfileRequest guardianName(String? guardianName);

  UpdateMyProfileRequest guardianPhone(String? guardianPhone);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `UpdateMyProfileRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// UpdateMyProfileRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  UpdateMyProfileRequest call({
    String? email,
    String? phone,
    String? avatarUrl,
    String? address,
    String? guardianName,
    String? guardianPhone,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfUpdateMyProfileRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfUpdateMyProfileRequest.copyWith.fieldName(...)`
class _$UpdateMyProfileRequestCWProxyImpl
    implements _$UpdateMyProfileRequestCWProxy {
  const _$UpdateMyProfileRequestCWProxyImpl(this._value);

  final UpdateMyProfileRequest _value;

  @override
  UpdateMyProfileRequest email(String? email) => this(email: email);

  @override
  UpdateMyProfileRequest phone(String? phone) => this(phone: phone);

  @override
  UpdateMyProfileRequest avatarUrl(String? avatarUrl) =>
      this(avatarUrl: avatarUrl);

  @override
  UpdateMyProfileRequest address(String? address) => this(address: address);

  @override
  UpdateMyProfileRequest guardianName(String? guardianName) =>
      this(guardianName: guardianName);

  @override
  UpdateMyProfileRequest guardianPhone(String? guardianPhone) =>
      this(guardianPhone: guardianPhone);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `UpdateMyProfileRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// UpdateMyProfileRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  UpdateMyProfileRequest call({
    Object? email = const $CopyWithPlaceholder(),
    Object? phone = const $CopyWithPlaceholder(),
    Object? avatarUrl = const $CopyWithPlaceholder(),
    Object? address = const $CopyWithPlaceholder(),
    Object? guardianName = const $CopyWithPlaceholder(),
    Object? guardianPhone = const $CopyWithPlaceholder(),
  }) {
    return UpdateMyProfileRequest(
      email: email == const $CopyWithPlaceholder()
          ? _value.email
          // ignore: cast_nullable_to_non_nullable
          : email as String?,
      phone: phone == const $CopyWithPlaceholder()
          ? _value.phone
          // ignore: cast_nullable_to_non_nullable
          : phone as String?,
      avatarUrl: avatarUrl == const $CopyWithPlaceholder()
          ? _value.avatarUrl
          // ignore: cast_nullable_to_non_nullable
          : avatarUrl as String?,
      address: address == const $CopyWithPlaceholder()
          ? _value.address
          // ignore: cast_nullable_to_non_nullable
          : address as String?,
      guardianName: guardianName == const $CopyWithPlaceholder()
          ? _value.guardianName
          // ignore: cast_nullable_to_non_nullable
          : guardianName as String?,
      guardianPhone: guardianPhone == const $CopyWithPlaceholder()
          ? _value.guardianPhone
          // ignore: cast_nullable_to_non_nullable
          : guardianPhone as String?,
    );
  }
}

extension $UpdateMyProfileRequestCopyWith on UpdateMyProfileRequest {
  /// Returns a callable class that can be used as follows: `instanceOfUpdateMyProfileRequest.copyWith(...)` or like so:`instanceOfUpdateMyProfileRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$UpdateMyProfileRequestCWProxy get copyWith =>
      _$UpdateMyProfileRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateMyProfileRequest _$UpdateMyProfileRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('UpdateMyProfileRequest', json, ($checkedConvert) {
  final val = UpdateMyProfileRequest(
    email: $checkedConvert('email', (v) => v as String?),
    phone: $checkedConvert('phone', (v) => v as String?),
    avatarUrl: $checkedConvert('avatarUrl', (v) => v as String?),
    address: $checkedConvert('address', (v) => v as String?),
    guardianName: $checkedConvert('guardianName', (v) => v as String?),
    guardianPhone: $checkedConvert('guardianPhone', (v) => v as String?),
  );
  return val;
});

Map<String, dynamic> _$UpdateMyProfileRequestToJson(
  UpdateMyProfileRequest instance,
) => <String, dynamic>{
  'email': ?instance.email,
  'phone': ?instance.phone,
  'avatarUrl': ?instance.avatarUrl,
  'address': ?instance.address,
  'guardianName': ?instance.guardianName,
  'guardianPhone': ?instance.guardianPhone,
};
