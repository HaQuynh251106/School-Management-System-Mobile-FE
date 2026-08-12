// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'refund_invoice_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$RefundInvoiceRequestCWProxy {
  RefundInvoiceRequest amount(int amount);

  RefundInvoiceRequest reason(String reason);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RefundInvoiceRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RefundInvoiceRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  RefundInvoiceRequest call({int amount, String reason});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfRefundInvoiceRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfRefundInvoiceRequest.copyWith.fieldName(...)`
class _$RefundInvoiceRequestCWProxyImpl
    implements _$RefundInvoiceRequestCWProxy {
  const _$RefundInvoiceRequestCWProxyImpl(this._value);

  final RefundInvoiceRequest _value;

  @override
  RefundInvoiceRequest amount(int amount) => this(amount: amount);

  @override
  RefundInvoiceRequest reason(String reason) => this(reason: reason);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RefundInvoiceRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RefundInvoiceRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  RefundInvoiceRequest call({
    Object? amount = const $CopyWithPlaceholder(),
    Object? reason = const $CopyWithPlaceholder(),
  }) {
    return RefundInvoiceRequest(
      amount: amount == const $CopyWithPlaceholder()
          ? _value.amount
          // ignore: cast_nullable_to_non_nullable
          : amount as int,
      reason: reason == const $CopyWithPlaceholder()
          ? _value.reason
          // ignore: cast_nullable_to_non_nullable
          : reason as String,
    );
  }
}

extension $RefundInvoiceRequestCopyWith on RefundInvoiceRequest {
  /// Returns a callable class that can be used as follows: `instanceOfRefundInvoiceRequest.copyWith(...)` or like so:`instanceOfRefundInvoiceRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$RefundInvoiceRequestCWProxy get copyWith =>
      _$RefundInvoiceRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RefundInvoiceRequest _$RefundInvoiceRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('RefundInvoiceRequest', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['amount', 'reason']);
  final val = RefundInvoiceRequest(
    amount: $checkedConvert('amount', (v) => (v as num).toInt()),
    reason: $checkedConvert('reason', (v) => v as String),
  );
  return val;
});

Map<String, dynamic> _$RefundInvoiceRequestToJson(
  RefundInvoiceRequest instance,
) => <String, dynamic>{'amount': instance.amount, 'reason': instance.reason};
