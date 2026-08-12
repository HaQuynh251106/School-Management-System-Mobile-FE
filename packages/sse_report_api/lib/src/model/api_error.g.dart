// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_error.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$ApiErrorCWProxy {
  ApiError code(String code);

  ApiError message(String message);

  ApiError details(Map<String, Object>? details);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ApiError(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ApiError(...).copyWith(id: 12, name: "My name")
  /// ````
  ApiError call({String code, String message, Map<String, Object>? details});
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfApiError.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfApiError.copyWith.fieldName(...)`
class _$ApiErrorCWProxyImpl implements _$ApiErrorCWProxy {
  const _$ApiErrorCWProxyImpl(this._value);

  final ApiError _value;

  @override
  ApiError code(String code) => this(code: code);

  @override
  ApiError message(String message) => this(message: message);

  @override
  ApiError details(Map<String, Object>? details) => this(details: details);

  @override
  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `ApiError(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// ApiError(...).copyWith(id: 12, name: "My name")
  /// ````
  ApiError call({
    Object? code = const $CopyWithPlaceholder(),
    Object? message = const $CopyWithPlaceholder(),
    Object? details = const $CopyWithPlaceholder(),
  }) {
    return ApiError(
      code: code == const $CopyWithPlaceholder()
          ? _value.code
          // ignore: cast_nullable_to_non_nullable
          : code as String,
      message: message == const $CopyWithPlaceholder()
          ? _value.message
          // ignore: cast_nullable_to_non_nullable
          : message as String,
      details: details == const $CopyWithPlaceholder()
          ? _value.details
          // ignore: cast_nullable_to_non_nullable
          : details as Map<String, Object>?,
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
      $checkKeys(json, requiredKeys: const ['code', 'message']);
      final val = ApiError(
        code: $checkedConvert('code', (v) => v as String),
        message: $checkedConvert('message', (v) => v as String),
        details: $checkedConvert(
          'details',
          (v) => (v as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as Object),
          ),
        ),
      );
      return val;
    });

Map<String, dynamic> _$ApiErrorToJson(ApiError instance) => <String, dynamic>{
  'code': instance.code,
  'message': instance.message,
  'details': ?instance.details,
};
