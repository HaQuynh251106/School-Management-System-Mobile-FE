//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'cash_payment_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CashPaymentRequest {
  /// Returns a new [CashPaymentRequest] instance.
  CashPaymentRequest({
    required this.invoiceId,

    this.amount,

    this.payerName,

    this.note,
  });

  @JsonKey(name: r'invoiceId', required: true, includeIfNull: false)
  final String invoiceId;

  /// Null collects the full remaining balance.
  // minimum: 1
  @JsonKey(name: r'amount', required: false, includeIfNull: false)
  final int? amount;

  @JsonKey(name: r'payerName', required: false, includeIfNull: false)
  final String? payerName;

  @JsonKey(name: r'note', required: false, includeIfNull: false)
  final String? note;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CashPaymentRequest &&
          other.invoiceId == invoiceId &&
          other.amount == amount &&
          other.payerName == payerName &&
          other.note == note;

  @override
  int get hashCode =>
      invoiceId.hashCode +
      (amount == null ? 0 : amount.hashCode) +
      (payerName == null ? 0 : payerName.hashCode) +
      (note == null ? 0 : note.hashCode);

  factory CashPaymentRequest.fromJson(Map<String, dynamic> json) =>
      _$CashPaymentRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CashPaymentRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
