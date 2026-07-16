class UserModel {
  const UserModel({
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
    this.teacherCode,
    this.mainSubject,
    this.childrenIds,
  });

  final String id;
  final String username;
  final String fullName;
  final String role;
  final String status;
  final bool passwordChangeRequired;
  final String? email;
  final String? phone;
  final String? avatarUrl;
  final String? studentCode;
  final String? className;
  final String? classId;
  final String? teacherCode;
  final String? mainSubject;
  final List<String>? childrenIds;

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] as String,
        username: json['username'] as String,
        fullName: json['fullName'] as String,
        role: json['role'] as String,
        status: json['status'] as String,
        passwordChangeRequired:
            json['passwordChangeRequired'] as bool? ?? false,
        email: json['email'] as String?,
        phone: json['phone'] as String?,
        avatarUrl: json['avatarUrl'] as String?,
        studentCode: json['studentCode'] as String?,
        className: json['className'] as String?,
        classId: json['classId'] as String?,
        teacherCode: json['teacherCode'] as String?,
        mainSubject: json['mainSubject'] as String?,
        childrenIds: (json['childrenIds'] as List?)?.cast<String>(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'fullName': fullName,
        'role': role,
        'status': status,
        'passwordChangeRequired': passwordChangeRequired,
        'email': email,
        'phone': phone,
        'avatarUrl': avatarUrl,
        'studentCode': studentCode,
        'className': className,
        'classId': classId,
        'teacherCode': teacherCode,
        'mainSubject': mainSubject,
        'childrenIds': childrenIds,
      };
}
