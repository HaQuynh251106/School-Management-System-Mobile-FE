class AppUser {
  const AppUser({
    required this.id,
    required this.username,
    required this.fullName,
    required this.role,
    this.email,
    this.classId,
    this.className,
    this.studentCode,
    this.teacherCode,
    this.mainSubject,
    this.passwordChangeRequired = false,
  });

  final String id;
  final String username;
  final String fullName;
  final String role;
  final String? email;
  final String? classId;
  final String? className;
  final String? studentCode;
  final String? teacherCode;
  final String? mainSubject;
  final bool passwordChangeRequired;

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
    id: '${json['id'] ?? ''}',
    username: '${json['username'] ?? ''}',
    fullName: '${json['fullName'] ?? json['username'] ?? ''}',
    role: '${json['role'] ?? 'STUDENT'}'.toUpperCase(),
    email: json['email']?.toString(),
    classId: json['classId']?.toString(),
    className: json['className']?.toString(),
    studentCode: json['studentCode']?.toString(),
    teacherCode: json['teacherCode']?.toString(),
    mainSubject: json['mainSubject']?.toString(),
    passwordChangeRequired: json['passwordChangeRequired'] == true,
  );
}
