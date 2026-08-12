// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PaymentCWProxy {
  Payment id(String id);

  Payment invoiceId(String invoiceId);

  Payment amount(int amount);

  Payment method(PaymentMethodEnum method);

  Payment status(PaymentStatusEnum status);

  Payment txnRef(String txnRef);

  Payment receiptCode(String? receiptCode);

  Payment payerName(String? payerName);

  Payment note(String? note);

  Payment recordedBy(String? recordedBy);

  Payment createdAt(DateTime createdAt);

  Payment paidAt(DateTime? paidAt);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Payment(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Payment(...).copyWith(id: 12, name: "My name")
  /// ````
  Payment call({
    String id,
    String invoiceId,
    int amount,
    PaymentMethodEnum method,
    PaymentStatusEnum status,
    String txnRef,
    String? receiptCode,
    String? payerName,
    String? note,
    String? recordedBy,
    DateTime createdAt,
    DateTime? paidAt,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPayment.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPayment.copyWith.fieldName(...)`
class _$PaymentCWProxyImpl implements _$PaymentCWProxy {
  const _$PaymentCWProxyImpl(this._value);

  final Payment _value;

  @override
  Payment id(String id) => this(id: id);

  @override
  Payment invoiceId(String invoiceId) => this(invoiceId: invoiceId);

  @override
  Payment amount(int amount) => this(amount: amount);

  @override
  Payment method(PaymentMethodEnum method) => this(method: method);

  @override
  Payment status(PaymentStatusEnum status) => this(status: status);

  @override
  Payment txnRef(String txnRef) => this(txnRef: txnRef);

  @override
  Payment receiptCode(String? receiptCode) => this(receiptCode: receiptCode);

  @override
  Payment payerName(String? payerName) => this(payerName: payerName);

  @override
  Payment note(String? note) => this(note: note);

  @override
  Payment recordedBy(String? recordedBy) => this(recordedBy: recordedBy);

  @override
  Payment createdAt(DateTime createdAt) => this(createdAt: createdAt);

  @override
  Payment paidAt(DateTime? paidAt) => this(paidAt: paidAt);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Payment(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Payment(...).copyWith(id: 12, name: "My name")
  /// ````
  Payment call({
    Object? id = const $CopyWithPlaceholder(),
    Object? invoiceId = const $CopyWithPlaceholder(),
    Object? amount = const $CopyWithPlaceholder(),
    Object? method = const $CopyWithPlaceholder(),
    Object? status = const $CopyWithPlaceholder(),
    Object? txnRef = const $CopyWithPlaceholder(),
    Object? receiptCode = const $CopyWithPlaceholder(),
    Object? payerName = const $CopyWithPlaceholder(),
    Object? note = const $CopyWithPlaceholder(),
    Object? recordedBy = const $CopyWithPlaceholder(),
    Object? createdAt = const $CopyWithPlaceholder(),
    Object? paidAt = const $CopyWithPlaceholder(),
  }) {
    return Payment(
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
          : method as PaymentMethodEnum,
      status: status == const $CopyWithPlaceholder()
          ? _value.status
          // ignore: cast_nullable_to_non_nullable
          : status as PaymentStatusEnum,
      txnRef: txnRef == const $CopyWithPlaceholder()
          ? _value.txnRef
          // ignore: cast_nullable_to_non_nullable
          : txnRef as String,
      receiptCode: receiptCode == const $CopyWithPlaceholder()
          ? _value.receiptCode
          // ignore: cast_nullable_to_non_nullable
          : receiptCode as String?,
      payerName: payerName == const $CopyWithPlaceholder()
          ? _value.payerName
          // ignore: cast_nullable_to_non_nullable
          : payerName as String?,
      note: note == const $CopyWithPlaceholder()
          ? _value.note
          // ignore: cast_nullable_to_non_nullable
          : note as String?,
      recordedBy: recordedBy == const $CopyWithPlaceholder()
          ? _value.recordedBy
          // ignore: cast_nullable_to_non_nullable
          : recordedBy as String?,
      createdAt: createdAt == const $CopyWithPlaceholder()
          ? _value.createdAt
          // ignore: cast_nullable_to_non_nullable
          : createdAt as DateTime,
      paidAt: paidAt == const $CopyWithPlaceholder()
          ? _value.paidAt
          // ignore: cast_nullable_to_non_nullable
          : paidAt as DateTime?,
    );
  }
}

extension $PaymentCopyWith on Payment {
  /// Returns a callable class that can be used as follows: `instanceOfPayment.copyWith(...)` or like so:`instanceOfPayment.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PaymentCWProxy get copyWith => _$PaymentCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Payment _$PaymentFromJson(Map<String, dynamic> json) =>
    $checkedCreate('Payment', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const [
          'id',
          'invoiceId',
          'amount',
          'method',
          'status',
          'txnRef',
          'createdAt',
        ],
      );
      final val = Payment(
        id: $checkedConvert('id', (v) => v as String),
        invoiceId: $checkedConvert('invoiceId', (v) => v as String),
        amount: $checkedConvert('amount', (v) => (v as num).toInt()),
        method: $checkedConvert(
          'method',
          (v) => $enumDecode(_$PaymentMethodEnumEnumMap, v),
        ),
        status: $checkedConvert(
          'status',
          (v) => $enumDecode(_$PaymentStatusEnumEnumMap, v),
        ),
        txnRef: $checkedConvert('txnRef', (v) => v as String),
        receiptCode: $checkedConvert('receiptCode', (v) => v as String?),
        payerName: $checkedConvert('payerName', (v) => v as String?),
        note: $checkedConvert('note', (v) => v as String?),
        recordedBy: $checkedConvert('recordedBy', (v) => v as String?),
        createdAt: $checkedConvert(
          'createdAt',
          (v) => DateTime.parse(v as String),
        ),
        paidAt: $checkedConvert(
          'paidAt',
          (v) => v == null ? null : DateTime.parse(v as String),
        ),
      );
      return val;
    });

Map<String, dynamic> _$PaymentToJson(Payment instance) => <String, dynamic>{
  'id': instance.id,
  'invoiceId': instance.invoiceId,
  'amount': instance.amount,
  'method': _$PaymentMethodEnumEnumMap[instance.method]!,
  'status': _$PaymentStatusEnumEnumMap[instance.status]!,
  'txnRef': instance.txnRef,
  'receiptCode': ?instance.receiptCode,
  'payerName': ?instance.payerName,
  'note': ?instance.note,
  'recordedBy': ?instance.recordedBy,
  'createdAt': instance.createdAt.toIso8601String(),
  'paidAt': ?instance.paidAt?.toIso8601String(),
};

const _$PaymentMethodEnumEnumMap = {
  PaymentMethodEnum.VIETQR: 'VIETQR',
  PaymentMethodEnum.CASH: 'CASH',
};

const _$PaymentStatusEnumEnumMap = {
  PaymentStatusEnum.PENDING: 'PENDING',
  PaymentStatusEnum.SUCCESS: 'SUCCESS',
  PaymentStatusEnum.FAILED: 'FAILED',
};
