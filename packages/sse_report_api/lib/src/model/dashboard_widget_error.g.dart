// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_widget_error.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$DashboardWidgetErrorCWProxy {
  DashboardWidgetError widget(String widget);

  DashboardWidgetError code(String code);

  DashboardWidgetError message(String message);

  DashboardWidgetError retryable(bool retryable);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `DashboardWidgetError(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// DashboardWidgetError(...).copyWith(id: 12, name: "My name")
  /// ````
  DashboardWidgetError call({
    String widget,
    String code,
    String message,
    bool retryable,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfDashboardWidgetError.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfDashboardWidgetError.copyWith.fieldName(...)`
class _$DashboardWidgetErrorCWProxyImpl
    implements _$DashboardWidgetErrorCWProxy {
  const _$DashboardWidgetErrorCWProxyImpl(this._value);

  final DashboardWidgetError _value;

  @override
  DashboardWidgetError widget(String widget) => this(widget: widget);

  @override
  DashboardWidgetError code(String code) => this(code: code);

  @override
  DashboardWidgetError message(String message) => this(message: message);

  @override
  DashboardWidgetError retryable(bool retryable) => this(retryable: retryable);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `DashboardWidgetError(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// DashboardWidgetError(...).copyWith(id: 12, name: "My name")
  /// ````
  DashboardWidgetError call({
    Object? widget = const $CopyWithPlaceholder(),
    Object? code = const $CopyWithPlaceholder(),
    Object? message = const $CopyWithPlaceholder(),
    Object? retryable = const $CopyWithPlaceholder(),
  }) {
    return DashboardWidgetError(
      widget: widget == const $CopyWithPlaceholder()
          ? _value.widget
          // ignore: cast_nullable_to_non_nullable
          : widget as String,
      code: code == const $CopyWithPlaceholder()
          ? _value.code
          // ignore: cast_nullable_to_non_nullable
          : code as String,
      message: message == const $CopyWithPlaceholder()
          ? _value.message
          // ignore: cast_nullable_to_non_nullable
          : message as String,
      retryable: retryable == const $CopyWithPlaceholder()
          ? _value.retryable
          // ignore: cast_nullable_to_non_nullable
          : retryable as bool,
    );
  }
}

extension $DashboardWidgetErrorCopyWith on DashboardWidgetError {
  /// Returns a callable class that can be used as follows: `instanceOfDashboardWidgetError.copyWith(...)` or like so:`instanceOfDashboardWidgetError.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$DashboardWidgetErrorCWProxy get copyWith =>
      _$DashboardWidgetErrorCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DashboardWidgetError _$DashboardWidgetErrorFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('DashboardWidgetError', json, ($checkedConvert) {
  $checkKeys(
    json,
    requiredKeys: const ['widget', 'code', 'message', 'retryable'],
  );
  final val = DashboardWidgetError(
    widget: $checkedConvert('widget', (v) => v as String),
    code: $checkedConvert('code', (v) => v as String),
    message: $checkedConvert('message', (v) => v as String),
    retryable: $checkedConvert('retryable', (v) => v as bool),
  );
  return val;
});

Map<String, dynamic> _$DashboardWidgetErrorToJson(
  DashboardWidgetError instance,
) => <String, dynamic>{
  'widget': instance.widget,
  'code': instance.code,
  'message': instance.message,
  'retryable': instance.retryable,
};
