import 'package:flutter/material.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/section_header.dart';

class AdminClassDetail extends StatefulWidget {
  const AdminClassDetail({
    super.key,
    required this.classId,
    required this.className,
    required this.gradeName,
    required this.homeroom,
    required this.studentCount,
  });

  final String classId;
  final String className;
  final String gradeName;
  final String homeroom;
  final int studentCount;

  @override
  State<AdminClassDetail> createState() => _AdminClassDetailState();
}

class _AdminClassDetailState extends State<AdminClassDetail> {
  late Future<List<List<Map<String, dynamic>>>> _future = _load();

  Future<List<List<Map<String, dynamic>>>> _load() => Future.wait([
        sl<ApiService>().classStudents(widget.classId),
        sl<ApiService>().teachingAssignments(classId: widget.classId),
        sl<ApiService>().timetableOfClass(widget.classId),
      ]);

  void _reload() => setState(() => _future = _load());

  @override
  Widget build(BuildContext context) => DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            title: Text('Lớp ${widget.className}'),
            backgroundColor: AppColors.adminAccent,
            actions: [
              IconButton(
                onPressed: _reload,
                icon: const Icon(Icons.refresh_rounded),
                tooltip: 'Tải lại',
              ),
            ],
            bottom: const TabBar(
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white60,
              indicatorColor: Colors.white,
              tabs: [
                Tab(text: 'Thông tin'),
                Tab(text: 'Học sinh'),
                Tab(text: 'TKB'),
              ],
            ),
          ),
          body: FutureBuilder<List<List<Map<String, dynamic>>>>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return _ErrorState(onRetry: _reload);
              }
              final batches = snapshot.data!;
              return TabBarView(children: [
                _InfoTab(
                  className: widget.className,
                  gradeName: widget.gradeName,
                  homeroom: widget.homeroom,
                  students: batches[0],
                  assignments: batches[1],
                  slots: batches[2],
                ),
                _StudentsTab(students: batches[0]),
                _TimetableTab(slots: batches[2]),
              ]);
            },
          ),
        ),
      );
}

class _InfoTab extends StatelessWidget {
  const _InfoTab({
    required this.className,
    required this.gradeName,
    required this.homeroom,
    required this.students,
    required this.assignments,
    required this.slots,
  });
  final String className;
  final String gradeName;
  final String homeroom;
  final List<Map<String, dynamic>> students;
  final List<Map<String, dynamic>> assignments;
  final List<Map<String, dynamic>> slots;

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.adminAccent, Color(0xFF3949AB)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(className,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text(gradeName, style: const TextStyle(color: Colors.white70)),
              Text(
                homeroom.trim().isEmpty
                    ? 'Chưa phân công giáo viên chủ nhiệm'
                    : 'GVCN: $homeroom',
                style: const TextStyle(color: Colors.white70),
              ),
            ]),
          ),
          const SizedBox(height: 18),
          const SectionHeader(title: 'Dữ liệu hiện tại'),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(
                child: _CountCard(label: 'Học sinh', value: students.length)),
            const SizedBox(width: 8),
            Expanded(
                child: _CountCard(
                    label: 'Môn đã phân công', value: assignments.length)),
            const SizedBox(width: 8),
            Expanded(
                child:
                    _CountCard(label: 'Tiết đã công bố', value: slots.length)),
          ]),
          const SizedBox(height: 18),
          const SectionHeader(title: 'Giáo viên bộ môn'),
          const SizedBox(height: 8),
          if (assignments.isEmpty)
            const _EmptyState(text: 'Chưa có phân công giảng dạy')
          else
            Card(
              child: Column(
                children: [
                  for (var index = 0; index < assignments.length; index++) ...[
                    ListTile(
                      leading: const Icon(Icons.menu_book_outlined,
                          color: AppColors.teacherAccent),
                      title: Text(
                          '${assignments[index]['subjectName'] ?? 'Môn học'}'),
                      subtitle: Text(
                          '${assignments[index]['teacherName'] ?? 'Chưa có giáo viên'}'),
                    ),
                    if (index < assignments.length - 1)
                      const Divider(height: 0),
                  ],
                ],
              ),
            ),
        ],
      );
}

