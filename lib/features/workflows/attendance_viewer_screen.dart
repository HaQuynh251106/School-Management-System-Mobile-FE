import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/session.dart';

class AttendanceViewerScreen extends StatefulWidget {
  const AttendanceViewerScreen({super.key, required this.accent});
  final Color accent;

  @override
  State<AttendanceViewerScreen> createState() => _AttendanceViewerScreenState();
}

class _AttendanceViewerScreenState extends State<AttendanceViewerScreen> {
  late Future<List<Map<String, dynamic>>> future;
  String filter = 'ALL';

  bool get isParent => context.read<AppSession>().user?.role == 'PARENT';

  @override
  void initState() {
    super.initState();
    future = _load();
  }

  Future<List<Map<String, dynamic>>> _load() {
    final session = context.read<AppSession>();
    return session.api.list(
      '/attendance',
      query: {
        if (isParent && session.selectedChildId != null)
          'studentId': session.selectedChildId,
      },
    );
  }

  void _reload() => setState(() => future = _load());

  String _status(String value) => switch (value) {
    'PRESENT' => 'Có mặt',
    'LATE' => 'Đi muộn',
    'ABSENT_EXCUSED' => 'Vắng có phép',
    'ABSENT_UNEXCUSED' => 'Vắng không phép',
    _ => value,
  };

  Color _color(String value) => switch (value) {
    'PRESENT' => Colors.green,
    'LATE' => Colors.orange,
    'ABSENT_EXCUSED' => Colors.blue,
    _ => Colors.red,
  };

  @override
  Widget build(BuildContext context) {
    final session = context.watch<AppSession>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chuyên cần'),
        actions: [
          IconButton(
            onPressed: _reload,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
            child: Column(
              children: [
                if (isParent)
                  DropdownButtonFormField<String>(
                    key: ValueKey(session.selectedChildId),
                    initialValue: session.selectedChildId,
                    decoration: const InputDecoration(
                      labelText: 'Học sinh',
                      prefixIcon: Icon(Icons.family_restroom_outlined),
                    ),
                    items: session.children
                        .map(
                          (item) => DropdownMenuItem(
                            value: '${item['id']}',
                            child: Text('${item['fullName'] ?? item['name']}'),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      session.selectChild(value);
                      _reload();
                    },
                  ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 42,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      for (final item in const [
                        ('ALL', 'Tất cả'),
                        ('PRESENT', 'Có mặt'),
                        ('LATE', 'Đi muộn'),
                        ('ABSENT_EXCUSED', 'Vắng có phép'),
                        ('ABSENT_UNEXCUSED', 'Vắng không phép'),
                      ])
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(item.$2),
                            selected: filter == item.$1,
                            onSelected: (_) => setState(() => filter = item.$1),
                          ),
                        ),
                    ],
                  ),
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
                final items = filter == 'ALL'
                    ? all
                    : all
                          .where((item) => '${item['status']}' == filter)
                          .toList();
                if (items.isEmpty) {
                  return const Center(
                    child: Text('Không có bản ghi chuyên cần phù hợp.'),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final status = '${item['status']}';
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _color(
                            status,
                          ).withValues(alpha: .12),
                          child: Icon(
                            status == 'PRESENT'
                                ? Icons.check_rounded
                                : Icons.event_busy_outlined,
                            color: _color(status),
                          ),
                        ),
                        title: Text(
                          '${item['subjectName'] ?? 'Tiết ${item['periodNo'] ?? ''}'}',
                        ),
                        subtitle: Text(
                          '${item['date'] ?? item['attendanceDate'] ?? ''} · ${item['classCode'] ?? ''}'
                          '${item['note'] == null ? '' : '\n${item['note']}'}',
                        ),
                        trailing: Chip(label: Text(_status(status))),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
