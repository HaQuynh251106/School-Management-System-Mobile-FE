// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'finance_summary.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$FinanceSummaryCWProxy {
  FinanceSummary invoiceCount(int invoiceCount);

  FinanceSummary paidInvoiceCount(int paidInvoiceCount);

  FinanceSummary totalAmount(int totalAmount);

  FinanceSummary paidAmount(int paidAmount);

  FinanceSummary outstanding(int outstanding);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `FinanceSummary(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// FinanceSummary(...).copyWith(id: 12, name: "My name")
  /// ````
  FinanceSummary call({
    int invoiceCount,
    int paidInvoiceCount,
    int totalAmount,
    int paidAmount,
    int outstanding,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfFinanceSummary.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfFinanceSummary.copyWith.fieldName(...)`
class _$FinanceSummaryCWProxyImpl implements _$FinanceSummaryCWProxy {
  const _$FinanceSummaryCWProxyImpl(this._value);

  final FinanceSummary _value;

  @override
  FinanceSummary invoiceCount(int invoiceCount) =>
      this(invoiceCount: invoiceCount);

  @override
  FinanceSummary paidInvoiceCount(int paidInvoiceCount) =>
      this(paidInvoiceCount: paidInvoiceCount);

  @override
  FinanceSummary totalAmount(int totalAmount) => this(totalAmount: totalAmount);

  @override
  FinanceSummary paidAmount(int paidAmount) => this(paidAmount: paidAmount);

  @override
  FinanceSummary outstanding(int outstanding) => this(outstanding: outstanding);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `FinanceSummary(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// FinanceSummary(...).copyWith(id: 12, name: "My name")
  /// ````
  FinanceSummary call({
    Object? invoiceCount = const $CopyWithPlaceholder(),
    Object? paidInvoiceCount = const $CopyWithPlaceholder(),
    Object? totalAmount = const $CopyWithPlaceholder(),
    Object? paidAmount = const $CopyWithPlaceholder(),
    Object? outstanding = const $CopyWithPlaceholder(),
  }) {
    return FinanceSummary(
      invoiceCount: invoiceCount == const $CopyWithPlaceholder()
          ? _value.invoiceCount
          // ignore: cast_nullable_to_non_nullable
          : invoiceCount as int,
      paidInvoiceCount: paidInvoiceCount == const $CopyWithPlaceholder()
          ? _value.paidInvoiceCount
          // ignore: cast_nullable_to_non_nullable
          : paidInvoiceCount as int,
      totalAmount: totalAmount == const $CopyWithPlaceholder()
          ? _value.totalAmount
          // ignore: cast_nullable_to_non_nullable
          : totalAmount as int,
      paidAmount: paidAmount == const $CopyWithPlaceholder()
          ? _value.paidAmount
          // ignore: cast_nullable_to_non_nullable
          : paidAmount as int,
      outstanding: outstanding == const $CopyWithPlaceholder()
          ? _value.outstanding
          // ignore: cast_nullable_to_non_nullable
          : outstanding as int,
    );
  }
}

extension $FinanceSummaryCopyWith on FinanceSummary {
  /// Returns a callable class that can be used as follows: `instanceOfFinanceSummary.copyWith(...)` or like so:`instanceOfFinanceSummary.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$FinanceSummaryCWProxy get copyWith => _$FinanceSummaryCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FinanceSummary _$FinanceSummaryFromJson(Map<String, dynamic> json) =>
    $checkedCreate('FinanceSummary', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const [
          'invoiceCount',
          'paidInvoiceCount',
          'totalAmount',
          'paidAmount',
          'outstanding',
        ],
      );
      final val = FinanceSummary(
        invoiceCount: $checkedConvert(
          'invoiceCount',
          (v) => (v as num).toInt(),
        ),
        paidInvoiceCount: $checkedConvert(
          'paidInvoiceCount',
          (v) => (v as num).toInt(),
        ),
        totalAmount: $checkedConvert('totalAmount', (v) => (v as num).toInt()),
        paidAmount: $checkedConvert('paidAmount', (v) => (v as num).toInt()),
        outstanding: $checkedConvert('outstanding', (v) => (v as num).toInt()),
      );
      return val;
    });

Map<String, dynamic> _$FinanceSummaryToJson(FinanceSummary instance) =>
    <String, dynamic>{
      'invoiceCount': instance.invoiceCount,
      'paidInvoiceCount': instance.paidInvoiceCount,
      'totalAmount': instance.totalAmount,
      'paidAmount': instance.paidAmount,
      'outstanding': instance.outstanding,
    };
