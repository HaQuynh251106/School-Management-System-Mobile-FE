// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'refund_mutation_result.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$RefundMutationResultCWProxy {
  RefundMutationResult refund(InvoiceRefund refund);

  RefundMutationResult invoice(Invoice invoice);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RefundMutationResult(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RefundMutationResult(...).copyWith(id: 12, name: "My name")
  /// ````
  RefundMutationResult call({InvoiceRefund refund, Invoice invoice});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfRefundMutationResult.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfRefundMutationResult.copyWith.fieldName(...)`
class _$RefundMutationResultCWProxyImpl
    implements _$RefundMutationResultCWProxy {
  const _$RefundMutationResultCWProxyImpl(this._value);

  final RefundMutationResult _value;

  @override
  RefundMutationResult refund(InvoiceRefund refund) => this(refund: refund);

  @override
  RefundMutationResult invoice(Invoice invoice) => this(invoice: invoice);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RefundMutationResult(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RefundMutationResult(...).copyWith(id: 12, name: "My name")
  /// ````
  RefundMutationResult call({
    Object? refund = const $CopyWithPlaceholder(),
    Object? invoice = const $CopyWithPlaceholder(),
  }) {
    return RefundMutationResult(
      refund: refund == const $CopyWithPlaceholder()
          ? _value.refund
          // ignore: cast_nullable_to_non_nullable
          : refund as InvoiceRefund,
      invoice: invoice == const $CopyWithPlaceholder()
          ? _value.invoice
          // ignore: cast_nullable_to_non_nullable
          : invoice as Invoice,
    );
  }
}

extension $RefundMutationResultCopyWith on RefundMutationResult {
  /// Returns a callable class that can be used as follows: `instanceOfRefundMutationResult.copyWith(...)` or like so:`instanceOfRefundMutationResult.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$RefundMutationResultCWProxy get copyWith =>
      _$RefundMutationResultCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RefundMutationResult _$RefundMutationResultFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('RefundMutationResult', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['refund', 'invoice']);
  final val = RefundMutationResult(
    refund: $checkedConvert(
      'refund',
      (v) => InvoiceRefund.fromJson(v as Map<String, dynamic>),
    ),
    invoice: $checkedConvert(
      'invoice',
      (v) => Invoice.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$RefundMutationResultToJson(
  RefundMutationResult instance,
) => <String, dynamic>{
  'refund': instance.refund.toJson(),
  'invoice': instance.invoice.toJson(),
};
