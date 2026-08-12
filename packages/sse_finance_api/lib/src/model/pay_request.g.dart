// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pay_request.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$PayRequestCWProxy {
  PayRequest invoiceId(String invoiceId);

  PayRequest method(PayRequestMethodEnum? method);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PayRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PayRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  PayRequest call({String invoiceId, PayRequestMethodEnum? method});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfPayRequest.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfPayRequest.copyWith.fieldName(...)`
class _$PayRequestCWProxyImpl implements _$PayRequestCWProxy {
  const _$PayRequestCWProxyImpl(this._value);

  final PayRequest _value;

  @override
  PayRequest invoiceId(String invoiceId) => this(invoiceId: invoiceId);

  @override
  PayRequest method(PayRequestMethodEnum? method) => this(method: method);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `PayRequest(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// PayRequest(...).copyWith(id: 12, name: "My name")
  /// ````
  PayRequest call({
    Object? invoiceId = const $CopyWithPlaceholder(),
    Object? method = const $CopyWithPlaceholder(),
  }) {
    return PayRequest(
      invoiceId: invoiceId == const $CopyWithPlaceholder()
          ? _value.invoiceId
          // ignore: cast_nullable_to_non_nullable
          : invoiceId as String,
      method: method == const $CopyWithPlaceholder()
          ? _value.method
          // ignore: cast_nullable_to_non_nullable
          : method as PayRequestMethodEnum?,
    );
  }
}

extension $PayRequestCopyWith on PayRequest {
  /// Returns a callable class that can be used as follows: `instanceOfPayRequest.copyWith(...)` or like so:`instanceOfPayRequest.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$PayRequestCWProxy get copyWith => _$PayRequestCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PayRequest _$PayRequestFromJson(Map<String, dynamic> json) =>
    $checkedCreate('PayRequest', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['invoiceId']);
      final val = PayRequest(
        invoiceId: $checkedConvert('invoiceId', (v) => v as String),
        method: $checkedConvert(
          'method',
          (v) =>
              $enumDecodeNullable(_$PayRequestMethodEnumEnumMap, v) ??
              PayRequestMethodEnum.VIETQR,
        ),
      );
      return val;
    });

Map<String, dynamic> _$PayRequestToJson(PayRequest instance) =>
    <String, dynamic>{
      'invoiceId': instance.invoiceId,
      'method': ?_$PayRequestMethodEnumEnumMap[instance.method],
    };

const _$PayRequestMethodEnumEnumMap = {PayRequestMethodEnum.VIETQR: 'VIETQR'};
