//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:sse_finance_api/src/model/invoice.dart';
import 'package:sse_finance_api/src/model/invoice_refund.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'refund_mutation_result.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class RefundMutationResult {
  /// Returns a new [RefundMutationResult] instance.
  RefundMutationResult({required this.refund, required this.invoice});

  @JsonKey(name: r'refund', required: true, includeIfNull: false)
  final InvoiceRefund refund;

  @JsonKey(name: r'invoice', required: true, includeIfNull: false)
  final Invoice invoice;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RefundMutationResult &&
          other.refund == refund &&
          other.invoice == invoice;

  @override
  int get hashCode => refund.hashCode + invoice.hashCode;

  factory RefundMutationResult.fromJson(Map<String, dynamic> json) =>
      _$RefundMutationResultFromJson(json);

  Map<String, dynamic> toJson() => _$RefundMutationResultToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
