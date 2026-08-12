//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:sse_report_api/src/model/dashboard_chart.dart';
import 'package:sse_report_api/src/model/dashboard_metric.dart';
import 'package:sse_report_api/src/model/dashboard_shortcut.dart';
import 'package:sse_report_api/src/model/dashboard_scope.dart';
import 'package:sse_report_api/src/model/dashboard_widget_error.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'dashboard.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class Dashboard {
  /// Returns a new [Dashboard] instance.
  Dashboard({
    required this.asOf,

    required this.scope,

    required this.metrics,

    required this.charts,

    required this.shortcuts,

    required this.errors,
  });

  @JsonKey(name: r'asOf', required: true, includeIfNull: false)
  final DateTime asOf;

  @JsonKey(name: r'scope', required: true, includeIfNull: false)
  final DashboardScope scope;

  @JsonKey(name: r'metrics', required: true, includeIfNull: false)
  final List<DashboardMetric> metrics;

  @JsonKey(name: r'charts', required: true, includeIfNull: false)
  final List<DashboardChart> charts;

  @JsonKey(name: r'shortcuts', required: true, includeIfNull: false)
  final List<DashboardShortcut> shortcuts;

  @JsonKey(name: r'errors', required: true, includeIfNull: false)
  final List<DashboardWidgetError> errors;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Dashboard &&
          other.asOf == asOf &&
          other.scope == scope &&
          other.metrics == metrics &&
          other.charts == charts &&
          other.shortcuts == shortcuts &&
          other.errors == errors;

  @override
  int get hashCode =>
      asOf.hashCode +
      scope.hashCode +
      metrics.hashCode +
      charts.hashCode +
      shortcuts.hashCode +
      errors.hashCode;

  factory Dashboard.fromJson(Map<String, dynamic> json) =>
      _$DashboardFromJson(json);

  Map<String, dynamic> toJson() => _$DashboardToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
