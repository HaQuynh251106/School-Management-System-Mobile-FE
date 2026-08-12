//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'admin_reset_password_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AdminResetPasswordRequest {
  /// Returns a new [AdminResetPasswordRequest] instance.
  AdminResetPasswordRequest({this.newPassword});

  @JsonKey(name: r'newPassword', required: false, includeIfNull: false)
  final String? newPassword;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdminResetPasswordRequest && other.newPassword == newPassword;

  @override
  int get hashCode => (newPassword == null ? 0 : newPassword.hashCode);

  factory AdminResetPasswordRequest.fromJson(Map<String, dynamic> json) =>
      _$AdminResetPasswordRequestFromJson(json);

  Map<String, dynamic> toJson() => _$AdminResetPasswordRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
