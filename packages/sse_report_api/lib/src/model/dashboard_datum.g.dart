// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_datum.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$DashboardDatumCWProxy {
  DashboardDatum label(String label);

  DashboardDatum value(num value);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `DashboardDatum(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// DashboardDatum(...).copyWith(id: 12, name: "My name")
  /// ````
  DashboardDatum call({String label, num value});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfDashboardDatum.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfDashboardDatum.copyWith.fieldName(...)`
class _$DashboardDatumCWProxyImpl implements _$DashboardDatumCWProxy {
  const _$DashboardDatumCWProxyImpl(this._value);

  final DashboardDatum _value;

  @override
  DashboardDatum label(String label) => this(label: label);

  @override
  DashboardDatum value(num value) => this(value: value);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `DashboardDatum(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// DashboardDatum(...).copyWith(id: 12, name: "My name")
  /// ````
  DashboardDatum call({
    Object? label = const $CopyWithPlaceholder(),
    Object? value = const $CopyWithPlaceholder(),
  }) {
    return DashboardDatum(
      label: label == const $CopyWithPlaceholder()
          ? _value.label
          // ignore: cast_nullable_to_non_nullable
          : label as String,
      value: value == const $CopyWithPlaceholder()
          ? _value.value
          // ignore: cast_nullable_to_non_nullable
          : value as num,
    );
  }
}

extension $DashboardDatumCopyWith on DashboardDatum {
  /// Returns a callable class that can be used as follows: `instanceOfDashboardDatum.copyWith(...)` or like so:`instanceOfDashboardDatum.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$DashboardDatumCWProxy get copyWith => _$DashboardDatumCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DashboardDatum _$DashboardDatumFromJson(Map<String, dynamic> json) =>
    $checkedCreate('DashboardDatum', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['label', 'value']);
      final val = DashboardDatum(
        label: $checkedConvert('label', (v) => v as String),
        value: $checkedConvert('value', (v) => v as num),
      );
      return val;
    });

Map<String, dynamic> _$DashboardDatumToJson(DashboardDatum instance) =>
    <String, dynamic>{'label': instance.label, 'value': instance.value};
