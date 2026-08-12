//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'forgot_password_response.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ForgotPasswordResponse {
  /// Returns a new [ForgotPasswordResponse] instance.
  ForgotPasswordResponse({
    required this.ok,

    required this.message,

    this.devResetToken,
  });

  @JsonKey(name: r'ok', required: true, includeIfNull: false)
  final bool ok;

  @JsonKey(name: r'message', required: true, includeIfNull: false)
  final String message;

  @JsonKey(name: r'devResetToken', required: false, includeIfNull: false)
  final String? devResetToken;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ForgotPasswordResponse &&
          other.ok == ok &&
          other.message == message &&
          other.devResetToken == devResetToken;

  @override
  int get hashCode =>
      ok.hashCode +
      message.hashCode +
      (devResetToken == null ? 0 : devResetToken.hashCode);

  factory ForgotPasswordResponse.fromJson(Map<String, dynamic> json) =>
      _$ForgotPasswordResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ForgotPasswordResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
