// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_scope.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$DashboardScopeCWProxy {
  DashboardScope role(String role);

  DashboardScope objectType(String objectType);

  DashboardScope objectIds(List<String> objectIds);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `DashboardScope(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// DashboardScope(...).copyWith(id: 12, name: "My name")
  /// ````
  DashboardScope call({String role, String objectType, List<String> objectIds});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfDashboardScope.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfDashboardScope.copyWith.fieldName(...)`
class _$DashboardScopeCWProxyImpl implements _$DashboardScopeCWProxy {
  const _$DashboardScopeCWProxyImpl(this._value);

  final DashboardScope _value;

  @override
  DashboardScope role(String role) => this(role: role);

  @override
  DashboardScope objectType(String objectType) => this(objectType: objectType);

  @override
  DashboardScope objectIds(List<String> objectIds) =>
      this(objectIds: objectIds);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `DashboardScope(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// DashboardScope(...).copyWith(id: 12, name: "My name")
  /// ````
  DashboardScope call({
    Object? role = const $CopyWithPlaceholder(),
    Object? objectType = const $CopyWithPlaceholder(),
    Object? objectIds = const $CopyWithPlaceholder(),
  }) {
    return DashboardScope(
      role: role == const $CopyWithPlaceholder()
          ? _value.role
          // ignore: cast_nullable_to_non_nullable
          : role as String,
      objectType: objectType == const $CopyWithPlaceholder()
          ? _value.objectType
          // ignore: cast_nullable_to_non_nullable
          : objectType as String,
      objectIds: objectIds == const $CopyWithPlaceholder()
          ? _value.objectIds
          // ignore: cast_nullable_to_non_nullable
          : objectIds as List<String>,
    );
  }
}

extension $DashboardScopeCopyWith on DashboardScope {
  /// Returns a callable class that can be used as follows: `instanceOfDashboardScope.copyWith(...)` or like so:`instanceOfDashboardScope.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$DashboardScopeCWProxy get copyWith => _$DashboardScopeCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DashboardScope _$DashboardScopeFromJson(Map<String, dynamic> json) =>
    $checkedCreate('DashboardScope', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['role', 'objectType', 'objectIds']);
      final val = DashboardScope(
        role: $checkedConvert('role', (v) => v as String),
        objectType: $checkedConvert('objectType', (v) => v as String),
        objectIds: $checkedConvert(
          'objectIds',
          (v) => (v as List<dynamic>).map((e) => e as String).toList(),
        ),
      );
      return val;
    });

Map<String, dynamic> _$DashboardScopeToJson(DashboardScope instance) =>
    <String, dynamic>{
      'role': instance.role,
      'objectType': instance.objectType,
      'objectIds': instance.objectIds,
    };
