//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'change_password_response.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ChangePasswordResponse {
  /// Returns a new [ChangePasswordResponse] instance.
  ChangePasswordResponse({
    required this.ok,

    required this.reauthenticationRequired,
  });

  @JsonKey(name: r'ok', required: true, includeIfNull: false)
  final bool ok;

  @JsonKey(
    name: r'reauthenticationRequired',
    required: true,
    includeIfNull: false,
  )
  final bool reauthenticationRequired;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChangePasswordResponse &&
          other.ok == ok &&
          other.reauthenticationRequired == reauthenticationRequired;

  @override
  int get hashCode => ok.hashCode + reauthenticationRequired.hashCode;

  factory ChangePasswordResponse.fromJson(Map<String, dynamic> json) =>
      _$ChangePasswordResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ChangePasswordResponseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
