//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'api_error.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ApiError {
  /// Returns a new [ApiError] instance.
  ApiError({
    required this.timestamp,

    required this.status,

    required this.code,

    required this.error,

    required this.path,

    required this.requestId,

    required this.fieldErrors,
  });

  @JsonKey(name: r'timestamp', required: true, includeIfNull: false)
  final DateTime timestamp;

  @JsonKey(name: r'status', required: true, includeIfNull: false)
  final int status;

  @JsonKey(name: r'code', required: true, includeIfNull: false)
  final String code;

  @JsonKey(name: r'error', required: true, includeIfNull: false)
  final String error;

  @JsonKey(name: r'path', required: true, includeIfNull: false)
  final String path;

  @JsonKey(name: r'requestId', required: true, includeIfNull: false)
  final String requestId;

  @JsonKey(name: r'fieldErrors', required: true, includeIfNull: false)
  final Map<String, String> fieldErrors;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ApiError &&
          other.timestamp == timestamp &&
          other.status == status &&
          other.code == code &&
          other.error == error &&
          other.path == path &&
          other.requestId == requestId &&
          other.fieldErrors == fieldErrors;

  @override
  int get hashCode =>
      timestamp.hashCode +
      status.hashCode +
      code.hashCode +
      error.hashCode +
      path.hashCode +
      requestId.hashCode +
      fieldErrors.hashCode;

  factory ApiError.fromJson(Map<String, dynamic> json) =>
      _$ApiErrorFromJson(json);

  Map<String, dynamic> toJson() => _$ApiErrorToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
