//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'finance_summary.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class FinanceSummary {
  /// Returns a new [FinanceSummary] instance.
  FinanceSummary({
    required this.invoiceCount,

    required this.paidInvoiceCount,

    required this.totalAmount,

    required this.paidAmount,

    required this.outstanding,
  });

  @JsonKey(name: r'invoiceCount', required: true, includeIfNull: false)
  final int invoiceCount;

  @JsonKey(name: r'paidInvoiceCount', required: true, includeIfNull: false)
  final int paidInvoiceCount;

  @JsonKey(name: r'totalAmount', required: true, includeIfNull: false)
  final int totalAmount;

  @JsonKey(name: r'paidAmount', required: true, includeIfNull: false)
  final int paidAmount;

  @JsonKey(name: r'outstanding', required: true, includeIfNull: false)
  final int outstanding;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FinanceSummary &&
          other.invoiceCount == invoiceCount &&
          other.paidInvoiceCount == paidInvoiceCount &&
          other.totalAmount == totalAmount &&
          other.paidAmount == paidAmount &&
          other.outstanding == outstanding;

  @override
  int get hashCode =>
      invoiceCount.hashCode +
      paidInvoiceCount.hashCode +
      totalAmount.hashCode +
      paidAmount.hashCode +
      outstanding.hashCode;

  factory FinanceSummary.fromJson(Map<String, dynamic> json) =>
      _$FinanceSummaryFromJson(json);

  Map<String, dynamic> toJson() => _$FinanceSummaryToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
