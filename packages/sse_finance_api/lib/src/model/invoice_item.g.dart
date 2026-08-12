// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invoice_item.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$InvoiceItemCWProxy {
  InvoiceItem id(String id);

  InvoiceItem invoiceId(String invoiceId);

  InvoiceItem name(String name);

  InvoiceItem amount(int amount);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `InvoiceItem(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// InvoiceItem(...).copyWith(id: 12, name: "My name")
  /// ````
  InvoiceItem call({String id, String invoiceId, String name, int amount});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfInvoiceItem.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfInvoiceItem.copyWith.fieldName(...)`
class _$InvoiceItemCWProxyImpl implements _$InvoiceItemCWProxy {
  const _$InvoiceItemCWProxyImpl(this._value);

  final InvoiceItem _value;

  @override
  InvoiceItem id(String id) => this(id: id);

  @override
  InvoiceItem invoiceId(String invoiceId) => this(invoiceId: invoiceId);

  @override
  InvoiceItem name(String name) => this(name: name);

  @override
  InvoiceItem amount(int amount) => this(amount: amount);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `InvoiceItem(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// InvoiceItem(...).copyWith(id: 12, name: "My name")
  /// ````
  InvoiceItem call({
    Object? id = const $CopyWithPlaceholder(),
    Object? invoiceId = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
    Object? amount = const $CopyWithPlaceholder(),
  }) {
    return InvoiceItem(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
      invoiceId: invoiceId == const $CopyWithPlaceholder()
          ? _value.invoiceId
          // ignore: cast_nullable_to_non_nullable
          : invoiceId as String,
      name: name == const $CopyWithPlaceholder()
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String,
      amount: amount == const $CopyWithPlaceholder()
          ? _value.amount
          // ignore: cast_nullable_to_non_nullable
          : amount as int,
    );
  }
}

extension $InvoiceItemCopyWith on InvoiceItem {
  /// Returns a callable class that can be used as follows: `instanceOfInvoiceItem.copyWith(...)` or like so:`instanceOfInvoiceItem.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$InvoiceItemCWProxy get copyWith => _$InvoiceItemCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InvoiceItem _$InvoiceItemFromJson(Map<String, dynamic> json) => $checkedCreate(
  'InvoiceItem',
  json,
  ($checkedConvert) {
    $checkKeys(json, requiredKeys: const ['id', 'invoiceId', 'name', 'amount']);
    final val = InvoiceItem(
      id: $checkedConvert('id', (v) => v as String),
      invoiceId: $checkedConvert('invoiceId', (v) => v as String),
      name: $checkedConvert('name', (v) => v as String),
      amount: $checkedConvert('amount', (v) => (v as num).toInt()),
    );
    return val;
  },
);

Map<String, dynamic> _$InvoiceItemToJson(InvoiceItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'invoiceId': instance.invoiceId,
      'name': instance.name,
      'amount': instance.amount,
    };
