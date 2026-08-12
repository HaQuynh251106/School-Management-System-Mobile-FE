// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_shortcut.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$DashboardShortcutCWProxy {
  DashboardShortcut key(String key);

  DashboardShortcut label(String label);

  DashboardShortcut target(String target);

  DashboardShortcut filters(Map<String, String> filters);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `DashboardShortcut(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// DashboardShortcut(...).copyWith(id: 12, name: "My name")
  /// ````
  DashboardShortcut call({
    String key,
    String label,
    String target,
    Map<String, String> filters,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfDashboardShortcut.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfDashboardShortcut.copyWith.fieldName(...)`
class _$DashboardShortcutCWProxyImpl implements _$DashboardShortcutCWProxy {
  const _$DashboardShortcutCWProxyImpl(this._value);

  final DashboardShortcut _value;

  @override
  DashboardShortcut key(String key) => this(key: key);

  @override
  DashboardShortcut label(String label) => this(label: label);

  @override
  DashboardShortcut target(String target) => this(target: target);

  @override
  DashboardShortcut filters(Map<String, String> filters) =>
      this(filters: filters);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `DashboardShortcut(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// DashboardShortcut(...).copyWith(id: 12, name: "My name")
  /// ````
  DashboardShortcut call({
    Object? key = const $CopyWithPlaceholder(),
    Object? label = const $CopyWithPlaceholder(),
    Object? target = const $CopyWithPlaceholder(),
    Object? filters = const $CopyWithPlaceholder(),
  }) {
    return DashboardShortcut(
      key: key == const $CopyWithPlaceholder()
          ? _value.key
          // ignore: cast_nullable_to_non_nullable
          : key as String,
      label: label == const $CopyWithPlaceholder()
          ? _value.label
          // ignore: cast_nullable_to_non_nullable
          : label as String,
      target: target == const $CopyWithPlaceholder()
          ? _value.target
          // ignore: cast_nullable_to_non_nullable
          : target as String,
      filters: filters == const $CopyWithPlaceholder()
          ? _value.filters
          // ignore: cast_nullable_to_non_nullable
          : filters as Map<String, String>,
    );
  }
}

extension $DashboardShortcutCopyWith on DashboardShortcut {
  /// Returns a callable class that can be used as follows: `instanceOfDashboardShortcut.copyWith(...)` or like so:`instanceOfDashboardShortcut.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$DashboardShortcutCWProxy get copyWith =>
      _$DashboardShortcutCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DashboardShortcut _$DashboardShortcutFromJson(Map<String, dynamic> json) =>
    $checkedCreate('DashboardShortcut', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const ['key', 'label', 'target', 'filters'],
      );
      final val = DashboardShortcut(
        key: $checkedConvert('key', (v) => v as String),
        label: $checkedConvert('label', (v) => v as String),
        target: $checkedConvert('target', (v) => v as String),
        filters: $checkedConvert(
          'filters',
          (v) => Map<String, String>.from(v as Map),
        ),
      );
      return val;
    });

Map<String, dynamic> _$DashboardShortcutToJson(DashboardShortcut instance) =>
    <String, dynamic>{
      'key': instance.key,
      'label': instance.label,
      'target': instance.target,
      'filters': instance.filters,
    };
