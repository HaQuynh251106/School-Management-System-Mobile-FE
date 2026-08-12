// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_mutation_result.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PaymentMutationResultCWProxy {
  PaymentMutationResult payment(Payment payment);

  PaymentMutationResult invoice(Invoice invoice);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PaymentMutationResult(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PaymentMutationResult(...).copyWith(id: 12, name: "My name")
  /// ````
  PaymentMutationResult call({Payment payment, Invoice invoice});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPaymentMutationResult.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPaymentMutationResult.copyWith.fieldName(...)`
class _$PaymentMutationResultCWProxyImpl
    implements _$PaymentMutationResultCWProxy {
  const _$PaymentMutationResultCWProxyImpl(this._value);

  final PaymentMutationResult _value;

  @override
  PaymentMutationResult payment(Payment payment) => this(payment: payment);

  @override
  PaymentMutationResult invoice(Invoice invoice) => this(invoice: invoice);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PaymentMutationResult(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PaymentMutationResult(...).copyWith(id: 12, name: "My name")
  /// ````
  PaymentMutationResult call({
    Object? payment = const $CopyWithPlaceholder(),
    Object? invoice = const $CopyWithPlaceholder(),
  }) {
    return PaymentMutationResult(
      payment: payment == const $CopyWithPlaceholder()
          ? _value.payment
          // ignore: cast_nullable_to_non_nullable
          : payment as Payment,
      invoice: invoice == const $CopyWithPlaceholder()
          ? _value.invoice
          // ignore: cast_nullable_to_non_nullable
          : invoice as Invoice,
    );
  }
}

extension $PaymentMutationResultCopyWith on PaymentMutationResult {
  /// Returns a callable class that can be used as follows: `instanceOfPaymentMutationResult.copyWith(...)` or like so:`instanceOfPaymentMutationResult.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PaymentMutationResultCWProxy get copyWith =>
      _$PaymentMutationResultCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaymentMutationResult _$PaymentMutationResultFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('PaymentMutationResult', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['payment', 'invoice']);
  final val = PaymentMutationResult(
    payment: $checkedConvert(
      'payment',
      (v) => Payment.fromJson(v as Map<String, dynamic>),
    ),
    invoice: $checkedConvert(
      'invoice',
      (v) => Invoice.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$PaymentMutationResultToJson(
  PaymentMutationResult instance,
) => <String, dynamic>{
  'payment': instance.payment.toJson(),
  'invoice': instance.invoice.toJson(),
};
