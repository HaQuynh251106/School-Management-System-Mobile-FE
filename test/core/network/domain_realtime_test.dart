import 'package:flutter_test/flutter_test.dart';
import 'package:sse_mobile/core/network/domain_realtime.dart';
import 'package:sse_mobile/core/network/realtime_service.dart';

void main() {
  test('direct grade event invalidates only the grade domain', () {
    final domains = domainsForRealtimeEvent(
      const RealtimeEvent('GRADE_UPDATED', {'gradeId': 'g-1'}),
    );

    expect(domains, {MobileDataDomain.grades});
  });

  test('direct exam event invalidates the exam domain', () {
    final domains = domainsForRealtimeEvent(
      const RealtimeEvent('EXAM_UPDATED', {'examPeriodId': 'ep-1'}),
    );

    expect(domains, contains(MobileDataDomain.exams));
  });

  test('notification category invalidates inbox and referenced data', () {
    final domains = domainsForRealtimeEvent(
      const RealtimeEvent('NOTIFICATION', {
        'type': 'EXAM_REVIEW_RESOLVED',
        'refType': 'EXAM_RESULT',
      }),
    );

    expect(
      domains,
      containsAll({MobileDataDomain.notifications, MobileDataDomain.exams}),
    );
  });

  test('payment notification refreshes finance and notifications', () {
    final domains = domainsForRealtimeEvent(
      const RealtimeEvent('NOTIFICATION', {
        'type': 'PAYMENT_CONFIRMED',
        'refType': 'INVOICE',
      }),
    );

    expect(
      domains,
      containsAll({MobileDataDomain.notifications, MobileDataDomain.finance}),
    );
  });

  test('year-end notification refreshes the yearly result', () {
    final domains = domainsForRealtimeEvent(
      const RealtimeEvent('NOTIFICATION', {'type': 'YEAR_END'}),
    );

    expect(
      domains,
      containsAll({
        MobileDataDomain.notifications,
        MobileDataDomain.yearResult,
      }),
    );
  });
}
