// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'viet_qr_confirmation_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$VietQrConfirmationRequestCWProxy {
  VietQrConfirmationRequest bankTransactionRef(String? bankTransactionRef);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `VietQrConfirmationRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// VietQrConfirmationRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  VietQrConfirmationRequest call({String? bankTransactionRef});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfVietQrConfirmationRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfVietQrConfirmationRequest.copyWith.fieldName(...)`
class _$VietQrConfirmationRequestCWProxyImpl
    implements _$VietQrConfirmationRequestCWProxy {
  const _$VietQrConfirmationRequestCWProxyImpl(this._value);

  final VietQrConfirmationRequest _value;

  @override
  VietQrConfirmationRequest bankTransactionRef(String? bankTransactionRef) =>
      this(bankTransactionRef: bankTransactionRef);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `VietQrConfirmationRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// VietQrConfirmationRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  VietQrConfirmationRequest call({
    Object? bankTransactionRef = const $CopyWithPlaceholder(),
  }) {
    return VietQrConfirmationRequest(
      bankTransactionRef: bankTransactionRef == const $CopyWithPlaceholder()
          ? _value.bankTransactionRef
          // ignore: cast_nullable_to_non_nullable
          : bankTransactionRef as String?,
    );
  }
}

extension $VietQrConfirmationRequestCopyWith on VietQrConfirmationRequest {
  /// Returns a callable class that can be used as follows: `instanceOfVietQrConfirmationRequest.copyWith(...)` or like so:`instanceOfVietQrConfirmationRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$VietQrConfirmationRequestCWProxy get copyWith =>
      _$VietQrConfirmationRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VietQrConfirmationRequest _$VietQrConfirmationRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('VietQrConfirmationRequest', json, ($checkedConvert) {
  final val = VietQrConfirmationRequest(
    bankTransactionRef: $checkedConvert(
      'bankTransactionRef',
      (v) => v as String?,
    ),
  );
  return val;
});

Map<String, dynamic> _$VietQrConfirmationRequestToJson(
  VietQrConfirmationRequest instance,
) => <String, dynamic>{'bankTransactionRef': ?instance.bankTransactionRef};
