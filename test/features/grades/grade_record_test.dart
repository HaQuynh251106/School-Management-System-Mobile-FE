import 'package:flutter_test/flutter_test.dart';
import 'package:sse_mobile/features/grades/data/grade_record.dart';

void main() {
  test('keeps multiple assessment indexes in the same category', () {
    final first = GradeRecord.fromJson({
      'id': 'g-1',
      'studentId': 'student-1',
      'subjectId': 'math',
      'subjectName': 'Toán',
      'semesterId': 'hk1',
      'category': '15M',
      'categoryName': '15 phút',
      'assessmentIndex': 1,
      'score': 7,
      'version': 2,
    });
    final second = GradeRecord.fromJson({
      'id': 'g-2',
      'studentId': 'student-1',
      'subjectId': 'math',
      'subjectName': 'Toán',
      'semesterId': 'hk1',
      'category': '15M',
      'categoryName': '15 phút',
      'assessmentIndex': 2,
      'score': 8.5,
      'version': 4,
    });

    final byKey = {first.key: first, second.key: second};
    expect(byKey, hasLength(2));
    expect(byKey['15M#1']!.score, 7);
    expect(byKey['15M#2']!.score, 8.5);
    expect(byKey['15M#2']!.version, 4);
  });

  test('groups grade rows without losing id version or assessment index', () {
    final grouped = groupGradeRecordsByStudent([
      {
        'id': 'g-1',
        'studentId': 'student-1',
        'subjectId': 'math',
        'subjectName': 'Toán',
        'semesterId': 'hk1',
        'category': '15M',
        'categoryName': '15 phút',
        'assessmentIndex': 1,
        'score': 9,
        'version': 2,
      },
      {
        'id': 'g-2',
        'studentId': 'student-1',
        'subjectId': 'math',
        'subjectName': 'Toán',
        'semesterId': 'hk1',
        'category': '15M',
        'categoryName': '15 phút',
        'assessmentIndex': 2,
        'score': 8,
        'version': 5,
      },
    ]);

    expect(grouped['student-1'], hasLength(2));
    expect(grouped['student-1']!['15M#1']!.id, 'g-1');
    expect(grouped['student-1']!['15M#1']!.version, 2);
    expect(grouped['student-1']!['15M#2']!.id, 'g-2');
    expect(grouped['student-1']!['15M#2']!.assessmentIndex, 2);
  });

  test(
    'update payload carries expectedVersion while create payload does not',
    () {
      const existing = GradeRecord(
        id: 'g-1',
        studentId: 'student-1',
        subjectId: 'math',
        subjectName: 'Toán',
        semesterId: 'hk1',
        category: '15M',
        categoryName: '15 phút',
        assessmentIndex: 2,
        score: 9,
        version: 7,
        recordedAt: null,
        note: 'Đã đối chiếu',
      );

      final update = buildGradeEntryPayload(
        studentId: 'student-1',
        score: 9.1,
        existing: existing,
      );
      final create = buildGradeEntryPayload(studentId: 'student-1', score: 8.5);

      expect(update, {
        'studentId': 'student-1',
        'score': 9.1,
        'note': 'Đã đối chiếu',
        'expectedVersion': 7,
      });
      expect(create, {'studentId': 'student-1', 'score': 8.5});
    },
  );

  test(
    'builds every configured grade column and calculates only when complete',
    () {
      final columns = buildGradeColumns(const [
        GradeCategoryDefinition(
          code: '15M',
          name: '15 phút',
          weight: 1,
          requiredCount: 2,
        ),
        GradeCategoryDefinition(
          code: 'FINAL',
          name: 'Cuối kỳ',
          weight: 3,
          requiredCount: 1,
        ),
      ]);
      expect(columns.map((column) => column.key), [
        '15M#1',
        '15M#2',
        'FINAL#1',
      ]);

      GradeRecord record(String id, String category, int index, double score) =>
          GradeRecord(
            id: id,
            studentId: 'student-1',
            subjectId: 'math',
            subjectName: 'Toán',
            semesterId: 'hk1',
            category: category,
            categoryName: category,
            assessmentIndex: index,
            score: score,
            version: 0,
            recordedAt: null,
            note: null,
          );

      final incomplete = {
        '15M#1': record('g-1', '15M', 1, 7),
        'FINAL#1': record('g-3', 'FINAL', 1, 9),
      };
      expect(completeWeightedAverage(incomplete, columns), isNull);

      final complete = {...incomplete, '15M#2': record('g-2', '15M', 2, 8)};
      expect(completeWeightedAverage(complete, columns), closeTo(8.4, 0.0001));
    },
  );

  test('reads the canonical average returned by the backend', () {
    final summary = GradeSubjectSummary.fromJson({
      'studentId': 'student-1',
      'subjectId': 'math',
      'subjectName': 'Toán',
      'semesterId': 'hk1',
      'average': 7.9,
      'complete': true,
      'missingAssessmentKeys': <String>[],
    });

    expect(summary.key, 'math|hk1');
    expect(summary.average, 7.9);
    expect(summary.complete, isTrue);
  });

  test('student subject selection keeps ids and canonical backend summary', () {
    final selections = buildSubjectGradeSelections(
      gradeRows: [
        {
          'id': 'g-1',
          'studentId': 'student-1',
          'subjectId': 'math',
          'subjectName': 'Toán',
          'semesterId': 'hk1',
          'category': '15M',
          'categoryName': '15 phút',
          'assessmentIndex': 1,
          'score': 9,
          'version': 3,
        },
      ],
      summaryRows: [
        {
          'studentId': 'student-1',
          'subjectId': 'math',
          'subjectName': 'Toán',
          'semesterId': 'hk1',
          'average': 8.25,
          'complete': true,
          'missingAssessmentKeys': <String>[],
        },
      ],
    );

    expect(selections, hasLength(1));
    expect(selections.single.subjectId, 'math');
    expect(selections.single.semesterId, 'hk1');
    expect(selections.single.average, 8.25);
    expect(selections.single.complete, isTrue);
  });

  test('parent subject selection retains real records for detail screen', () {
    final selections = buildSubjectGradeSelections(
      gradeRows: [
        {
          'id': 'g-1',
          'studentId': 'student-1',
          'subjectId': 'math',
          'subjectName': 'Toán',
          'semesterId': 'hk2',
          'category': '15M',
          'categoryName': '15 phút',
          'assessmentIndex': 1,
          'score': 7.5,
          'version': 1,
        },
        {
          'id': 'g-2',
          'studentId': 'student-1',
          'subjectId': 'math',
          'subjectName': 'Toán',
          'semesterId': 'hk2',
          'category': '15M',
          'categoryName': '15 phút',
          'assessmentIndex': 2,
          'score': 8.5,
          'version': 2,
        },
      ],
      summaryRows: const [],
    );

    final records = selections.single.records;
    expect(records, hasLength(2));
    expect(records['15M#1']!.id, 'g-1');
    expect(records['15M#2']!.id, 'g-2');
    expect(selections.single.subjectId, 'math');
    expect(selections.single.semesterId, 'hk2');
  });
}
