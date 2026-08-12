// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_error.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ApiErrorCWProxy {
  ApiError status(int status);

  ApiError error(String? error);

  ApiError message(String message);

  ApiError path(String? path);

  ApiError timestamp(DateTime? timestamp);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ApiError(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ApiError(...).copyWith(id: 12, name: "My name")
  /// ````
  ApiError call({
    int status,
    String? error,
    String message,
    String? path,
    DateTime? timestamp,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfApiError.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfApiError.copyWith.fieldName(...)`
class _$ApiErrorCWProxyImpl implements _$ApiErrorCWProxy {
  const _$ApiErrorCWProxyImpl(this._value);

  final ApiError _value;

  @override
  ApiError status(int status) => this(status: status);

  @override
  ApiError error(String? error) => this(error: error);

  @override
  ApiError message(String message) => this(message: message);

  @override
  ApiError path(String? path) => this(path: path);

  @override
  ApiError timestamp(DateTime? timestamp) => this(timestamp: timestamp);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ApiError(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ApiError(...).copyWith(id: 12, name: "My name")
  /// ````
  ApiError call({
    Object? status = const $CopyWithPlaceholder(),
    Object? error = const $CopyWithPlaceholder(),
    Object? message = const $CopyWithPlaceholder(),
    Object? path = const $CopyWithPlaceholder(),
    Object? timestamp = const $CopyWithPlaceholder(),
  }) {
    return ApiError(
      status: status == const $CopyWithPlaceholder()
          ? _value.status
          // ignore: cast_nullable_to_non_nullable
          : status as int,
      error: error == const $CopyWithPlaceholder()
          ? _value.error
          // ignore: cast_nullable_to_non_nullable
          : error as String?,
      message: message == const $CopyWithPlaceholder()
          ? _value.message
          // ignore: cast_nullable_to_non_nullable
          : message as String,
      path: path == const $CopyWithPlaceholder()
          ? _value.path
          // ignore: cast_nullable_to_non_nullable
          : path as String?,
      timestamp: timestamp == const $CopyWithPlaceholder()
          ? _value.timestamp
          // ignore: cast_nullable_to_non_nullable
          : timestamp as DateTime?,
    );
  }
}

extension $ApiErrorCopyWith on ApiError {
  /// Returns a callable class that can be used as follows: `instanceOfApiError.copyWith(...)` or like so:`instanceOfApiError.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$ApiErrorCWProxy get copyWith => _$ApiErrorCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiError _$ApiErrorFromJson(Map<String, dynamic> json) =>
    $checkedCreate('ApiError', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['status', 'message']);
      final val = ApiError(
        status: $checkedConvert('status', (v) => (v as num).toInt()),
        error: $checkedConvert('error', (v) => v as String?),
        message: $checkedConvert('message', (v) => v as String),
        path: $checkedConvert('path', (v) => v as String?),
        timestamp: $checkedConvert(
          'timestamp',
          (v) => v == null ? null : DateTime.parse(v as String),
        ),
      );
      return val;
    });

Map<String, dynamic> _$ApiErrorToJson(ApiError instance) => <String, dynamic>{
  'status': instance.status,
  'error': ?instance.error,
  'message': instance.message,
  'path': ?instance.path,
  'timestamp': ?instance.timestamp?.toIso8601String(),
};
