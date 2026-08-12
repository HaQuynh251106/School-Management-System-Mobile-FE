//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'revenue_report.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class RevenueReport {
  /// Returns a new [RevenueReport] instance.
  RevenueReport({
    required this.invoiceCount,

    required this.paidCount,

    required this.totalAmount,

    required this.paidAmount,

    required this.outstanding,
  });

  @JsonKey(name: r'invoiceCount', required: true, includeIfNull: false)
  final int invoiceCount;

  @JsonKey(name: r'paidCount', required: true, includeIfNull: false)
  final int paidCount;

  @JsonKey(name: r'totalAmount', required: true, includeIfNull: false)
  final int totalAmount;

  @JsonKey(name: r'paidAmount', required: true, includeIfNull: false)
  final int paidAmount;

  @JsonKey(name: r'outstanding', required: true, includeIfNull: false)
  final int outstanding;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RevenueReport &&
          other.invoiceCount == invoiceCount &&
          other.paidCount == paidCount &&
          other.totalAmount == totalAmount &&
          other.paidAmount == paidAmount &&
          other.outstanding == outstanding;

  @override
  int get hashCode =>
      invoiceCount.hashCode +
      paidCount.hashCode +
      totalAmount.hashCode +
      paidAmount.hashCode +
      outstanding.hashCode;

  factory RevenueReport.fromJson(Map<String, dynamic> json) =>
      _$RevenueReportFromJson(json);

  Map<String, dynamic> toJson() => _$RevenueReportToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
