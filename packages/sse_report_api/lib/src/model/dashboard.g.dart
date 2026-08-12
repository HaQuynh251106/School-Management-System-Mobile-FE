// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$DashboardCWProxy {
  Dashboard asOf(DateTime asOf);

  Dashboard scope(DashboardScope scope);

  Dashboard metrics(List<DashboardMetric> metrics);

  Dashboard charts(List<DashboardChart> charts);

  Dashboard shortcuts(List<DashboardShortcut> shortcuts);

  Dashboard errors(List<DashboardWidgetError> errors);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Dashboard(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Dashboard(...).copyWith(id: 12, name: "My name")
  /// ````
  Dashboard call({
    DateTime asOf,
    DashboardScope scope,
    List<DashboardMetric> metrics,
    List<DashboardChart> charts,
    List<DashboardShortcut> shortcuts,
    List<DashboardWidgetError> errors,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfDashboard.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfDashboard.copyWith.fieldName(...)`
class _$DashboardCWProxyImpl implements _$DashboardCWProxy {
  const _$DashboardCWProxyImpl(this._value);

  final Dashboard _value;

  @override
  Dashboard asOf(DateTime asOf) => this(asOf: asOf);

  @override
  Dashboard scope(DashboardScope scope) => this(scope: scope);

  @override
  Dashboard metrics(List<DashboardMetric> metrics) => this(metrics: metrics);

  @override
  Dashboard charts(List<DashboardChart> charts) => this(charts: charts);

  @override
  Dashboard shortcuts(List<DashboardShortcut> shortcuts) =>
      this(shortcuts: shortcuts);

  @override
  Dashboard errors(List<DashboardWidgetError> errors) => this(errors: errors);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Dashboard(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Dashboard(...).copyWith(id: 12, name: "My name")
  /// ````
  Dashboard call({
    Object? asOf = const $CopyWithPlaceholder(),
    Object? scope = const $CopyWithPlaceholder(),
    Object? metrics = const $CopyWithPlaceholder(),
    Object? charts = const $CopyWithPlaceholder(),
    Object? shortcuts = const $CopyWithPlaceholder(),
    Object? errors = const $CopyWithPlaceholder(),
  }) {
    return Dashboard(
      asOf: asOf == const $CopyWithPlaceholder()
          ? _value.asOf
          // ignore: cast_nullable_to_non_nullable
          : asOf as DateTime,
      scope: scope == const $CopyWithPlaceholder()
          ? _value.scope
          // ignore: cast_nullable_to_non_nullable
          : scope as DashboardScope,
      metrics: metrics == const $CopyWithPlaceholder()
          ? _value.metrics
          // ignore: cast_nullable_to_non_nullable
          : metrics as List<DashboardMetric>,
      charts: charts == const $CopyWithPlaceholder()
          ? _value.charts
          // ignore: cast_nullable_to_non_nullable
          : charts as List<DashboardChart>,
      shortcuts: shortcuts == const $CopyWithPlaceholder()
          ? _value.shortcuts
          // ignore: cast_nullable_to_non_nullable
          : shortcuts as List<DashboardShortcut>,
      errors: errors == const $CopyWithPlaceholder()
          ? _value.errors
          // ignore: cast_nullable_to_non_nullable
          : errors as List<DashboardWidgetError>,
    );
  }
}

extension $DashboardCopyWith on Dashboard {
  /// Returns a callable class that can be used as follows: `instanceOfDashboard.copyWith(...)` or like so:`instanceOfDashboard.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$DashboardCWProxy get copyWith => _$DashboardCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Dashboard _$DashboardFromJson(Map<String, dynamic> json) =>
    $checkedCreate('Dashboard', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const [
          'asOf',
          'scope',
          'metrics',
          'charts',
          'shortcuts',
          'errors',
        ],
      );
      final val = Dashboard(
        asOf: $checkedConvert('asOf', (v) => DateTime.parse(v as String)),
        scope: $checkedConvert(
          'scope',
          (v) => DashboardScope.fromJson(v as Map<String, dynamic>),
        ),
        metrics: $checkedConvert(
          'metrics',
          (v) => (v as List<dynamic>)
              .map((e) => DashboardMetric.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
        charts: $checkedConvert(
          'charts',
          (v) => (v as List<dynamic>)
              .map((e) => DashboardChart.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
        shortcuts: $checkedConvert(
          'shortcuts',
          (v) => (v as List<dynamic>)
              .map((e) => DashboardShortcut.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
        errors: $checkedConvert(
          'errors',
          (v) => (v as List<dynamic>)
              .map(
                (e) => DashboardWidgetError.fromJson(e as Map<String, dynamic>),
              )
              .toList(),
        ),
      );
      return val;
    });

Map<String, dynamic> _$DashboardToJson(Dashboard instance) => <String, dynamic>{
  'asOf': instance.asOf.toIso8601String(),
  'scope': instance.scope.toJson(),
  'metrics': instance.metrics.map((e) => e.toJson()).toList(),
  'charts': instance.charts.map((e) => e.toJson()).toList(),
  'shortcuts': instance.shortcuts.map((e) => e.toJson()).toList(),
  'errors': instance.errors.map((e) => e.toJson()).toList(),
};
