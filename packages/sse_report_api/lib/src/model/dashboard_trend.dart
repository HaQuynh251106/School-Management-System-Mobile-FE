//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'dashboard_trend.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class DashboardTrend {
  /// Returns a new [DashboardTrend] instance.
  DashboardTrend({required this.direction, this.change, required this.label});

  @JsonKey(name: r'direction', required: true, includeIfNull: false)
  final String direction;

  @JsonKey(name: r'change', required: false, includeIfNull: false)
  final num? change;

  @JsonKey(name: r'label', required: true, includeIfNull: false)
  final String label;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DashboardTrend &&
          other.direction == direction &&
          other.change == change &&
          other.label == label;

  @override
  int get hashCode => direction.hashCode + change.hashCode + label.hashCode;

  factory DashboardTrend.fromJson(Map<String, dynamic> json) =>
      _$DashboardTrendFromJson(json);

  Map<String, dynamic> toJson() => _$DashboardTrendToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
