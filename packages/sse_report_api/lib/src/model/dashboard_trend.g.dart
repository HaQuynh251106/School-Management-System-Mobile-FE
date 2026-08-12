// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_trend.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$DashboardTrendCWProxy {
  DashboardTrend direction(String direction);

  DashboardTrend change(num? change);

  DashboardTrend label(String label);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `DashboardTrend(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// DashboardTrend(...).copyWith(id: 12, name: "My name")
  /// ````
  DashboardTrend call({String direction, num? change, String label});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfDashboardTrend.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfDashboardTrend.copyWith.fieldName(...)`
class _$DashboardTrendCWProxyImpl implements _$DashboardTrendCWProxy {
  const _$DashboardTrendCWProxyImpl(this._value);

  final DashboardTrend _value;

  @override
  DashboardTrend direction(String direction) => this(direction: direction);

  @override
  DashboardTrend change(num? change) => this(change: change);

  @override
  DashboardTrend label(String label) => this(label: label);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `DashboardTrend(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// DashboardTrend(...).copyWith(id: 12, name: "My name")
  /// ````
  DashboardTrend call({
    Object? direction = const $CopyWithPlaceholder(),
    Object? change = const $CopyWithPlaceholder(),
    Object? label = const $CopyWithPlaceholder(),
  }) {
    return DashboardTrend(
      direction: direction == const $CopyWithPlaceholder()
          ? _value.direction
          // ignore: cast_nullable_to_non_nullable
          : direction as String,
      change: change == const $CopyWithPlaceholder()
          ? _value.change
          // ignore: cast_nullable_to_non_nullable
          : change as num?,
      label: label == const $CopyWithPlaceholder()
          ? _value.label
          // ignore: cast_nullable_to_non_nullable
          : label as String,
    );
  }
}

extension $DashboardTrendCopyWith on DashboardTrend {
  /// Returns a callable class that can be used as follows: `instanceOfDashboardTrend.copyWith(...)` or like so:`instanceOfDashboardTrend.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$DashboardTrendCWProxy get copyWith => _$DashboardTrendCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DashboardTrend _$DashboardTrendFromJson(Map<String, dynamic> json) =>
    $checkedCreate('DashboardTrend', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['direction', 'label']);
      final val = DashboardTrend(
        direction: $checkedConvert('direction', (v) => v as String),
        change: $checkedConvert('change', (v) => v as num?),
        label: $checkedConvert('label', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$DashboardTrendToJson(DashboardTrend instance) =>
    <String, dynamic>{
      'direction': instance.direction,
      'change': ?instance.change,
      'label': instance.label,
    };
