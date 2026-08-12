// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_chart.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$DashboardChartCWProxy {
  DashboardChart title(String title);

  DashboardChart subtitle(String subtitle);

  DashboardChart type(String type);

  DashboardChart suffix(String suffix);

  DashboardChart max(num max);

  DashboardChart data(List<DashboardDatum> data);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `DashboardChart(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// DashboardChart(...).copyWith(id: 12, name: "My name")
  /// ````
  DashboardChart call({
    String title,
    String subtitle,
    String type,
    String suffix,
    num max,
    List<DashboardDatum> data,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfDashboardChart.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfDashboardChart.copyWith.fieldName(...)`
class _$DashboardChartCWProxyImpl implements _$DashboardChartCWProxy {
  const _$DashboardChartCWProxyImpl(this._value);

  final DashboardChart _value;

  @override
  DashboardChart title(String title) => this(title: title);

  @override
  DashboardChart subtitle(String subtitle) => this(subtitle: subtitle);

  @override
  DashboardChart type(String type) => this(type: type);

  @override
  DashboardChart suffix(String suffix) => this(suffix: suffix);

  @override
  DashboardChart max(num max) => this(max: max);

  @override
  DashboardChart data(List<DashboardDatum> data) => this(data: data);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `DashboardChart(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// DashboardChart(...).copyWith(id: 12, name: "My name")
  /// ````
  DashboardChart call({
    Object? title = const $CopyWithPlaceholder(),
    Object? subtitle = const $CopyWithPlaceholder(),
    Object? type = const $CopyWithPlaceholder(),
    Object? suffix = const $CopyWithPlaceholder(),
    Object? max = const $CopyWithPlaceholder(),
    Object? data = const $CopyWithPlaceholder(),
  }) {
    return DashboardChart(
      title: title == const $CopyWithPlaceholder()
          ? _value.title
          // ignore: cast_nullable_to_non_nullable
          : title as String,
      subtitle: subtitle == const $CopyWithPlaceholder()
          ? _value.subtitle
          // ignore: cast_nullable_to_non_nullable
          : subtitle as String,
      type: type == const $CopyWithPlaceholder()
          ? _value.type
          // ignore: cast_nullable_to_non_nullable
          : type as String,
      suffix: suffix == const $CopyWithPlaceholder()
          ? _value.suffix
          // ignore: cast_nullable_to_non_nullable
          : suffix as String,
      max: max == const $CopyWithPlaceholder()
          ? _value.max
          // ignore: cast_nullable_to_non_nullable
          : max as num,
      data: data == const $CopyWithPlaceholder()
          ? _value.data
          // ignore: cast_nullable_to_non_nullable
          : data as List<DashboardDatum>,
    );
  }
}

extension $DashboardChartCopyWith on DashboardChart {
  /// Returns a callable class that can be used as follows: `instanceOfDashboardChart.copyWith(...)` or like so:`instanceOfDashboardChart.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$DashboardChartCWProxy get copyWith => _$DashboardChartCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DashboardChart _$DashboardChartFromJson(Map<String, dynamic> json) =>
    $checkedCreate('DashboardChart', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const [
          'title',
          'subtitle',
          'type',
          'suffix',
          'max',
          'data',
        ],
      );
      final val = DashboardChart(
        title: $checkedConvert('title', (v) => v as String),
        subtitle: $checkedConvert('subtitle', (v) => v as String),
        type: $checkedConvert('type', (v) => v as String),
        suffix: $checkedConvert('suffix', (v) => v as String),
        max: $checkedConvert('max', (v) => v as num),
        data: $checkedConvert(
          'data',
          (v) => (v as List<dynamic>)
              .map((e) => DashboardDatum.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
      );
      return val;
    });

Map<String, dynamic> _$DashboardChartToJson(DashboardChart instance) =>
    <String, dynamic>{
      'title': instance.title,
      'subtitle': instance.subtitle,
      'type': instance.type,
      'suffix': instance.suffix,
      'max': instance.max,
      'data': instance.data.map((e) => e.toJson()).toList(),
    };
