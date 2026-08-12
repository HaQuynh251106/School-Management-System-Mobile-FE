//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:sse_finance_api/src/model/invoice_item.dart';
import 'package:sse_finance_api/src/model/invoice.dart';
import 'package:sse_finance_api/src/model/payment.dart';
import 'package:sse_finance_api/src/model/invoice_refund.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'invoice_detail.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class InvoiceDetail {
  /// Returns a new [InvoiceDetail] instance.
  InvoiceDetail({
    required this.invoice,

    required this.items,

    required this.payments,

    required this.refunds,
  });

  @JsonKey(name: r'invoice', required: true, includeIfNull: false)
  final Invoice invoice;

  @JsonKey(name: r'items', required: true, includeIfNull: false)
  final List<InvoiceItem> items;

  @JsonKey(name: r'payments', required: true, includeIfNull: false)
  final List<Payment> payments;

  @JsonKey(name: r'refunds', required: true, includeIfNull: false)
  final List<InvoiceRefund> refunds;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InvoiceDetail &&
          other.invoice == invoice &&
          other.items == items &&
          other.payments == payments &&
          other.refunds == refunds;

  @override
  int get hashCode =>
      invoice.hashCode + items.hashCode + payments.hashCode + refunds.hashCode;

  factory InvoiceDetail.fromJson(Map<String, dynamic> json) =>
      _$InvoiceDetailFromJson(json);

  Map<String, dynamic> toJson() => _$InvoiceDetailToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
