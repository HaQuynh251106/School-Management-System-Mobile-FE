import 'package:flutter_test/flutter_test.dart';
import 'package:sse_mobile/features/admin/presentation/pages/class_detail.dart';

void main() {
  group('ClassOverviewMetrics', () {
    test('tính điểm trung bình và chuyên cần từ dữ liệu thật', () {
      final metrics = ClassOverviewMetrics.fromRaw(
        grades: [
          {'score': 8},
          {'score': 7.5},
          {'score': null},
        ],
        attendance: [
          {'status': 'PRESENT'},
          {'status': 'LATE'},
          {'status': 'ABSENT_UNEXCUSED'},
          {'status': 'ABSENT_EXCUSED'},
        ],
        assignments: const [],
      );

      expect(metrics.averageScoreLabel, '7.8');
      expect(metrics.attendanceRateLabel, '50%');
      expect(metrics.unexcusedCount, 1);
    });

    test('hiển thị gạch ngang khi chưa có điểm và chuyên cần', () {
      final metrics = ClassOverviewMetrics.fromRaw(
        grades: const [],
        attendance: const [],
        assignments: const [],
      );

      expect(metrics.averageScoreLabel, '—');
      expect(metrics.attendanceRateLabel, '—');
      expect(metrics.unexcusedCount, 0);
    });
  });
}
