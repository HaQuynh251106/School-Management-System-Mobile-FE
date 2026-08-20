import 'package:flutter_test/flutter_test.dart';
import 'package:sse_mobile/features/parent/presentation/helpers/parent_overview_metrics.dart';

void main() {
  test('uses canonical grade summaries and live attendance records', () {
    final metrics = buildParentOverviewMetrics(
      gradeSummaries: const [
        {'average': 8.0},
        {'average': 9.0},
        {'average': null},
      ],
      attendance: const [
        {'status': 'PRESENT'},
        {'status': 'LATE'},
        {'status': 'ABSENT_EXCUSED'},
      ],
    );

    expect(metrics.averageScore, 8.5);
    expect(metrics.presentCount, 2);
    expect(metrics.absentCount, 1);
    expect(metrics.attendanceCount, 3);
  });

  test('does not turn missing backend data into zero-valued metrics', () {
    final metrics = buildParentOverviewMetrics(
      gradeSummaries: const [],
      attendance: const [],
    );

    expect(metrics.averageScore, isNull);
    expect(metrics.hasAttendance, isFalse);
  });
}
