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
    required this.status,

    this.error,

    required this.message,

    this.path,

    this.timestamp,
  });

  @JsonKey(name: r'status', required: true, includeIfNull: false)
  final int status;

  @JsonKey(name: r'error', required: false, includeIfNull: false)
  final String? error;

  @JsonKey(name: r'message', required: true, includeIfNull: false)
  final String message;

  @JsonKey(name: r'path', required: false, includeIfNull: false)
  final String? path;

  @JsonKey(name: r'timestamp', required: false, includeIfNull: false)
  final DateTime? timestamp;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ApiError &&
          other.status == status &&
          other.error == error &&
          other.message == message &&
          other.path == path &&
          other.timestamp == timestamp;

  @override
  int get hashCode =>
      status.hashCode +
      (error == null ? 0 : error.hashCode) +
      message.hashCode +
      (path == null ? 0 : path.hashCode) +
      (timestamp == null ? 0 : timestamp.hashCode);

  factory ApiError.fromJson(Map<String, dynamic> json) =>
      _$ApiErrorFromJson(json);

  Map<String, dynamic> toJson() => _$ApiErrorToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
