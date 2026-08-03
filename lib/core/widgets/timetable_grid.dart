import 'dart:math' as math;

import 'package:flutter/material.dart';

const timetableDays = <(String, String)>[
  ('MON', 'Thứ 2'),
  ('TUE', 'Thứ 3'),
  ('WED', 'Thứ 4'),
  ('THU', 'Thứ 5'),
  ('FRI', 'Thứ 6'),
  ('SAT', 'Thứ 7'),
];

/// Bảng thời khóa biểu tuần theo phong cách Material tiêu chuẩn.
class TimetableGrid extends StatelessWidget {
  const TimetableGrid({
    super.key,
    required this.slots,
    required this.accent,
    this.dayFilter = 'ALL',
    this.onSlotTap,
    this.showTeacher = true,
    this.showClass = true,
  });

  final List<Map<String, dynamic>> slots;
  final Color accent;
  final String dayFilter;
  final ValueChanged<Map<String, dynamic>>? onSlotTap;
  final bool showTeacher;
  final bool showClass;

  @override
  Widget build(BuildContext context) {
    final visibleDays = dayFilter == 'ALL'
        ? timetableDays
        : timetableDays.where((day) => day.$1 == dayFilter).toList();
    final maxPeriod = math.max(
      6,
      slots.fold<int>(
        0,
        (value, slot) =>
            math.max(value, (slot['periodNo'] as num?)?.toInt() ?? 0),
      ),
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        final cellWidth = visibleDays.length == 1
            ? math.max(240.0, constraints.maxWidth - 70)
            : 158.0;
        final totalWidth = 68 + cellWidth * visibleDays.length;
        return Card(
          clipBehavior: Clip.antiAlias,
          child: Scrollbar(
            thumbVisibility: totalWidth > constraints.maxWidth,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: math.max(constraints.maxWidth, totalWidth),
                child: Table(
                  columnWidths: {
                    0: const FixedColumnWidth(68),
                    for (var i = 0; i < visibleDays.length; i++)
                      i + 1: FixedColumnWidth(
                        math.max(
                          cellWidth,
                          (constraints.maxWidth - 68) / visibleDays.length,
                        ),
                      ),
                  },
                  border: TableBorder(
                    horizontalInside: BorderSide(
                      color: Theme.of(context).dividerColor,
                    ),
                    verticalInside: BorderSide(
                      color: Theme.of(context).dividerColor,
                    ),
                  ),
                  children: [
                    TableRow(
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? const Color(0xFF1C2735)
                            : const Color(0xFFF0F3F7),
                      ),
                      children: [
                        const SizedBox(
                          height: 50,
                          child: Center(
                            child: Text(
                              'TIẾT',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                        ...visibleDays.map(
                          (day) => _DayHeader(
                            label: day.$2,
                            active: day.$1 == _todayCode(),
                            accent: accent,
                          ),
                        ),
                      ],
                    ),
                    for (var period = 1; period <= maxPeriod; period++)
                      TableRow(
                        children: [
                          _PeriodHeader(period: period, slots: slots),
                          ...visibleDays.map((day) {
                            final slot = slots
                                .where(
                                  (item) =>
                                      '${item['dayOfWeek']}' == day.$1 &&
                                      (item['periodNo'] as num?)?.toInt() ==
                                          period,
                                )
                                .firstOrNull;
                            return _ScheduleCell(
                              slot: slot,
                              accent: accent,
                              showTeacher: showTeacher,
                              showClass: showClass,
                              onTap: slot == null || onSlotTap == null
                                  ? null
                                  : () => onSlotTap!(slot),
                            );
                          }),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _DayHeader extends StatelessWidget {
  const _DayHeader({
    required this.label,
    required this.active,
    required this.accent,
  });

  final String label;
  final bool active;
  final Color accent;

  @override
  Widget build(BuildContext context) => Container(
    height: 50,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      border: active
          ? Border(bottom: BorderSide(color: accent, width: 3))
          : null,
    ),
    child: Text(
      label,
      style: TextStyle(
        color: active ? accent : null,
        fontWeight: FontWeight.w800,
      ),
    ),
  );
}

class _PeriodHeader extends StatelessWidget {
  const _PeriodHeader({required this.period, required this.slots});

  final int period;
  final List<Map<String, dynamic>> slots;

  @override
  Widget build(BuildContext context) {
    final match = slots
        .where((slot) => (slot['periodNo'] as num?)?.toInt() == period)
        .firstOrNull;
    final start = '${match?['startTime'] ?? ''}';
    return Container(
      height: 106,
      color: Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF17212E)
          : const Color(0xFFFAFBFC),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$period',
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
          ),
          if (start.isNotEmpty) ...[
            const SizedBox(height: 3),
            Text(
              start,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(fontSize: 10),
            ),
          ],
        ],
      ),
    );
  }
}

class _ScheduleCell extends StatelessWidget {
  const _ScheduleCell({
    required this.slot,
    required this.accent,
    required this.showTeacher,
    required this.showClass,
    this.onTap,
  });

  final Map<String, dynamic>? slot;
  final Color accent;
  final bool showTeacher;
  final bool showClass;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    if (slot == null) {
      return SizedBox(
        height: 106,
        child: Center(
          child: Text(
            '—',
            style: TextStyle(color: Theme.of(context).disabledColor),
          ),
        ),
      );
    }
    final subject = '${slot!['subjectName'] ?? 'Môn học'}';
    final color = _subjectColor(subject, accent);
    final classCode = '${slot!['classCode'] ?? ''}';
    final teacher = '${slot!['teacherName'] ?? ''}';
    final room = '${slot!['roomCode'] ?? '—'}';
    final time = '${slot!['startTime'] ?? ''}–${slot!['endTime'] ?? ''}';
    final content = Container(
      height: 106,
      padding: const EdgeInsets.fromLTRB(11, 10, 9, 9),
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: color, width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            subject,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: color, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 3),
          Text(
            time,
            maxLines: 1,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontSize: 10),
          ),
          const Spacer(),
          if (showClass && classCode.isNotEmpty)
            _MetaLine(icon: Icons.groups_2_outlined, text: 'Lớp $classCode'),
          if (showTeacher && teacher.isNotEmpty)
            _MetaLine(icon: Icons.person_outline, text: teacher),
          _MetaLine(icon: Icons.room_outlined, text: 'Phòng $room'),
        ],
      ),
    );
    if (onTap == null) return content;
    return Material(
      color: Colors.transparent,
      child: InkWell(onTap: onTap, child: content),
    );
  }
}

class _MetaLine extends StatelessWidget {
  const _MetaLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 1),
    child: Row(
      children: [
        Icon(
          icon,
          size: 11,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 3),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 9),
          ),
        ),
      ],
    ),
  );
}

Color _subjectColor(String subject, Color accent) {
  const palette = [
    Color(0xFF2457C5),
    Color(0xFF188066),
    Color(0xFF6B4DB5),
    Color(0xFFB66A24),
    Color(0xFFB94362),
    Color(0xFF277F9E),
  ];
  if (subject.isEmpty) return accent;
  final value = subject.codeUnits.fold<int>(0, (sum, item) => sum + item);
  return palette[value % palette.length];
}

String _todayCode() {
  const codes = ['', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
  return codes[DateTime.now().weekday];
}
