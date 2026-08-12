//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'update_my_profile_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class UpdateMyProfileRequest {
  /// Returns a new [UpdateMyProfileRequest] instance.
  UpdateMyProfileRequest({
    this.email,

    this.phone,

    this.avatarUrl,

    this.address,

    this.guardianName,

    this.guardianPhone,
  });

  @JsonKey(name: r'email', required: false, includeIfNull: false)
  final String? email;

  @JsonKey(name: r'phone', required: false, includeIfNull: false)
  final String? phone;

  @JsonKey(name: r'avatarUrl', required: false, includeIfNull: false)
  final String? avatarUrl;

  @JsonKey(name: r'address', required: false, includeIfNull: false)
  final String? address;

  @JsonKey(name: r'guardianName', required: false, includeIfNull: false)
  final String? guardianName;

  @JsonKey(name: r'guardianPhone', required: false, includeIfNull: false)
  final String? guardianPhone;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpdateMyProfileRequest &&
          other.email == email &&
          other.phone == phone &&
          other.avatarUrl == avatarUrl &&
          other.address == address &&
          other.guardianName == guardianName &&
          other.guardianPhone == guardianPhone;

  @override
  int get hashCode =>
      (email == null ? 0 : email.hashCode) +
      (phone == null ? 0 : phone.hashCode) +
      (avatarUrl == null ? 0 : avatarUrl.hashCode) +
      (address == null ? 0 : address.hashCode) +
      (guardianName == null ? 0 : guardianName.hashCode) +
      (guardianPhone == null ? 0 : guardianPhone.hashCode);

  factory UpdateMyProfileRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateMyProfileRequestFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateMyProfileRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}
