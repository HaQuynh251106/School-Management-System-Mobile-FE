import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/session.dart';

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

  bool get isParent =>
      context.read<AppSession>().user?.role == 'PARENT';

  static const days = <(String, String)>[
    ('MON', 'Thứ 2'),
    ('TUE', 'Thứ 3'),
    ('WED', 'Thứ 4'),
    ('THU', 'Thứ 5'),
    ('FRI', 'Thứ 6'),
    ('SAT', 'Thứ 7'),
  ];

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
      final aDay = days.indexWhere((day) => day.$1 == '${a['dayOfWeek']}');
      final bDay = days.indexWhere((day) => day.$1 == '${b['dayOfWeek']}');
      final compare = aDay.compareTo(bDay);
      if (compare != 0) return compare;
      return (a['periodNo'] as num? ?? 0)
          .compareTo(b['periodNo'] as num? ?? 0);
    });
    return values;
  }

  void _reload() => setState(() => future = _load());

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(widget.title),
      actions: [
        IconButton(onPressed: _reload, icon: const Icon(Icons.refresh_rounded)),
      ],
    ),
    body: Column(
      children: [
        if (isParent)
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
            child: DropdownButtonFormField<String>(
              key: ValueKey(
                context.watch<AppSession>().selectedChildId,
              ),
              initialValue:
                  context.watch<AppSession>().selectedChildId,
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
        SizedBox(
          height: 58,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            children: [
              ChoiceChip(
                label: const Text('Cả tuần'),
                selected: selectedDay == 'ALL',
                onSelected: (_) => setState(() => selectedDay = 'ALL'),
              ),
              const SizedBox(width: 8),
              ...days.expand(
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
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: future,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('${snapshot.error}'));
              }
              final all = snapshot.data ?? [];
              final items = selectedDay == 'ALL'
                  ? all
                  : all
                        .where(
                          (item) =>
                              '${item['dayOfWeek']}' == selectedDay,
                        )
                        .toList();
              if (items.isEmpty) {
                return const Center(
                  child: Text('Không có tiết học trong thời gian đã chọn.'),
                );
              }
              return RefreshIndicator(
                onRefresh: () async => _reload(),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                  children: days.map((day) {
                    final dayItems = items
                        .where(
                          (item) => '${item['dayOfWeek']}' == day.$1,
                        )
                        .toList();
                    if (dayItems.isEmpty) return const SizedBox.shrink();
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              day.$2,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const Divider(),
                            ...dayItems.map(
                              (item) => ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: CircleAvatar(
                                  backgroundColor:
                                      widget.accent.withValues(alpha: .1),
                                  child: Text(
                                    '${item['periodNo']}',
                                    style: TextStyle(
                                      color: widget.accent,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  '${item['subjectName'] ?? 'Môn học'}',
                                ),
                                subtitle: Text(
                                  '${item['startTime']}–${item['endTime']} · Lớp ${item['classCode'] ?? '—'}\n${item['teacherName'] ?? ''} · Phòng ${item['roomCode'] ?? '—'}',
                                ),
                                isThreeLine: true,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          ),
        ),
      ],
    ),
  );
}
