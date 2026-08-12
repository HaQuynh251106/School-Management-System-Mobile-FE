//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:sse_finance_api/src/model/invoice.dart';
import 'package:sse_finance_api/src/model/payment.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'viet_qr_callback_result.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class VietQrCallbackResult {
  /// Returns a new [VietQrCallbackResult] instance.
  VietQrCallbackResult({
    required this.payment,

    required this.invoice,

    required this.gatewayStatus,
  });

  @JsonKey(name: r'payment', required: true, includeIfNull: false)
  final Payment payment;

  @JsonKey(name: r'invoice', required: true, includeIfNull: false)
  final Invoice invoice;

  @JsonKey(name: r'gatewayStatus', required: true, includeIfNull: false)
  final String gatewayStatus;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VietQrCallbackResult &&
          other.payment == payment &&
          other.invoice == invoice &&
          other.gatewayStatus == gatewayStatus;

  @override
  int get hashCode =>
      payment.hashCode + invoice.hashCode + gatewayStatus.hashCode;

  factory VietQrCallbackResult.fromJson(Map<String, dynamic> json) =>
      _$VietQrCallbackResultFromJson(json);

  Map<String, dynamic> toJson() => _$VietQrCallbackResultToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
