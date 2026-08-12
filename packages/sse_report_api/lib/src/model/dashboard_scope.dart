//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'dashboard_scope.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class DashboardScope {
  /// Returns a new [DashboardScope] instance.
  DashboardScope({
    required this.role,

    required this.objectType,

    required this.objectIds,
  });

  @JsonKey(name: r'role', required: true, includeIfNull: false)
  final String role;

  @JsonKey(name: r'objectType', required: true, includeIfNull: false)
  final String objectType;

  @JsonKey(name: r'objectIds', required: true, includeIfNull: false)
  final List<String> objectIds;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DashboardScope &&
          other.role == role &&
          other.objectType == objectType &&
          other.objectIds == objectIds;

  @override
  int get hashCode => role.hashCode + objectType.hashCode + objectIds.hashCode;

  factory DashboardScope.fromJson(Map<String, dynamic> json) =>
      _$DashboardScopeFromJson(json);

  Map<String, dynamic> toJson() => _$DashboardScopeToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
