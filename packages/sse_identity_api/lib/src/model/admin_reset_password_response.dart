//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'admin_reset_password_response.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AdminResetPasswordResponse {
  /// Returns a new [AdminResetPasswordResponse] instance.
  AdminResetPasswordResponse({required this.ok, required this.password});

  @JsonKey(name: r'ok', required: true, includeIfNull: false)
  final bool ok;

  @JsonKey(name: r'password', required: true, includeIfNull: false)
  final String password;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdminResetPasswordResponse &&
          other.ok == ok &&
          other.password == password;

  @override
  int get hashCode => ok.hashCode + password.hashCode;

  factory AdminResetPasswordResponse.fromJson(Map<String, dynamic> json) =>
      _$AdminResetPasswordResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AdminResetPasswordResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
