import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/network/api_service.dart';

class SchoolDayStatus {
  const SchoolDayStatus({
    required this.date,
    required this.attendanceRequired,
    this.title,
    this.reason,
    this.holidayStartDate,
    this.holidayEndDate,
  });

  final DateTime date;
  final bool attendanceRequired;
  final String? title;
  final String? reason;
  final DateTime? holidayStartDate;
  final DateTime? holidayEndDate;

  bool get isHoliday => !attendanceRequired;

  factory SchoolDayStatus.fromJson(DateTime date, Map<String, dynamic> json) =>
      SchoolDayStatus(
        date: date,
        attendanceRequired: json['attendanceRequired'] != false,
        title: json['title']?.toString(),
        reason: json['reason']?.toString(),
        holidayStartDate: DateTime.tryParse(
          json['holidayStartDate']?.toString() ?? '',
        ),
        holidayEndDate: DateTime.tryParse(
          json['holidayEndDate']?.toString() ?? '',
        ),
      );

  factory SchoolDayStatus.regular(DateTime date) =>
      SchoolDayStatus(date: date, attendanceRequired: true);
}

List<DateTime> schoolWeekDates(DateTime reference, {int dayCount = 6}) {
  final date = DateTime(reference.year, reference.month, reference.day);
  final monday = date.subtract(Duration(days: date.weekday - DateTime.monday));
  return List.generate(dayCount, (index) => monday.add(Duration(days: index)));
}

Future<SchoolDayStatus> loadSchoolDayStatus(
  ApiService api,
  DateTime date,
) async {
  try {
    final json = await api.attendanceDayStatus(date);
    return SchoolDayStatus.fromJson(date, json);
  } catch (_) {
    // A day-status outage must not hide the normal timetable.
    return SchoolDayStatus.regular(date);
  }
}

Future<List<SchoolDayStatus>> loadSchoolWeekStatuses(
  ApiService api,
  List<DateTime> dates,
) => Future.wait(dates.map((date) => loadSchoolDayStatus(api, date)));

class SchoolHolidayBanner extends StatelessWidget {
  const SchoolHolidayBanner({
    super.key,
    required this.status,
    required this.accent,
  });

  final SchoolDayStatus status;
  final Color accent;

  String get _dateLabel {
    final format = DateFormat('dd/MM/yyyy');
    final start = status.holidayStartDate ?? status.date;
    final end = status.holidayEndDate ?? start;
    if (DateUtils.isSameDay(start, end)) return format.format(start);
    return '${format.format(start)} - ${format.format(end)}';
  }

  @override
  Widget build(BuildContext context) {
    if (!status.isHoliday) return const SizedBox.shrink();
    final title = status.title?.trim();
    final reason = status.reason?.trim();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: accent.withValues(alpha: 0.28)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.event_busy_rounded, color: accent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nghỉ toàn trường',
                  style: TextStyle(
                    color: accent,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  title?.isNotEmpty == true ? title! : 'Ngày nghỉ học',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(_dateLabel, style: const TextStyle(fontSize: 12)),
                if (reason?.isNotEmpty == true) ...[
                  const SizedBox(height: 6),
                  Text(
                    reason!,
                    style: const TextStyle(fontSize: 13, height: 1.35),
                  ),
                ],
                const SizedBox(height: 6),
                const Text(
                  'Không xếp tiết học và không yêu cầu điểm danh trong thời gian này.',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
