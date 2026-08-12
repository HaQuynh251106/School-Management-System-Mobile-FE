//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:sse_finance_api/src/model/invoice.dart';
import 'package:sse_finance_api/src/model/payment.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'payment_mutation_result.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PaymentMutationResult {
  /// Returns a new [PaymentMutationResult] instance.
  PaymentMutationResult({required this.payment, required this.invoice});

  @JsonKey(name: r'payment', required: true, includeIfNull: false)
  final Payment payment;

  @JsonKey(name: r'invoice', required: true, includeIfNull: false)
  final Invoice invoice;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaymentMutationResult &&
          other.payment == payment &&
          other.invoice == invoice;

  @override
  int get hashCode => payment.hashCode + invoice.hashCode;

  factory PaymentMutationResult.fromJson(Map<String, dynamic> json) =>
      _$PaymentMutationResultFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentMutationResultToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
