// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'viet_qr_callback_result.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$VietQrCallbackResultCWProxy {
  VietQrCallbackResult payment(Payment payment);

  VietQrCallbackResult invoice(Invoice invoice);

  VietQrCallbackResult gatewayStatus(String gatewayStatus);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `VietQrCallbackResult(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// VietQrCallbackResult(...).copyWith(id: 12, name: "My name")
  /// ````
  VietQrCallbackResult call({
    Payment payment,
    Invoice invoice,
    String gatewayStatus,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfVietQrCallbackResult.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfVietQrCallbackResult.copyWith.fieldName(...)`
class _$VietQrCallbackResultCWProxyImpl
    implements _$VietQrCallbackResultCWProxy {
  const _$VietQrCallbackResultCWProxyImpl(this._value);

  final VietQrCallbackResult _value;

  @override
  VietQrCallbackResult payment(Payment payment) => this(payment: payment);

  @override
  VietQrCallbackResult invoice(Invoice invoice) => this(invoice: invoice);

  @override
  VietQrCallbackResult gatewayStatus(String gatewayStatus) =>
      this(gatewayStatus: gatewayStatus);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `VietQrCallbackResult(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// VietQrCallbackResult(...).copyWith(id: 12, name: "My name")
  /// ````
  VietQrCallbackResult call({
    Object? payment = const $CopyWithPlaceholder(),
    Object? invoice = const $CopyWithPlaceholder(),
    Object? gatewayStatus = const $CopyWithPlaceholder(),
  }) {
    return VietQrCallbackResult(
      payment: payment == const $CopyWithPlaceholder()
          ? _value.payment
          // ignore: cast_nullable_to_non_nullable
          : payment as Payment,
      invoice: invoice == const $CopyWithPlaceholder()
          ? _value.invoice
          // ignore: cast_nullable_to_non_nullable
          : invoice as Invoice,
      gatewayStatus: gatewayStatus == const $CopyWithPlaceholder()
          ? _value.gatewayStatus
          // ignore: cast_nullable_to_non_nullable
          : gatewayStatus as String,
    );
  }
}

extension $VietQrCallbackResultCopyWith on VietQrCallbackResult {
  /// Returns a callable class that can be used as follows: `instanceOfVietQrCallbackResult.copyWith(...)` or like so:`instanceOfVietQrCallbackResult.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$VietQrCallbackResultCWProxy get copyWith =>
      _$VietQrCallbackResultCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VietQrCallbackResult _$VietQrCallbackResultFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('VietQrCallbackResult', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['payment', 'invoice', 'gatewayStatus']);
  final val = VietQrCallbackResult(
    payment: $checkedConvert(
      'payment',
      (v) => Payment.fromJson(v as Map<String, dynamic>),
    ),
    invoice: $checkedConvert(
      'invoice',
      (v) => Invoice.fromJson(v as Map<String, dynamic>),
    ),
    gatewayStatus: $checkedConvert('gatewayStatus', (v) => v as String),
  );
  return val;
});

Map<String, dynamic> _$VietQrCallbackResultToJson(
  VietQrCallbackResult instance,
) => <String, dynamic>{
  'payment': instance.payment.toJson(),
  'invoice': instance.invoice.toJson(),
  'gatewayStatus': instance.gatewayStatus,
};
