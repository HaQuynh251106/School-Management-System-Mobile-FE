// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'viet_qr_payment_result.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$VietQrPaymentResultCWProxy {
  VietQrPaymentResult payment(Payment payment);

  VietQrPaymentResult invoice(Invoice invoice);

  VietQrPaymentResult gateway(VietQrPaymentResultGatewayEnum gateway);

  VietQrPaymentResult gatewayStatus(String gatewayStatus);

  VietQrPaymentResult qrImageUrl(String qrImageUrl);

  VietQrPaymentResult bankId(String bankId);

  VietQrPaymentResult accountNo(String accountNo);

  VietQrPaymentResult accountName(String accountName);

  VietQrPaymentResult transferContent(String transferContent);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `VietQrPaymentResult(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// VietQrPaymentResult(...).copyWith(id: 12, name: "My name")
  /// ````
  VietQrPaymentResult call({
    Payment payment,
    Invoice invoice,
    VietQrPaymentResultGatewayEnum gateway,
    String gatewayStatus,
    String qrImageUrl,
    String bankId,
    String accountNo,
    String accountName,
    String transferContent,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfVietQrPaymentResult.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfVietQrPaymentResult.copyWith.fieldName(...)`
class _$VietQrPaymentResultCWProxyImpl implements _$VietQrPaymentResultCWProxy {
  const _$VietQrPaymentResultCWProxyImpl(this._value);

  final VietQrPaymentResult _value;

  @override
  VietQrPaymentResult payment(Payment payment) => this(payment: payment);

  @override
  VietQrPaymentResult invoice(Invoice invoice) => this(invoice: invoice);

  @override
  VietQrPaymentResult gateway(VietQrPaymentResultGatewayEnum gateway) =>
      this(gateway: gateway);

  @override
  VietQrPaymentResult gatewayStatus(String gatewayStatus) =>
      this(gatewayStatus: gatewayStatus);

  @override
  VietQrPaymentResult qrImageUrl(String qrImageUrl) =>
      this(qrImageUrl: qrImageUrl);

  @override
  VietQrPaymentResult bankId(String bankId) => this(bankId: bankId);

  @override
  VietQrPaymentResult accountNo(String accountNo) => this(accountNo: accountNo);

  @override
  VietQrPaymentResult accountName(String accountName) =>
      this(accountName: accountName);

  @override
  VietQrPaymentResult transferContent(String transferContent) =>
      this(transferContent: transferContent);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `VietQrPaymentResult(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// VietQrPaymentResult(...).copyWith(id: 12, name: "My name")
  /// ````
  VietQrPaymentResult call({
    Object? payment = const $CopyWithPlaceholder(),
    Object? invoice = const $CopyWithPlaceholder(),
    Object? gateway = const $CopyWithPlaceholder(),
    Object? gatewayStatus = const $CopyWithPlaceholder(),
    Object? qrImageUrl = const $CopyWithPlaceholder(),
    Object? bankId = const $CopyWithPlaceholder(),
    Object? accountNo = const $CopyWithPlaceholder(),
    Object? accountName = const $CopyWithPlaceholder(),
    Object? transferContent = const $CopyWithPlaceholder(),
  }) {
    return VietQrPaymentResult(
      payment: payment == const $CopyWithPlaceholder()
          ? _value.payment
          // ignore: cast_nullable_to_non_nullable
          : payment as Payment,
      invoice: invoice == const $CopyWithPlaceholder()
          ? _value.invoice
          // ignore: cast_nullable_to_non_nullable
          : invoice as Invoice,
      gateway: gateway == const $CopyWithPlaceholder()
          ? _value.gateway
          // ignore: cast_nullable_to_non_nullable
          : gateway as VietQrPaymentResultGatewayEnum,
      gatewayStatus: gatewayStatus == const $CopyWithPlaceholder()
          ? _value.gatewayStatus
          // ignore: cast_nullable_to_non_nullable
          : gatewayStatus as String,
      qrImageUrl: qrImageUrl == const $CopyWithPlaceholder()
          ? _value.qrImageUrl
          // ignore: cast_nullable_to_non_nullable
          : qrImageUrl as String,
      bankId: bankId == const $CopyWithPlaceholder()
          ? _value.bankId
          // ignore: cast_nullable_to_non_nullable
          : bankId as String,
      accountNo: accountNo == const $CopyWithPlaceholder()
          ? _value.accountNo
          // ignore: cast_nullable_to_non_nullable
          : accountNo as String,
      accountName: accountName == const $CopyWithPlaceholder()
          ? _value.accountName
          // ignore: cast_nullable_to_non_nullable
          : accountName as String,
      transferContent: transferContent == const $CopyWithPlaceholder()
          ? _value.transferContent
          // ignore: cast_nullable_to_non_nullable
          : transferContent as String,
    );
  }
}

extension $VietQrPaymentResultCopyWith on VietQrPaymentResult {
  /// Returns a callable class that can be used as follows: `instanceOfVietQrPaymentResult.copyWith(...)` or like so:`instanceOfVietQrPaymentResult.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$VietQrPaymentResultCWProxy get copyWith =>
      _$VietQrPaymentResultCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VietQrPaymentResult _$VietQrPaymentResultFromJson(Map<String, dynamic> json) =>
    $checkedCreate('VietQrPaymentResult', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const [
          'payment',
          'invoice',
          'gateway',
          'gatewayStatus',
          'qrImageUrl',
          'bankId',
          'accountNo',
          'accountName',
          'transferContent',
        ],
      );
      final val = VietQrPaymentResult(
        payment: $checkedConvert(
          'payment',
          (v) => Payment.fromJson(v as Map<String, dynamic>),
        ),
        invoice: $checkedConvert(
          'invoice',
          (v) => Invoice.fromJson(v as Map<String, dynamic>),
        ),
        gateway: $checkedConvert(
          'gateway',
          (v) => $enumDecode(_$VietQrPaymentResultGatewayEnumEnumMap, v),
        ),
        gatewayStatus: $checkedConvert('gatewayStatus', (v) => v as String),
        qrImageUrl: $checkedConvert('qrImageUrl', (v) => v as String),
        bankId: $checkedConvert('bankId', (v) => v as String),
        accountNo: $checkedConvert('accountNo', (v) => v as String),
        accountName: $checkedConvert('accountName', (v) => v as String),
        transferContent: $checkedConvert('transferContent', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$VietQrPaymentResultToJson(
  VietQrPaymentResult instance,
) => <String, dynamic>{
  'payment': instance.payment.toJson(),
  'invoice': instance.invoice.toJson(),
  'gateway': _$VietQrPaymentResultGatewayEnumEnumMap[instance.gateway]!,
  'gatewayStatus': instance.gatewayStatus,
  'qrImageUrl': instance.qrImageUrl,
  'bankId': instance.bankId,
  'accountNo': instance.accountNo,
  'accountName': instance.accountName,
  'transferContent': instance.transferContent,
};

const _$VietQrPaymentResultGatewayEnumEnumMap = {
  VietQrPaymentResultGatewayEnum.VIETQR: 'VIETQR',
};
