import 'package:flutter_test/flutter_test.dart';
import 'package:smart_school_mobile_v2/core/models/app_user.dart';

void main() {
  test('đọc đúng hồ sơ người dùng từ API', () {
    final user = AppUser.fromJson({
      'id': 'u-1',
      'username': 'teacher01',
      'fullName': 'Nguyễn Đức Minh',
      'role': 'teacher',
      'mainSubject': 'Toán',
    });

    expect(user.id, 'u-1');
    expect(user.role, 'TEACHER');
    expect(user.fullName, 'Nguyễn Đức Minh');
    expect(user.mainSubject, 'Toán');
  });
}
