//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'dashboard_shortcut.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class DashboardShortcut {
  /// Returns a new [DashboardShortcut] instance.
  DashboardShortcut({
    required this.key,

    required this.label,

    required this.target,

    required this.filters,
  });

  @JsonKey(name: r'key', required: true, includeIfNull: false)
  final String key;

  @JsonKey(name: r'label', required: true, includeIfNull: false)
  final String label;

  @JsonKey(name: r'target', required: true, includeIfNull: false)
  final String target;

  @JsonKey(name: r'filters', required: true, includeIfNull: false)
  final Map<String, String> filters;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DashboardShortcut &&
          other.key == key &&
          other.label == label &&
          other.target == target &&
          other.filters == filters;

  @override
  int get hashCode =>
      key.hashCode + label.hashCode + target.hashCode + filters.hashCode;

  factory DashboardShortcut.fromJson(Map<String, dynamic> json) =>
      _$DashboardShortcutFromJson(json);

  Map<String, dynamic> toJson() => _$DashboardShortcutToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
