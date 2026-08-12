//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'invoice_refund.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class InvoiceRefund {
  /// Returns a new [InvoiceRefund] instance.
  InvoiceRefund({
    required this.id,

    required this.invoiceId,

    required this.amount,

    required this.method,

    required this.reason,

    required this.status,

    required this.createdBy,

    required this.createdAt,
  });

  @JsonKey(name: r'id', required: true, includeIfNull: false)
  final String id;

  @JsonKey(name: r'invoiceId', required: true, includeIfNull: false)
  final String invoiceId;

  // minimum: 1
  @JsonKey(name: r'amount', required: true, includeIfNull: false)
  final int amount;

  @JsonKey(name: r'method', required: true, includeIfNull: false)
  final String method;

  @JsonKey(name: r'reason', required: true, includeIfNull: false)
  final String reason;

  @JsonKey(name: r'status', required: true, includeIfNull: false)
  final InvoiceRefundStatusEnum status;

  @JsonKey(name: r'createdBy', required: true, includeIfNull: false)
  final String createdBy;

  @JsonKey(name: r'createdAt', required: true, includeIfNull: false)
  final DateTime createdAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InvoiceRefund &&
          other.id == id &&
          other.invoiceId == invoiceId &&
          other.amount == amount &&
          other.method == method &&
          other.reason == reason &&
          other.status == status &&
          other.createdBy == createdBy &&
          other.createdAt == createdAt;

  @override
  int get hashCode =>
      id.hashCode +
      invoiceId.hashCode +
      amount.hashCode +
      method.hashCode +
      reason.hashCode +
      status.hashCode +
      createdBy.hashCode +
      createdAt.hashCode;

  factory InvoiceRefund.fromJson(Map<String, dynamic> json) =>
      _$InvoiceRefundFromJson(json);

  Map<String, dynamic> toJson() => _$InvoiceRefundToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum InvoiceRefundStatusEnum {
  @JsonValue(r'SUCCESS')
  SUCCESS(r'SUCCESS');

  const InvoiceRefundStatusEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
