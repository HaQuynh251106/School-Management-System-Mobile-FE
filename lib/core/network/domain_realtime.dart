import 'dart:async';

import 'realtime_service.dart';

enum MobileDataDomain {
  timetable,
  attendance,
  grades,
  assignments,
  exams,
  finance,
  notifications,
  chat,
  educationPlan,
  yearResult,
  clubs,
}

Set<MobileDataDomain> domainsForRealtimeEvent(RealtimeEvent event) {
  final type = event.type.trim().toUpperCase();
  final resource = '${event.data['resource'] ?? ''}'.trim().toUpperCase();
  final notificationType = '${event.data['type'] ?? ''}'.trim().toUpperCase();
  final refType = '${event.data['refType'] ?? ''}'.trim().toUpperCase();
  final tokens = '$type $resource $notificationType $refType';

  final domains = <MobileDataDomain>{};
  if (type == 'NOTIFICATION') domains.add(MobileDataDomain.notifications);
  if (tokens.contains('TIMETABLE') || tokens.contains('SCHEDULE')) {
    domains.add(MobileDataDomain.timetable);
  }
  if (tokens.contains('ATTENDANCE') || tokens.contains('LEAVE')) {
    domains.add(MobileDataDomain.attendance);
  }
  if (tokens.contains('GRADE') && !tokens.contains('EXAM')) {
    domains.add(MobileDataDomain.grades);
  }
  if (tokens.contains('ASSIGNMENT') || tokens.contains('SUBMISSION')) {
    domains.add(MobileDataDomain.assignments);
  }
  if (tokens.contains('EXAM')) domains.add(MobileDataDomain.exams);
  if (tokens.contains('PAYMENT') ||
      tokens.contains('INVOICE') ||
      tokens.contains('FINANCE')) {
    domains.add(MobileDataDomain.finance);
  }
  if (tokens.contains('CHAT') || tokens.contains('MESSAGE')) {
    domains.add(MobileDataDomain.chat);
  }
  if (tokens.contains('EDUCATION_PLAN') || tokens.contains('ACADEMIC_PLAN')) {
    domains.add(MobileDataDomain.educationPlan);
  }
  if (tokens.contains('YEAR_RESULT') ||
      tokens.contains('YEARLY_SUMMARY') ||
      tokens.contains('YEAR_END')) {
    domains.add(MobileDataDomain.yearResult);
  }
  if (tokens.contains('CLUB') || tokens.contains('EXTRACURRICULAR')) {
    domains.add(MobileDataDomain.clubs);
  }
  return domains;
}

bool realtimeEventAffects(
  RealtimeEvent event,
  Set<MobileDataDomain> watchedDomains,
) => domainsForRealtimeEvent(event).any(watchedDomains.contains);

class DomainRealtimeSubscription {
  DomainRealtimeSubscription._();

  late final StreamSubscription<RealtimeEvent> _subscription;
  Timer? _debounce;

  static DomainRealtimeSubscription listen({
    required RealtimeService realtime,
    required Set<MobileDataDomain> domains,
    required void Function() onInvalidate,
    Duration debounce = const Duration(milliseconds: 250),
  }) {
    realtime.connect();
    final result = DomainRealtimeSubscription._();
    result._subscription = realtime.events
        .where((event) => realtimeEventAffects(event, domains))
        .listen((_) {
          result._debounce?.cancel();
          result._debounce = Timer(debounce, onInvalidate);
        });
    return result;
  }

  Future<void> dispose() async {
    _debounce?.cancel();
    await _subscription.cancel();
  }
}
