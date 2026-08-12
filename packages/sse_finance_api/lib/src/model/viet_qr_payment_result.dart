//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:sse_finance_api/src/model/invoice.dart';
import 'package:sse_finance_api/src/model/payment.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'viet_qr_payment_result.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class VietQrPaymentResult {
  /// Returns a new [VietQrPaymentResult] instance.
  VietQrPaymentResult({
    required this.payment,

    required this.invoice,

    required this.gateway,

    required this.gatewayStatus,

    required this.qrImageUrl,

    required this.bankId,

    required this.accountNo,

    required this.accountName,

    required this.transferContent,
  });

  @JsonKey(name: r'payment', required: true, includeIfNull: false)
  final Payment payment;

  @JsonKey(name: r'invoice', required: true, includeIfNull: false)
  final Invoice invoice;

  @JsonKey(name: r'gateway', required: true, includeIfNull: false)
  final VietQrPaymentResultGatewayEnum gateway;

  @JsonKey(name: r'gatewayStatus', required: true, includeIfNull: false)
  final String gatewayStatus;

  @JsonKey(name: r'qrImageUrl', required: true, includeIfNull: false)
  final String qrImageUrl;

  @JsonKey(name: r'bankId', required: true, includeIfNull: false)
  final String bankId;

  @JsonKey(name: r'accountNo', required: true, includeIfNull: false)
  final String accountNo;

  @JsonKey(name: r'accountName', required: true, includeIfNull: false)
  final String accountName;

  @JsonKey(name: r'transferContent', required: true, includeIfNull: false)
  final String transferContent;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VietQrPaymentResult &&
          other.payment == payment &&
          other.invoice == invoice &&
          other.gateway == gateway &&
          other.gatewayStatus == gatewayStatus &&
          other.qrImageUrl == qrImageUrl &&
          other.bankId == bankId &&
          other.accountNo == accountNo &&
          other.accountName == accountName &&
          other.transferContent == transferContent;

  @override
  int get hashCode =>
      payment.hashCode +
      invoice.hashCode +
      gateway.hashCode +
      gatewayStatus.hashCode +
      qrImageUrl.hashCode +
      bankId.hashCode +
      accountNo.hashCode +
      accountName.hashCode +
      transferContent.hashCode;

  factory VietQrPaymentResult.fromJson(Map<String, dynamic> json) =>
      _$VietQrPaymentResultFromJson(json);

  Map<String, dynamic> toJson() => _$VietQrPaymentResultToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum VietQrPaymentResultGatewayEnum {
  @JsonValue(r'VIETQR')
  VIETQR(r'VIETQR');

  const VietQrPaymentResultGatewayEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
