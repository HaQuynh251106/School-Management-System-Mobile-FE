//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'create_user_request.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CreateUserRequest {
  /// Returns a new [CreateUserRequest] instance.
  CreateUserRequest({
    this.id,

    required this.username,

    required this.password,

    required this.fullName,

    required this.role,

    required this.email,

    required this.phone,

    this.avatarUrl,

    this.mainSubjectId,

    this.classId,

    this.className,

    this.dateOfBirth,

    this.gender,

    this.placeOfBirth,

    this.ethnicity,

    this.nationality,

    this.address,

    this.enrollmentDate,

    this.guardianName,

    this.guardianPhone,
  });

  @JsonKey(name: r'id', required: false, includeIfNull: false)
  final String? id;

  @JsonKey(name: r'username', required: true, includeIfNull: false)
  final String username;

  @JsonKey(name: r'password', required: true, includeIfNull: false)
  final String password;

  @JsonKey(name: r'fullName', required: true, includeIfNull: false)
  final String fullName;

  @JsonKey(name: r'role', required: true, includeIfNull: false)
  final CreateUserRequestRoleEnum role;

  @JsonKey(name: r'email', required: true, includeIfNull: false)
  final String email;

  @JsonKey(name: r'phone', required: true, includeIfNull: false)
  final String phone;

  @JsonKey(name: r'avatarUrl', required: false, includeIfNull: false)
  final String? avatarUrl;

  /// Bat buoc khi role la TEACHER; phai la id mon hoc ton tai trong danh muc /subjects.
  @JsonKey(name: r'mainSubjectId', required: false, includeIfNull: false)
  final String? mainSubjectId;

  @JsonKey(name: r'classId', required: false, includeIfNull: false)
  final String? classId;

  @JsonKey(name: r'className', required: false, includeIfNull: false)
  final String? className;

  @JsonKey(name: r'dateOfBirth', required: false, includeIfNull: false)
  final DateTime? dateOfBirth;

  @JsonKey(name: r'gender', required: false, includeIfNull: false)
  final String? gender;

  @JsonKey(name: r'placeOfBirth', required: false, includeIfNull: false)
  final String? placeOfBirth;

  @JsonKey(name: r'ethnicity', required: false, includeIfNull: false)
  final String? ethnicity;

  @JsonKey(name: r'nationality', required: false, includeIfNull: false)
  final String? nationality;

  @JsonKey(name: r'address', required: false, includeIfNull: false)
  final String? address;

  @JsonKey(name: r'enrollmentDate', required: false, includeIfNull: false)
  final DateTime? enrollmentDate;

  @JsonKey(name: r'guardianName', required: false, includeIfNull: false)
  final String? guardianName;

  @JsonKey(name: r'guardianPhone', required: false, includeIfNull: false)
  final String? guardianPhone;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreateUserRequest &&
          other.id == id &&
          other.username == username &&
          other.password == password &&
          other.fullName == fullName &&
          other.role == role &&
          other.email == email &&
          other.phone == phone &&
          other.avatarUrl == avatarUrl &&
          other.mainSubjectId == mainSubjectId &&
          other.classId == classId &&
          other.className == className &&
          other.dateOfBirth == dateOfBirth &&
          other.gender == gender &&
          other.placeOfBirth == placeOfBirth &&
          other.ethnicity == ethnicity &&
          other.nationality == nationality &&
          other.address == address &&
          other.enrollmentDate == enrollmentDate &&
          other.guardianName == guardianName &&
          other.guardianPhone == guardianPhone;

  @override
  int get hashCode =>
      id.hashCode +
      username.hashCode +
      password.hashCode +
      fullName.hashCode +
      role.hashCode +
      email.hashCode +
      phone.hashCode +
      avatarUrl.hashCode +
      mainSubjectId.hashCode +
      classId.hashCode +
      className.hashCode +
      dateOfBirth.hashCode +
      gender.hashCode +
      placeOfBirth.hashCode +
      ethnicity.hashCode +
      nationality.hashCode +
      address.hashCode +
      enrollmentDate.hashCode +
      guardianName.hashCode +
      guardianPhone.hashCode;

  factory CreateUserRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateUserRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreateUserRequestToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum CreateUserRequestRoleEnum {
  @JsonValue(r'ADMIN')
  ADMIN(r'ADMIN'),
  @JsonValue(r'TEACHER')
  TEACHER(r'TEACHER'),
  @JsonValue(r'STUDENT')
  STUDENT(r'STUDENT'),
  @JsonValue(r'PARENT')
  PARENT(r'PARENT');

  const CreateUserRequestRoleEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
