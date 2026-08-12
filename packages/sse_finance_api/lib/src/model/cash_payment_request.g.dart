// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cash_payment_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$CashPaymentRequestCWProxy {
  CashPaymentRequest invoiceId(String invoiceId);

  CashPaymentRequest amount(int? amount);

  CashPaymentRequest payerName(String? payerName);

  CashPaymentRequest note(String? note);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CashPaymentRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CashPaymentRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  CashPaymentRequest call({
    String invoiceId,
    int? amount,
    String? payerName,
    String? note,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCashPaymentRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCashPaymentRequest.copyWith.fieldName(...)`
class _$CashPaymentRequestCWProxyImpl implements _$CashPaymentRequestCWProxy {
  const _$CashPaymentRequestCWProxyImpl(this._value);

  final CashPaymentRequest _value;

  @override
  CashPaymentRequest invoiceId(String invoiceId) => this(invoiceId: invoiceId);

  @override
  CashPaymentRequest amount(int? amount) => this(amount: amount);

  @override
  CashPaymentRequest payerName(String? payerName) => this(payerName: payerName);

  @override
  CashPaymentRequest note(String? note) => this(note: note);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `CashPaymentRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// CashPaymentRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  CashPaymentRequest call({
    Object? invoiceId = const $CopyWithPlaceholder(),
    Object? amount = const $CopyWithPlaceholder(),
    Object? payerName = const $CopyWithPlaceholder(),
    Object? note = const $CopyWithPlaceholder(),
  }) {
    return CashPaymentRequest(
      invoiceId: invoiceId == const $CopyWithPlaceholder()
          ? _value.invoiceId
          // ignore: cast_nullable_to_non_nullable
          : invoiceId as String,
      amount: amount == const $CopyWithPlaceholder()
          ? _value.amount
          // ignore: cast_nullable_to_non_nullable
          : amount as int?,
      payerName: payerName == const $CopyWithPlaceholder()
          ? _value.payerName
          // ignore: cast_nullable_to_non_nullable
          : payerName as String?,
      note: note == const $CopyWithPlaceholder()
          ? _value.note
          // ignore: cast_nullable_to_non_nullable
          : note as String?,
    );
  }
}

extension $CashPaymentRequestCopyWith on CashPaymentRequest {
  /// Returns a callable class that can be used as follows: `instanceOfCashPaymentRequest.copyWith(...)` or like so:`instanceOfCashPaymentRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CashPaymentRequestCWProxy get copyWith =>
      _$CashPaymentRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CashPaymentRequest _$CashPaymentRequestFromJson(Map<String, dynamic> json) =>
    $checkedCreate('CashPaymentRequest', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['invoiceId']);
      final val = CashPaymentRequest(
        invoiceId: $checkedConvert('invoiceId', (v) => v as String),
        amount: $checkedConvert('amount', (v) => (v as num?)?.toInt()),
        payerName: $checkedConvert('payerName', (v) => v as String?),
        note: $checkedConvert('note', (v) => v as String?),
      );
      return val;
    });

Map<String, dynamic> _$CashPaymentRequestToJson(CashPaymentRequest instance) =>
    <String, dynamic>{
      'invoiceId': instance.invoiceId,
      'amount': ?instance.amount,
      'payerName': ?instance.payerName,
      'note': ?instance.note,
    };