class _StudentsTab extends StatefulWidget {
  const _StudentsTab({required this.students});
  final List<Map<String, dynamic>> students;

  @override
  State<_StudentsTab> createState() => _StudentsTabState();
}

class _StudentsTabState extends State<_StudentsTab> {
  String query = '';

  @override
  Widget build(BuildContext context) {
    final students = widget.students.where((student) {
      final term = query.trim().toLowerCase();
      if (term.isEmpty) return true;
      return '${student['fullName'] ?? ''}'.toLowerCase().contains(term) ||
          '${student['studentCode'] ?? ''}'.toLowerCase().contains(term);
    }).toList();
    return Column(children: [
      Padding(
        padding: const EdgeInsets.all(12),
        child: TextField(
          onChanged: (value) => setState(() => query = value),
          decoration: const InputDecoration(
            hintText: 'Tìm theo tên hoặc mã học sinh',
            prefixIcon: Icon(Icons.search_rounded),
          ),
        ),
      ),
      Expanded(
        child: students.isEmpty
            ? const _EmptyState(text: 'Không có học sinh phù hợp')
            : ListView.separated(
                itemCount: students.length,
                separatorBuilder: (_, __) => const Divider(height: 0),
                itemBuilder: (context, index) {
                  final student = students[index];
                  return ListTile(
                    leading: CircleAvatar(child: Text('${index + 1}')),
                    title: Text('${student['fullName'] ?? ''}'),
                    subtitle: Text('${student['studentCode'] ?? ''}'),
                  );
                },
              ),
      ),
    ]);
  }
}

class _TimetableTab extends StatelessWidget {
  const _TimetableTab({required this.slots});
  final List<Map<String, dynamic>> slots;

  static const labels = {
    'MON': 'Thứ Hai',
    'TUE': 'Thứ Ba',
    'WED': 'Thứ Tư',
    'THU': 'Thứ Năm',
    'FRI': 'Thứ Sáu',
    'SAT': 'Thứ Bảy',
  };

  @override
  Widget build(BuildContext context) {
    if (slots.isEmpty) {
      return const _EmptyState(text: 'Chưa có thời khóa biểu được công bố');
    }
    final sorted = [...slots]..sort((a, b) {
        final day = labels.keys.toList();
        final byDay = day
            .indexOf('${a['dayOfWeek']}')
            .compareTo(day.indexOf('${b['dayOfWeek']}'));
        return byDay != 0
            ? byDay
            : ((a['periodNo'] as num?)?.toInt() ?? 0)
                .compareTo((b['periodNo'] as num?)?.toInt() ?? 0);
      });
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sorted.length,
      itemBuilder: (context, index) {
        final slot = sorted[index];
        return Card(
          child: ListTile(
            leading: CircleAvatar(child: Text('${slot['periodNo'] ?? '—'}')),
            title: Text('${slot['subjectName'] ?? 'Môn học'}'),
            subtitle: Text(
              '${labels['${slot['dayOfWeek']}'] ?? slot['dayOfWeek']} · '
              '${slot['startTime'] ?? ''}–${slot['endTime'] ?? ''}\n'
              '${slot['teacherName'] ?? 'Chưa có giáo viên'} · ${slot['roomCode'] ?? 'Chưa có phòng'}',
            ),
            isThreeLine: true,
          ),
        );
      },
    );
  }
}

class _CountCard extends StatelessWidget {
  const _CountCard({required this.label, required this.value});
  final String label;
  final int value;

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
          child: Column(children: [
            Text('$value', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(label,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall),
          ]),
        ),
      );
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(text,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant)),
        ),
      );
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('Không thể tải dữ liệu lớp học'),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Thử lại'),
          ),
        ]),
      );
}
