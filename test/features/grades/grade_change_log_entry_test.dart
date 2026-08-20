import 'package:flutter_test/flutter_test.dart';
import 'package:sse_mobile/features/grades/data/grade_change_log_entry.dart';

void main() {
  test('maps real per-grade logs with student metadata and newest first', () {
    final entries = buildGradeChangeLogEntries(
      grades: [
        {
          'id': 'g-1',
          'studentId': 'student-1',
          'subjectName': 'Toán',
          'category': '15M',
          'categoryName': '15 phút',
        },
      ],
      logsByGrade: {
        'g-1': [
          {
            'id': 'log-old',
            'gradeId': 'g-1',
            'action': 'CREATE',
            'newScore': 9,
            'changedAt': '2026-08-12T08:00:00Z',
          },
          {
            'id': 'log-new',
            'gradeId': 'g-1',
            'action': 'UPDATE',
            'oldScore': 9,
            'newScore': 9.1,
            'reason': 'Chấm lại bài',
            'changedAt': '2026-08-12T09:00:00Z',
          },
        ],
      },
      studentNames: const {'student-1': 'Nguyễn Minh An'},
    );

    expect(entries, hasLength(2));
    expect(entries.first.id, 'log-new');
    expect(entries.first.studentName, 'Nguyễn Minh An');
    expect(entries.first.subjectCategoryLabel, 'Toán — 15 phút');
    expect(entries.first.oldScore, 9);
    expect(entries.first.newScore, 9.1);
    expect(entries.first.reason, 'Chấm lại bài');
  });

  test('does not invent entries for logs outside the fetched grade scope', () {
    final entries = buildGradeChangeLogEntries(
      grades: const [],
      logsByGrade: const {
        'g-outside': [
          {'id': 'log-1', 'gradeId': 'g-outside', 'newScore': 8},
        ],
      },
      studentNames: const {},
    );

    expect(entries, isEmpty);
  });
}
