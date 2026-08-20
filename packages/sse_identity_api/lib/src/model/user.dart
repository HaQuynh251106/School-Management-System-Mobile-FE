//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@CopyWith()
@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class User {
  /// Returns a new [User] instance.
  User({
    required this.id,

    required this.username,

    required this.fullName,

    required this.role,

    required this.status,

    required this.passwordChangeRequired,

    this.email,

    this.phone,

    this.avatarUrl,

    this.studentCode,

    this.className,

    this.classId,

    this.dateOfBirth,

    this.gender,

    this.placeOfBirth,

    this.ethnicity,

    this.nationality,

    this.address,

    this.enrollmentDate,

    this.guardianName,

    this.guardianPhone,

    this.teacherCode,

    this.mainSubjectId,

    this.mainSubject,

    this.childrenIds,

    this.cohortId,

    this.studentStatus,

    this.graduatedAt,

    this.graduationAcademicYearId,

    this.graduationClassId,
  });

  @JsonKey(name: r'id', required: true, includeIfNull: false)
  final String id;

  @JsonKey(name: r'username', required: true, includeIfNull: false)
  final String username;

  @JsonKey(name: r'fullName', required: true, includeIfNull: false)
  final String fullName;

  @JsonKey(name: r'role', required: true, includeIfNull: false)
  final UserRoleEnum role;

  @JsonKey(name: r'status', required: true, includeIfNull: false)
  final UserStatusEnum status;

  @JsonKey(
    name: r'passwordChangeRequired',
    required: true,
    includeIfNull: false,
  )
  final bool passwordChangeRequired;

  @JsonKey(name: r'email', required: false, includeIfNull: false)
  final String? email;

  @JsonKey(name: r'phone', required: false, includeIfNull: false)
  final String? phone;

  @JsonKey(name: r'avatarUrl', required: false, includeIfNull: false)
  final String? avatarUrl;

  @JsonKey(name: r'studentCode', required: false, includeIfNull: false)
  final String? studentCode;

  @JsonKey(name: r'className', required: false, includeIfNull: false)
  final String? className;

  @JsonKey(name: r'classId', required: false, includeIfNull: false)
  final String? classId;

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

  @JsonKey(name: r'teacherCode', required: false, includeIfNull: false)
  final String? teacherCode;

  @JsonKey(name: r'mainSubjectId', required: false, includeIfNull: false)
  final String? mainSubjectId;

  @JsonKey(name: r'mainSubject', required: false, includeIfNull: false)
  final String? mainSubject;

  @JsonKey(name: r'childrenIds', required: false, includeIfNull: false)
  final List<String>? childrenIds;

  @JsonKey(name: r'cohortId', required: false, includeIfNull: false)
  final String? cohortId;

  @JsonKey(name: r'studentStatus', required: false, includeIfNull: false)
  final String? studentStatus;

  @JsonKey(name: r'graduatedAt', required: false, includeIfNull: false)
  final DateTime? graduatedAt;

  @JsonKey(
    name: r'graduationAcademicYearId',
    required: false,
    includeIfNull: false,
  )
  final String? graduationAcademicYearId;

  @JsonKey(name: r'graduationClassId', required: false, includeIfNull: false)
  final String? graduationClassId;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User &&
          other.id == id &&
          other.username == username &&
          other.fullName == fullName &&
          other.role == role &&
          other.status == status &&
          other.passwordChangeRequired == passwordChangeRequired &&
          other.email == email &&
          other.phone == phone &&
          other.avatarUrl == avatarUrl &&
          other.studentCode == studentCode &&
          other.className == className &&
          other.classId == classId &&
          other.dateOfBirth == dateOfBirth &&
          other.gender == gender &&
          other.placeOfBirth == placeOfBirth &&
          other.ethnicity == ethnicity &&
          other.nationality == nationality &&
          other.address == address &&
          other.enrollmentDate == enrollmentDate &&
          other.guardianName == guardianName &&
          other.guardianPhone == guardianPhone &&
          other.teacherCode == teacherCode &&
          other.mainSubjectId == mainSubjectId &&
          other.mainSubject == mainSubject &&
          other.childrenIds == childrenIds &&
          other.cohortId == cohortId &&
          other.studentStatus == studentStatus &&
          other.graduatedAt == graduatedAt &&
          other.graduationAcademicYearId == graduationAcademicYearId &&
          other.graduationClassId == graduationClassId;

  @override
  int get hashCode =>
      id.hashCode +
      username.hashCode +
      fullName.hashCode +
      role.hashCode +
      status.hashCode +
      passwordChangeRequired.hashCode +
      (email == null ? 0 : email.hashCode) +
      (phone == null ? 0 : phone.hashCode) +
      (avatarUrl == null ? 0 : avatarUrl.hashCode) +
      (studentCode == null ? 0 : studentCode.hashCode) +
      (className == null ? 0 : className.hashCode) +
      (classId == null ? 0 : classId.hashCode) +
      (dateOfBirth == null ? 0 : dateOfBirth.hashCode) +
      (gender == null ? 0 : gender.hashCode) +
      (placeOfBirth == null ? 0 : placeOfBirth.hashCode) +
      (ethnicity == null ? 0 : ethnicity.hashCode) +
      (nationality == null ? 0 : nationality.hashCode) +
      (address == null ? 0 : address.hashCode) +
      (enrollmentDate == null ? 0 : enrollmentDate.hashCode) +
      (guardianName == null ? 0 : guardianName.hashCode) +
      (guardianPhone == null ? 0 : guardianPhone.hashCode) +
      (teacherCode == null ? 0 : teacherCode.hashCode) +
      (mainSubjectId == null ? 0 : mainSubjectId.hashCode) +
      (mainSubject == null ? 0 : mainSubject.hashCode) +
      (childrenIds == null ? 0 : childrenIds.hashCode) +
      (cohortId == null ? 0 : cohortId.hashCode) +
      (studentStatus == null ? 0 : studentStatus.hashCode) +
      (graduatedAt == null ? 0 : graduatedAt.hashCode) +
      (graduationAcademicYearId == null
          ? 0
          : graduationAcademicYearId.hashCode) +
      (graduationClassId == null ? 0 : graduationClassId.hashCode);

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

enum UserRoleEnum {
  @JsonValue(r'ADMIN')
  ADMIN(r'ADMIN'),
  @JsonValue(r'TEACHER')
  TEACHER(r'TEACHER'),
  @JsonValue(r'STUDENT')
  STUDENT(r'STUDENT'),
  @JsonValue(r'PARENT')
  PARENT(r'PARENT');

  const UserRoleEnum(this.value);

  final String value;

  @override
  String toString() => value;
}

enum UserStatusEnum {
  @JsonValue(r'ACTIVE')
  ACTIVE(r'ACTIVE'),
  @JsonValue(r'LOCKED')
  LOCKED(r'LOCKED'),
  @JsonValue(r'INACTIVE')
  INACTIVE(r'INACTIVE');

  const UserStatusEnum(this.value);

  final String value;

  @override
  String toString() => value;
}
