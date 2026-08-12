// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invoice_refund.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$InvoiceRefundCWProxy {
  InvoiceRefund id(String id);

  InvoiceRefund invoiceId(String invoiceId);

  InvoiceRefund amount(int amount);

  InvoiceRefund method(String method);

  InvoiceRefund reason(String reason);

  InvoiceRefund status(InvoiceRefundStatusEnum status);

  InvoiceRefund createdBy(String createdBy);

  InvoiceRefund createdAt(DateTime createdAt);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `InvoiceRefund(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// InvoiceRefund(...).copyWith(id: 12, name: "My name")
  /// ````
  InvoiceRefund call({
    String id,
    String invoiceId,
    int amount,
    String method,
    String reason,
    InvoiceRefundStatusEnum status,
    String createdBy,
    DateTime createdAt,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfInvoiceRefund.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfInvoiceRefund.copyWith.fieldName(...)`
class _$InvoiceRefundCWProxyImpl implements _$InvoiceRefundCWProxy {
  const _$InvoiceRefundCWProxyImpl(this._value);

  final InvoiceRefund _value;

  @override
  InvoiceRefund id(String id) => this(id: id);

  @override
  InvoiceRefund invoiceId(String invoiceId) => this(invoiceId: invoiceId);

  @override
  InvoiceRefund amount(int amount) => this(amount: amount);

  @override
  InvoiceRefund method(String method) => this(method: method);

  @override
  InvoiceRefund reason(String reason) => this(reason: reason);

  @override
  InvoiceRefund status(InvoiceRefundStatusEnum status) => this(status: status);

  @override
  InvoiceRefund createdBy(String createdBy) => this(createdBy: createdBy);

  @override
  InvoiceRefund createdAt(DateTime createdAt) => this(createdAt: createdAt);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `InvoiceRefund(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// InvoiceRefund(...).copyWith(id: 12, name: "My name")
  /// ````
  InvoiceRefund call({
    Object? id = const $CopyWithPlaceholder(),
    Object? invoiceId = const $CopyWithPlaceholder(),
    Object? amount = const $CopyWithPlaceholder(),
    Object? method = const $CopyWithPlaceholder(),
    Object? reason = const $CopyWithPlaceholder(),
    Object? status = const $CopyWithPlaceholder(),
    Object? createdBy = const $CopyWithPlaceholder(),
    Object? createdAt = const $CopyWithPlaceholder(),
  }) {
    return InvoiceRefund(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String,
      invoiceId: invoiceId == const $CopyWithPlaceholder()
          ? _value.invoiceId
          // ignore: cast_nullable_to_non_nullable
          : invoiceId as String,
      amount: amount == const $CopyWithPlaceholder()
          ? _value.amount
          // ignore: cast_nullable_to_non_nullable
          : amount as int,
      method: method == const $CopyWithPlaceholder()
          ? _value.method
          // ignore: cast_nullable_to_non_nullable
          : method as String,
      reason: reason == const $CopyWithPlaceholder()
          ? _value.reason
          // ignore: cast_nullable_to_non_nullable
          : reason as String,
      status: status == const $CopyWithPlaceholder()
          ? _value.status
          // ignore: cast_nullable_to_non_nullable
          : status as InvoiceRefundStatusEnum,
      createdBy: createdBy == const $CopyWithPlaceholder()
          ? _value.createdBy
          // ignore: cast_nullable_to_non_nullable
          : createdBy as String,
      createdAt: createdAt == const $CopyWithPlaceholder()
          ? _value.createdAt
          // ignore: cast_nullable_to_non_nullable
          : createdAt as DateTime,
    );
  }
}

extension $InvoiceRefundCopyWith on InvoiceRefund {
  /// Returns a callable class that can be used as follows: `instanceOfInvoiceRefund.copyWith(...)` or like so:`instanceOfInvoiceRefund.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$InvoiceRefundCWProxy get copyWith => _$InvoiceRefundCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InvoiceRefund _$InvoiceRefundFromJson(Map<String, dynamic> json) =>
    $checkedCreate('InvoiceRefund', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const [
          'id',
          'invoiceId',
          'amount',
          'method',
          'reason',
          'status',
          'createdBy',
          'createdAt',
        ],
      );
      final val = InvoiceRefund(
        id: $checkedConvert('id', (v) => v as String),
        invoiceId: $checkedConvert('invoiceId', (v) => v as String),
        amount: $checkedConvert('amount', (v) => (v as num).toInt()),
        method: $checkedConvert('method', (v) => v as String),
        reason: $checkedConvert('reason', (v) => v as String),
        status: $checkedConvert(
          'status',
          (v) => $enumDecode(_$InvoiceRefundStatusEnumEnumMap, v),
        ),
        createdBy: $checkedConvert('createdBy', (v) => v as String),
        createdAt: $checkedConvert(
          'createdAt',
          (v) => DateTime.parse(v as String),
        ),
      );
      return val;
    });

Map<String, dynamic> _$InvoiceRefundToJson(InvoiceRefund instance) =>
    <String, dynamic>{
      'id': instance.id,
      'invoiceId': instance.invoiceId,
      'amount': instance.amount,
      'method': instance.method,
      'reason': instance.reason,
      'status': _$InvoiceRefundStatusEnumEnumMap[instance.status]!,
      'createdBy': instance.createdBy,
      'createdAt': instance.createdAt.toIso8601String(),
    };

const _$InvoiceRefundStatusEnumEnumMap = {
  InvoiceRefundStatusEnum.SUCCESS: 'SUCCESS',
};
