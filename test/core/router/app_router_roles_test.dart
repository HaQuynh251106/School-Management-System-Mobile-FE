import 'package:flutter_test/flutter_test.dart';
import 'package:sse_mobile/core/router/app_router.dart';
import 'package:sse_mobile/features/auth/data/models/user_model.dart';

void main() {
  UserModel user(String role) => UserModel(
    id: 'u-$role',
    username: role.toLowerCase(),
    fullName: role,
    role: role,
    status: 'ACTIVE',
    passwordChangeRequired: false,
  );

  test('điều hướng đúng sáu vai trò của ứng dụng mobile', () {
    expect(AppRouter.homeForRole(user('ADMIN')), '/admin');
    expect(AppRouter.homeForRole(user('ACADEMIC_STAFF')), '/academic-staff');
    expect(AppRouter.homeForRole(user('ACCOUNTANT')), '/accountant');
    expect(AppRouter.homeForRole(user('TEACHER')), '/teacher');
    expect(AppRouter.homeForRole(user('STUDENT')), '/student');
    expect(AppRouter.homeForRole(user('PARENT')), '/parent');
    expect(AppRouter.homeForRole(user('UNKNOWN')), '/unsupported-role');
  });
}
