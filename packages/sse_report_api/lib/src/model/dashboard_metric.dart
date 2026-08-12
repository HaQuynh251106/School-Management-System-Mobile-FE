//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:sse_report_api/src/model/dashboard_trend.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'dashboard_metric.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class DashboardMetric {
  /// Returns a new [DashboardMetric] instance.
  DashboardMetric({
    required this.key,

    required this.label,

    required this.value,

    required this.format,

    required this.hint,

    required this.tone,

    required this.trend,
  });

  @JsonKey(name: r'key', required: true, includeIfNull: false)
  final String key;

  @JsonKey(name: r'label', required: true, includeIfNull: false)
  final String label;

  @JsonKey(name: r'value', required: true, includeIfNull: false)
  final num value;

  @JsonKey(name: r'format', required: true, includeIfNull: false)
  final String format;

  @JsonKey(name: r'hint', required: true, includeIfNull: false)
  final String hint;

  @JsonKey(name: r'tone', required: true, includeIfNull: false)
  final String tone;

  @JsonKey(name: r'trend', required: true, includeIfNull: false)
  final DashboardTrend trend;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DashboardMetric &&
          other.key == key &&
          other.label == label &&
          other.value == value &&
          other.format == format &&
          other.hint == hint &&
          other.tone == tone &&
          other.trend == trend;

  @override
  int get hashCode =>
      key.hashCode +
      label.hashCode +
      value.hashCode +
      format.hashCode +
      hint.hashCode +
      tone.hashCode +
      trend.hashCode;

  factory DashboardMetric.fromJson(Map<String, dynamic> json) =>
      _$DashboardMetricFromJson(json);

  Map<String, dynamic> toJson() => _$DashboardMetricToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
