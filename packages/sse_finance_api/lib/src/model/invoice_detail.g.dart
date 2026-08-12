// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invoice_detail.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$InvoiceDetailCWProxy {
  InvoiceDetail invoice(Invoice invoice);

  InvoiceDetail items(List<InvoiceItem> items);

  InvoiceDetail payments(List<Payment> payments);

  InvoiceDetail refunds(List<InvoiceRefund> refunds);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `InvoiceDetail(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// InvoiceDetail(...).copyWith(id: 12, name: "My name")
  /// ````
  InvoiceDetail call({
    Invoice invoice,
    List<InvoiceItem> items,
    List<Payment> payments,
    List<InvoiceRefund> refunds,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfInvoiceDetail.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfInvoiceDetail.copyWith.fieldName(...)`
class _$InvoiceDetailCWProxyImpl implements _$InvoiceDetailCWProxy {
  const _$InvoiceDetailCWProxyImpl(this._value);

  final InvoiceDetail _value;

  @override
  InvoiceDetail invoice(Invoice invoice) => this(invoice: invoice);

  @override
  InvoiceDetail items(List<InvoiceItem> items) => this(items: items);

  @override
  InvoiceDetail payments(List<Payment> payments) => this(payments: payments);

  @override
  InvoiceDetail refunds(List<InvoiceRefund> refunds) => this(refunds: refunds);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `InvoiceDetail(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// InvoiceDetail(...).copyWith(id: 12, name: "My name")
  /// ````
  InvoiceDetail call({
    Object? invoice = const $CopyWithPlaceholder(),
    Object? items = const $CopyWithPlaceholder(),
    Object? payments = const $CopyWithPlaceholder(),
    Object? refunds = const $CopyWithPlaceholder(),
  }) {
    return InvoiceDetail(
      invoice: invoice == const $CopyWithPlaceholder()
          ? _value.invoice
          // ignore: cast_nullable_to_non_nullable
          : invoice as Invoice,
      items: items == const $CopyWithPlaceholder()
          ? _value.items
          // ignore: cast_nullable_to_non_nullable
          : items as List<InvoiceItem>,
      payments: payments == const $CopyWithPlaceholder()
          ? _value.payments
          // ignore: cast_nullable_to_non_nullable
          : payments as List<Payment>,
      refunds: refunds == const $CopyWithPlaceholder()
          ? _value.refunds
          // ignore: cast_nullable_to_non_nullable
          : refunds as List<InvoiceRefund>,
    );
  }
}

extension $InvoiceDetailCopyWith on InvoiceDetail {
  /// Returns a callable class that can be used as follows: `instanceOfInvoiceDetail.copyWith(...)` or like so:`instanceOfInvoiceDetail.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$InvoiceDetailCWProxy get copyWith => _$InvoiceDetailCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InvoiceDetail _$InvoiceDetailFromJson(Map<String, dynamic> json) =>
    $checkedCreate('InvoiceDetail', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const ['invoice', 'items', 'payments', 'refunds'],
      );
      final val = InvoiceDetail(
        invoice: $checkedConvert(
          'invoice',
          (v) => Invoice.fromJson(v as Map<String, dynamic>),
        ),
        items: $checkedConvert(
          'items',
          (v) => (v as List<dynamic>)
              .map((e) => InvoiceItem.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
        payments: $checkedConvert(
          'payments',
          (v) => (v as List<dynamic>)
              .map((e) => Payment.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
        refunds: $checkedConvert(
          'refunds',
          (v) => (v as List<dynamic>)
              .map((e) => InvoiceRefund.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
      );
      return val;
    });

Map<String, dynamic> _$InvoiceDetailToJson(InvoiceDetail instance) =>
    <String, dynamic>{
      'invoice': instance.invoice.toJson(),
      'items': instance.items.map((e) => e.toJson()).toList(),
      'payments': instance.payments.map((e) => e.toJson()).toList(),
      'refunds': instance.refunds.map((e) => e.toJson()).toList(),
    };
