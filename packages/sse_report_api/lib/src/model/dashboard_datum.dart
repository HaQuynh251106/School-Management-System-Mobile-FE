//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'dashboard_datum.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class DashboardDatum {
  /// Returns a new [DashboardDatum] instance.
  DashboardDatum({required this.label, required this.value});

  @JsonKey(name: r'label', required: true, includeIfNull: false)
  final String label;

  @JsonKey(name: r'value', required: true, includeIfNull: false)
  final num value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DashboardDatum && other.label == label && other.value == value;

  @override
  int get hashCode => label.hashCode + value.hashCode;

  factory DashboardDatum.fromJson(Map<String, dynamic> json) =>
      _$DashboardDatumFromJson(json);

  Map<String, dynamic> toJson() => _$DashboardDatumToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
