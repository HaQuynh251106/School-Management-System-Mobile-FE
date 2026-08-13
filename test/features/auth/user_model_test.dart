import 'package:flutter_test/flutter_test.dart';
import 'package:sse_mobile/features/auth/data/models/user_model.dart';

void main() {
  test('maps a backend user response and preserves role fields', () {
    final user = UserModel.fromJson({
      'id': 'stu-1',
      'username': 'hs.an',
      'userCode': 'HS000001',
      'fullName': 'Phạm Hoài An',
      'role': 'STUDENT',
      'status': 'ACTIVE',
      'studentCode': 'HS001',
      'childrenIds': <String>[],
    });

    expect(user.id, 'stu-1');
    expect(user.role, 'STUDENT');
    expect(user.studentCode, 'HS001');
    expect(user.userCode, 'HS000001');
    expect(user.toJson()['username'], 'hs.an');
  });
}
