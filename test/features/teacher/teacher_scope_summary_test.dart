import 'package:flutter_test/flutter_test.dart';
import 'package:sse_mobile/features/teacher/presentation/pages/teacher_home.dart';

void main() {
  test('giáo viên mới không kế thừa lớp và môn của giáo viên khác', () {
    final summary = TeacherScopeSummary.fromApi(
      teacherId: 'teacher-new',
      classes: const [
        {
          'id': 'class-10a1',
          'code': '10A1',
          'homeroomTeacherId': 'teacher-existing',
        },
      ],
      assignments: const [],
    );

    expect(summary.homeroomLabel, 'Chưa được phân công');
    expect(summary.teachingLabel, 'Chưa được phân công giảng dạy');
  });

  test('chỉ tổng hợp lớp chủ nhiệm và phân công đúng giáo viên', () {
    final summary = TeacherScopeSummary.fromApi(
      teacherId: 'teacher-1',
      classes: const [
        {'id': 'class-10a1', 'code': '10A1', 'homeroomTeacherId': 'teacher-1'},
      ],
      assignments: const [
        {
          'classId': 'class-10a1',
          'classCode': '10A1',
          'subjectId': 'math',
          'subjectName': 'Toán',
        },
        {
          'classId': 'class-10a2',
          'classCode': '10A2',
          'subjectId': 'math',
          'subjectName': 'Toán',
        },
      ],
    );

    expect(summary.homeroomLabel, '10A1');
    expect(summary.teachingLabel, 'Toán • 2 lớp');
  });
}
