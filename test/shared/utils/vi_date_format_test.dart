import 'package:flutter_test/flutter_test.dart';
import 'package:sse_mobile/shared/utils/vi_date_format.dart';

void main() {
  test('formats date-only and UTC API values for Vietnamese users', () {
    expect(formatViDate('2026-08-13'), '13/08/2026');
    expect(formatViDateTime('2026-08-13T08:30:00Z'), contains('13/08/2026'));
  });

  test('preserves invalid labels and provides a fallback for empty values', () {
    expect(formatViDate('Chưa chốt'), 'Chưa chốt');
    expect(formatViDate(null), '—');
    expect(formatViDateRange(null, null), '—');
  });

  test('formats a complete date range', () {
    expect(
      formatViDateRange('2026-08-17', '2027-05-31'),
      '17/08/2026 – 31/05/2027',
    );
  });
}
