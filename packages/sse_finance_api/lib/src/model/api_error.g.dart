// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_error.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ApiErrorCWProxy {
  ApiError timestamp(DateTime timestamp);

  ApiError status(int status);

  ApiError code(String code);

  ApiError error(String error);

  ApiError path(String path);

  ApiError requestId(String requestId);

  ApiError fieldErrors(Map<String, String> fieldErrors);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ApiError(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ApiError(...).copyWith(id: 12, name: "My name")
  /// ````
  ApiError call({
    DateTime timestamp,
    int status,
    String code,
    String error,
    String path,
    String requestId,
    Map<String, String> fieldErrors,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfApiError.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfApiError.copyWith.fieldName(...)`
class _$ApiErrorCWProxyImpl implements _$ApiErrorCWProxy {
  const _$ApiErrorCWProxyImpl(this._value);

  final ApiError _value;

  @override
  ApiError timestamp(DateTime timestamp) => this(timestamp: timestamp);

  @override
  ApiError status(int status) => this(status: status);

  @override
  ApiError code(String code) => this(code: code);

  @override
  ApiError error(String error) => this(error: error);

  @override
  ApiError path(String path) => this(path: path);

  @override
  ApiError requestId(String requestId) => this(requestId: requestId);

  @override
  ApiError fieldErrors(Map<String, String> fieldErrors) =>
      this(fieldErrors: fieldErrors);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ApiError(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ApiError(...).copyWith(id: 12, name: "My name")
  /// ````
  ApiError call({
    Object? timestamp = const $CopyWithPlaceholder(),
    Object? status = const $CopyWithPlaceholder(),
    Object? code = const $CopyWithPlaceholder(),
    Object? error = const $CopyWithPlaceholder(),
    Object? path = const $CopyWithPlaceholder(),
    Object? requestId = const $CopyWithPlaceholder(),
    Object? fieldErrors = const $CopyWithPlaceholder(),
  }) {
    return ApiError(
      timestamp: timestamp == const $CopyWithPlaceholder()
          ? _value.timestamp
          // ignore: cast_nullable_to_non_nullable
          : timestamp as DateTime,
      status: status == const $CopyWithPlaceholder()
          ? _value.status
          // ignore: cast_nullable_to_non_nullable
          : status as int,
      code: code == const $CopyWithPlaceholder()
          ? _value.code
          // ignore: cast_nullable_to_non_nullable
          : code as String,
      error: error == const $CopyWithPlaceholder()
          ? _value.error
          // ignore: cast_nullable_to_non_nullable
          : error as String,
      path: path == const $CopyWithPlaceholder()
          ? _value.path
          // ignore: cast_nullable_to_non_nullable
          : path as String,
      requestId: requestId == const $CopyWithPlaceholder()
          ? _value.requestId
          // ignore: cast_nullable_to_non_nullable
          : requestId as String,
      fieldErrors: fieldErrors == const $CopyWithPlaceholder()
          ? _value.fieldErrors
          // ignore: cast_nullable_to_non_nullable
          : fieldErrors as Map<String, String>,
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
      $checkKeys(
        json,
        requiredKeys: const [
          'timestamp',
          'status',
          'code',
          'error',
          'path',
          'requestId',
          'fieldErrors',
        ],
      );
      final val = ApiError(
        timestamp: $checkedConvert(
          'timestamp',
          (v) => DateTime.parse(v as String),
        ),
        status: $checkedConvert('status', (v) => (v as num).toInt()),
        code: $checkedConvert('code', (v) => v as String),
        error: $checkedConvert('error', (v) => v as String),
        path: $checkedConvert('path', (v) => v as String),
        requestId: $checkedConvert('requestId', (v) => v as String),
        fieldErrors: $checkedConvert(
          'fieldErrors',
          (v) => Map<String, String>.from(v as Map),
        ),
      );
      return val;
    });

Map<String, dynamic> _$ApiErrorToJson(ApiError instance) => <String, dynamic>{
  'timestamp': instance.timestamp.toIso8601String(),
  'status': instance.status,
  'code': instance.code,
  'error': instance.error,
  'path': instance.path,
  'requestId': instance.requestId,
  'fieldErrors': instance.fieldErrors,
};
