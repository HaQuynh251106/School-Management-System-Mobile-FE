//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'refund_invoice_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class RefundInvoiceRequest {
  /// Returns a new [RefundInvoiceRequest] instance.
  RefundInvoiceRequest({required this.amount, required this.reason});

  // minimum: 1
  @JsonKey(name: r'amount', required: true, includeIfNull: false)
  final int amount;

  @JsonKey(name: r'reason', required: true, includeIfNull: false)
  final String reason;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RefundInvoiceRequest &&
          other.amount == amount &&
          other.reason == reason;

  @override
  int get hashCode => amount.hashCode + reason.hashCode;

  factory RefundInvoiceRequest.fromJson(Map<String, dynamic> json) =>
      _$RefundInvoiceRequestFromJson(json);

  Map<String, dynamic> toJson() => _$RefundInvoiceRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
