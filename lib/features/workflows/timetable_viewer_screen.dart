import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/session.dart';
import '../../core/widgets/async_state_view.dart';
import '../../core/widgets/timetable_grid.dart';

class TimetableViewerScreen extends StatefulWidget {
  const TimetableViewerScreen({
    super.key,
    required this.title,
    required this.accent,
  });

  final String title;
  final Color accent;

  @override
  State<TimetableViewerScreen> createState() => _TimetableViewerScreenState();
}

class _TimetableViewerScreenState extends State<TimetableViewerScreen> {
  late Future<List<Map<String, dynamic>>> future;
  String selectedDay = 'ALL';

  bool get isParent => context.read<AppSession>().user?.role == 'PARENT';

  @override
  void initState() {
    super.initState();
    future = _load();
  }

  Future<List<Map<String, dynamic>>> _load() async {
    final session = context.read<AppSession>();
    final child = session.children.where(
      (item) => '${item['id']}' == session.selectedChildId,
    );
    final values = isParent
        ? child.isEmpty || child.first['classId'] == null
              ? <Map<String, dynamic>>[]
              : await session.api.list(
                  '/timetableSlots',
                  query: {'classId': child.first['classId']},
                )
        : await session.api.list('/me/timetable');
    values.sort((a, b) {
      final aDay = timetableDays.indexWhere(
        (day) => day.$1 == '${a['dayOfWeek']}',
      );
      final bDay = timetableDays.indexWhere(
        (day) => day.$1 == '${b['dayOfWeek']}',
      );
      final compare = aDay.compareTo(bDay);
      if (compare != 0) return compare;
      return (a['periodNo'] as num? ?? 0).compareTo(b['periodNo'] as num? ?? 0);
    });
    return values;
  }

  void _reload() => setState(() => future = _load());

  void _showSlot(Map<String, dynamic> slot) => showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (context) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 4, 22, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: widget.accent.withValues(alpha: .13),
                    borderRadius: BorderRadius.circular(17),
                  ),
                  child: Icon(Icons.menu_book_rounded, color: widget.accent),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${slot['subjectName'] ?? 'Môn học'}',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        'Tiết ${slot['periodNo']} · ${slot['startTime']}–${slot['endTime']}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _DetailLine(
              icon: Icons.groups_2_outlined,
              label: 'Lớp học',
              value: '${slot['classCode'] ?? '—'}',
            ),
            _DetailLine(
              icon: Icons.person_outline_rounded,
              label: 'Giáo viên',
              value: '${slot['teacherName'] ?? '—'}',
            ),
            _DetailLine(
              icon: Icons.room_outlined,
              label: 'Phòng học',
              value: '${slot['roomCode'] ?? '—'}',
            ),
          ],
        ),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(widget.title),
      actions: [
        IconButton(onPressed: _reload, icon: const Icon(Icons.refresh_rounded)),
      ],
    ),
    body: Padding(
      padding: const EdgeInsets.fromLTRB(14, 4, 14, 18),
      child: Column(
        children: [
          if (isParent)
            Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: DropdownButtonFormField<String>(
                  key: ValueKey(context.watch<AppSession>().selectedChildId),
                  initialValue: context.watch<AppSession>().selectedChildId,
                  decoration: const InputDecoration(
                    labelText: 'Học sinh',
                    prefixIcon: Icon(Icons.family_restroom_outlined),
                  ),
                  items: context
                      .watch<AppSession>()
                      .children
                      .map(
                        (item) => DropdownMenuItem(
                          value: '${item['id']}',
                          child: Text('${item['fullName'] ?? item['name']}'),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    context.read<AppSession>().selectChild(value);
                    _reload();
                  },
                ),
              ),
            ),
          SizedBox(
            height: 58,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(vertical: 7),
              children: [
                ChoiceChip(
                  avatar: const Icon(Icons.view_week_outlined, size: 17),
                  label: const Text('Cả tuần'),
                  selected: selectedDay == 'ALL',
                  onSelected: (_) => setState(() => selectedDay = 'ALL'),
                ),
                const SizedBox(width: 8),
                ...timetableDays.expand(
                  (day) => [
                    ChoiceChip(
                      label: Text(day.$2),
                      selected: selectedDay == day.$1,
                      onSelected: (_) => setState(() => selectedDay = day.$1),
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: AsyncStateView<List<Map<String, dynamic>>>(
              future: future,
              onRetry: _reload,
              builder: (context, all) {
                final hasVisibleSlots =
                    selectedDay == 'ALL' ||
                    all.any((item) => '${item['dayOfWeek']}' == selectedDay);
                if (all.isEmpty || !hasVisibleSlots) {
                  return const EmptyState(
                    title: 'Chưa có tiết học',
                    message: 'Không có tiết học trong thời gian đã chọn.',
                    icon: Icons.event_available_outlined,
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async => _reload(),
                  child: ListView(
                    padding: const EdgeInsets.only(bottom: 22),
                    children: [
                      _TimetableSummary(
                        slots: all,
                        accent: widget.accent,
                        isParent: isParent,
                      ),
                      const SizedBox(height: 12),
                      TimetableGrid(
                        slots: all,
                        accent: widget.accent,
                        dayFilter: selectedDay,
                        onSlotTap: _showSlot,
                        showTeacher: isParent,
                        showClass: !isParent,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    ),
  );
}

class _TimetableSummary extends StatelessWidget {
  const _TimetableSummary({
    required this.slots,
    required this.accent,
    required this.isParent,
  });

  final List<Map<String, dynamic>> slots;
  final Color accent;
  final bool isParent;

  @override
  Widget build(BuildContext context) {
    final morning = slots.where((item) {
      final hour = int.tryParse('${item['startTime']}'.split(':').first) ?? 0;
      return hour < 12;
    }).length;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: .14),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.grid_view_rounded, color: accent),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Lịch học dạng lưới',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    '${slots.length} tiết · $morning ca sáng · ${slots.length - morning} ca chiều',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            if (!isParent)
              const Chip(
                avatar: Icon(Icons.swipe_rounded, size: 16),
                label: Text('Vuốt ngang'),
              ),
          ],
        ),
      ),
    );
  }
}

class _DetailLine extends StatelessWidget {
  const _DetailLine({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: Icon(icon),
    title: Text(label),
    trailing: Text(
      value,
      textAlign: TextAlign.right,
      style: const TextStyle(fontWeight: FontWeight.w800),
    ),
  );
}
