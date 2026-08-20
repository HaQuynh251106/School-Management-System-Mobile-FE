const mobileRoleHomes = <String, String>{
  'TEACHER': '/teacher',
  'STUDENT': '/student',
  'PARENT': '/parent',
};

const unsupportedMobileRolePath = '/unsupported-role';

const unsupportedMobileRoleMessage =
    'Tài khoản quản trị chỉ sử dụng trên phiên bản Web. '
    'Ứng dụng Mobile dành cho Giáo viên, Học sinh và Phụ huynh.';

bool isSupportedMobileRole(String role) => mobileRoleHomes.containsKey(role);

String homePathForMobileRole(String role) =>
    mobileRoleHomes[role] ?? unsupportedMobileRolePath;
