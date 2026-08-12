//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:sse_report_api/src/model/dashboard_datum.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'dashboard_chart.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class DashboardChart {
  /// Returns a new [DashboardChart] instance.
  DashboardChart({
    required this.title,

    required this.subtitle,

    required this.type,

    required this.suffix,

    required this.max,

    required this.data,
  });

  @JsonKey(name: r'title', required: true, includeIfNull: false)
  final String title;

  @JsonKey(name: r'subtitle', required: true, includeIfNull: false)
  final String subtitle;

  @JsonKey(name: r'type', required: true, includeIfNull: false)
  final String type;

  @JsonKey(name: r'suffix', required: true, includeIfNull: false)
  final String suffix;

  @JsonKey(name: r'max', required: true, includeIfNull: false)
  final num max;

  @JsonKey(name: r'data', required: true, includeIfNull: false)
  final List<DashboardDatum> data;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DashboardChart &&
          other.title == title &&
          other.subtitle == subtitle &&
          other.type == type &&
          other.suffix == suffix &&
          other.max == max &&
          other.data == data;

  @override
  int get hashCode =>
      title.hashCode +
      subtitle.hashCode +
      type.hashCode +
      suffix.hashCode +
      max.hashCode +
      data.hashCode;

  factory DashboardChart.fromJson(Map<String, dynamic> json) =>
      _$DashboardChartFromJson(json);

  Map<String, dynamic> toJson() => _$DashboardChartToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
