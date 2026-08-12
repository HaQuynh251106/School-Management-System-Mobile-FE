// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'revenue_report.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$RevenueReportCWProxy {
  RevenueReport invoiceCount(int invoiceCount);

  RevenueReport paidCount(int paidCount);

  RevenueReport totalAmount(int totalAmount);

  RevenueReport paidAmount(int paidAmount);

  RevenueReport outstanding(int outstanding);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RevenueReport(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RevenueReport(...).copyWith(id: 12, name: "My name")
  /// ````
  RevenueReport call({
    int invoiceCount,
    int paidCount,
    int totalAmount,
    int paidAmount,
    int outstanding,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfRevenueReport.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfRevenueReport.copyWith.fieldName(...)`
class _$RevenueReportCWProxyImpl implements _$RevenueReportCWProxy {
  const _$RevenueReportCWProxyImpl(this._value);

  final RevenueReport _value;

  @override
  RevenueReport invoiceCount(int invoiceCount) =>
      this(invoiceCount: invoiceCount);

  @override
  RevenueReport paidCount(int paidCount) => this(paidCount: paidCount);

  @override
  RevenueReport totalAmount(int totalAmount) => this(totalAmount: totalAmount);

  @override
  RevenueReport paidAmount(int paidAmount) => this(paidAmount: paidAmount);

  @override
  RevenueReport outstanding(int outstanding) => this(outstanding: outstanding);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `RevenueReport(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// RevenueReport(...).copyWith(id: 12, name: "My name")
  /// ````
  RevenueReport call({
    Object? invoiceCount = const $CopyWithPlaceholder(),
    Object? paidCount = const $CopyWithPlaceholder(),
    Object? totalAmount = const $CopyWithPlaceholder(),
    Object? paidAmount = const $CopyWithPlaceholder(),
    Object? outstanding = const $CopyWithPlaceholder(),
  }) {
    return RevenueReport(
      invoiceCount: invoiceCount == const $CopyWithPlaceholder()
          ? _value.invoiceCount
          // ignore: cast_nullable_to_non_nullable
          : invoiceCount as int,
      paidCount: paidCount == const $CopyWithPlaceholder()
          ? _value.paidCount
          // ignore: cast_nullable_to_non_nullable
          : paidCount as int,
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

extension $RevenueReportCopyWith on RevenueReport {
  /// Returns a callable class that can be used as follows: `instanceOfRevenueReport.copyWith(...)` or like so:`instanceOfRevenueReport.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$RevenueReportCWProxy get copyWith => _$RevenueReportCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RevenueReport _$RevenueReportFromJson(Map<String, dynamic> json) =>
    $checkedCreate('RevenueReport', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const [
          'invoiceCount',
          'paidCount',
          'totalAmount',
          'paidAmount',
          'outstanding',
        ],
      );
      final val = RevenueReport(
        invoiceCount: $checkedConvert(
          'invoiceCount',
          (v) => (v as num).toInt(),
        ),
        paidCount: $checkedConvert('paidCount', (v) => (v as num).toInt()),
        totalAmount: $checkedConvert('totalAmount', (v) => (v as num).toInt()),
        paidAmount: $checkedConvert('paidAmount', (v) => (v as num).toInt()),
        outstanding: $checkedConvert('outstanding', (v) => (v as num).toInt()),
      );
      return val;
    });

Map<String, dynamic> _$RevenueReportToJson(RevenueReport instance) =>
    <String, dynamic>{
      'invoiceCount': instance.invoiceCount,
      'paidCount': instance.paidCount,
      'totalAmount': instance.totalAmount,
      'paidAmount': instance.paidAmount,
      'outstanding': instance.outstanding,
    };
