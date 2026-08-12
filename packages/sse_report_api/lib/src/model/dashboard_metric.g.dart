// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_metric.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$DashboardMetricCWProxy {
  DashboardMetric key(String key);

  DashboardMetric label(String label);

  DashboardMetric value(num value);

  DashboardMetric format(String format);

  DashboardMetric hint(String hint);

  DashboardMetric tone(String tone);

  DashboardMetric trend(DashboardTrend trend);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `DashboardMetric(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// DashboardMetric(...).copyWith(id: 12, name: "My name")
  /// ````
  DashboardMetric call({
    String key,
    String label,
    num value,
    String format,
    String hint,
    String tone,
    DashboardTrend trend,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfDashboardMetric.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfDashboardMetric.copyWith.fieldName(...)`
class _$DashboardMetricCWProxyImpl implements _$DashboardMetricCWProxy {
  const _$DashboardMetricCWProxyImpl(this._value);

  final DashboardMetric _value;

  @override
  DashboardMetric key(String key) => this(key: key);

  @override
  DashboardMetric label(String label) => this(label: label);

  @override
  DashboardMetric value(num value) => this(value: value);

  @override
  DashboardMetric format(String format) => this(format: format);

  @override
  DashboardMetric hint(String hint) => this(hint: hint);

  @override
  DashboardMetric tone(String tone) => this(tone: tone);

  @override
  DashboardMetric trend(DashboardTrend trend) => this(trend: trend);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `DashboardMetric(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// DashboardMetric(...).copyWith(id: 12, name: "My name")
  /// ````
  DashboardMetric call({
    Object? key = const $CopyWithPlaceholder(),
    Object? label = const $CopyWithPlaceholder(),
    Object? value = const $CopyWithPlaceholder(),
    Object? format = const $CopyWithPlaceholder(),
    Object? hint = const $CopyWithPlaceholder(),
    Object? tone = const $CopyWithPlaceholder(),
    Object? trend = const $CopyWithPlaceholder(),
  }) {
    return DashboardMetric(
      key: key == const $CopyWithPlaceholder()
          ? _value.key
          // ignore: cast_nullable_to_non_nullable
          : key as String,
      label: label == const $CopyWithPlaceholder()
          ? _value.label
          // ignore: cast_nullable_to_non_nullable
          : label as String,
      value: value == const $CopyWithPlaceholder()
          ? _value.value
          // ignore: cast_nullable_to_non_nullable
          : value as num,
      format: format == const $CopyWithPlaceholder()
          ? _value.format
          // ignore: cast_nullable_to_non_nullable
          : format as String,
      hint: hint == const $CopyWithPlaceholder()
          ? _value.hint
          // ignore: cast_nullable_to_non_nullable
          : hint as String,
      tone: tone == const $CopyWithPlaceholder()
          ? _value.tone
          // ignore: cast_nullable_to_non_nullable
          : tone as String,
      trend: trend == const $CopyWithPlaceholder()
          ? _value.trend
          // ignore: cast_nullable_to_non_nullable
          : trend as DashboardTrend,
    );
  }
}

extension $DashboardMetricCopyWith on DashboardMetric {
  /// Returns a callable class that can be used as follows: `instanceOfDashboardMetric.copyWith(...)` or like so:`instanceOfDashboardMetric.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$DashboardMetricCWProxy get copyWith => _$DashboardMetricCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DashboardMetric _$DashboardMetricFromJson(Map<String, dynamic> json) =>
    $checkedCreate('DashboardMetric', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const [
          'key',
          'label',
          'value',
          'format',
          'hint',
          'tone',
          'trend',
        ],
      );
      final val = DashboardMetric(
        key: $checkedConvert('key', (v) => v as String),
        label: $checkedConvert('label', (v) => v as String),
        value: $checkedConvert('value', (v) => v as num),
        format: $checkedConvert('format', (v) => v as String),
        hint: $checkedConvert('hint', (v) => v as String),
        tone: $checkedConvert('tone', (v) => v as String),
        trend: $checkedConvert(
          'trend',
          (v) => DashboardTrend.fromJson(v as Map<String, dynamic>),
        ),
      );
      return val;
    });

Map<String, dynamic> _$DashboardMetricToJson(DashboardMetric instance) =>
    <String, dynamic>{
      'key': instance.key,
      'label': instance.label,
      'value': instance.value,
      'format': instance.format,
      'hint': instance.hint,
      'tone': instance.tone,
      'trend': instance.trend.toJson(),
    };
