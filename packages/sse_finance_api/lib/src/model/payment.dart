//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'payment.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class Payment {
  /// Returns a new [Payment] instance.
  Payment({
    required this.id,

    required this.invoiceId,

    required this.amount,

    required this.method,

    required this.status,

    required this.txnRef,

    this.receiptCode,

    this.payerName,

    this.note,

    this.recordedBy,

    required this.createdAt,

    this.paidAt,
  });

  @JsonKey(name: r'id', required: true, includeIfNull: false)
  final String id;

  @JsonKey(name: r'invoiceId', required: true, includeIfNull: false)
  final String invoiceId;

  // minimum: 1
  @JsonKey(name: r'amount', required: true, includeIfNull: false)
  final int amount;

  @JsonKey(name: r'method', required: true, includeIfNull: false)
  final PaymentMethodEnum method;

  @JsonKey(name: r'status', required: true, includeIfNull: false)
  final PaymentStatusEnum status;

  @JsonKey(name: r'txnRef', required: true, includeIfNull: false)
  final String txnRef;

  @JsonKey(name: r'receiptCode', required: false, includeIfNull: false)
  final String? receiptCode;

  @JsonKey(name: r'payerName', required: false, includeIfNull: false)
  final String? payerName;

  @JsonKey(name: r'note', required: false, includeIfNull: false)
  final String? note;

  @JsonKey(name: r'recordedBy', required: false, includeIfNull: false)
  final String? recordedBy;

  @JsonKey(name: r'createdAt', required: true, includeIfNull: false)
  final DateTime createdAt;

  @JsonKey(name: r'paidAt', required: false, includeIfNull: false)
  final DateTime? paidAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Payment &&
          other.id == id &&
          other.invoiceId == invoiceId &&
          other.amount == amount &&
          other.method == method &&
          other.status == status &&
          other.txnRef == txnRef &&
          other.receiptCode == receiptCode &&
          other.payerName == payerName &&
          other.note == note &&
          other.recordedBy == recordedBy &&
          other.createdAt == createdAt &&
          other.paidAt == paidAt;

  @override
  int get hashCode =>
      id.hashCode +
      invoiceId.hashCode +
      amount.hashCode +
      method.hashCode +
      status.hashCode +
      txnRef.hashCode +
      (receiptCode == null ? 0 : receiptCode.hashCode) +
      (payerName == null ? 0 : payerName.hashCode) +
      (note == null ? 0 : note.hashCode) +
      (recordedBy == null ? 0 : recordedBy.hashCode) +
      createdAt.hashCode +
      (paidAt == null ? 0 : paidAt.hashCode);

  factory Payment.fromJson(Map<String, dynamic> json) =>
      _$PaymentFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum PaymentMethodEnum {
  @JsonValue(r'VIETQR')
  VIETQR(r'VIETQR'),
  @JsonValue(r'CASH')
  CASH(r'CASH');

  const PaymentMethodEnum(this.value);

  final String value;

  @override
  String toString() => value;
}

enum PaymentStatusEnum {
  @JsonValue(r'PENDING')
  PENDING(r'PENDING'),
  @JsonValue(r'SUCCESS')
  SUCCESS(r'SUCCESS'),
  @JsonValue(r'FAILED')
  FAILED(r'FAILED');

  const PaymentStatusEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
