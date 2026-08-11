import 'package:flutter/material.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/section_header.dart';

class AdminClassDetail extends StatelessWidget {
  const AdminClassDetail({
    super.key,
    required this.className,
    required this.gradeName,
    required this.homeroom,
    required this.studentCount,
  });

  final String className;
  final String gradeName;
  final String homeroom;
  final int studentCount;

  @override
  Widget build(BuildContext context) {
    final title = className.trim().toLowerCase().startsWith('lớp ')
        ? className.trim()
        : 'Lớp ${className.trim()}';
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(title),
          backgroundColor: AppColors.adminAccent,
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
        body: TabBarView(
          children: [
            _InfoTab(
              className: className,
              gradeName: gradeName,
              homeroom: homeroom,
              studentCount: studentCount,
            ),
            _StudentsTab(className: className),
            const _TimetableSummaryTab(),
          ],
        ),
      ),
    );
  }
}

class _InfoTab extends StatelessWidget {
  const _InfoTab({
    required this.className,
    required this.gradeName,
    required this.homeroom,
    required this.studentCount,
  });
  final String className;
  final String gradeName;
  final String homeroom;
  final int studentCount;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.adminAccent, Color(0xFF3949AB)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    className,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      gradeName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'GVCN: $homeroom',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: Colors.white70),
                    ),
                    Text(
                      'Sĩ số: $studentCount HS',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const SectionHeader(title: 'Thống kê'),
        const SizedBox(height: 10),
        const Row(
          children: [
            Expanded(
                child: _StatCard(
                    label: 'TB lớp', value: '7.8', color: AppColors.success)),
            SizedBox(width: 10),
            Expanded(
                child: _StatCard(
                    label: 'Tỉ lệ CC', value: '94%', color: AppColors.primary)),
            SizedBox(width: 10),
            Expanded(
                child: _StatCard(
                    label: 'Vắng KP', value: '3', color: AppColors.error)),
          ],
        ),
        const SizedBox(height: 20),
        const SectionHeader(title: 'GV bộ môn'),
        const SizedBox(height: 8),
        const Card(
          child: Column(
            children: [
              ListTile(
                leading: Icon(Icons.functions_rounded,
                    color: AppColors.teacherAccent),
                title: Text('Toán'),
                subtitle: Text('Trần Thị Hoa'),
              ),
              Divider(height: 0),
              ListTile(
                leading: Icon(Icons.science_outlined,
                    color: AppColors.teacherAccent),
                title: Text('Vật lý'),
                subtitle: Text('Lê Văn Minh'),
              ),
              Divider(height: 0),
              ListTile(
                leading: Icon(Icons.menu_book_rounded,
                    color: AppColors.teacherAccent),
                title: Text('Ngữ văn'),
                subtitle: Text('Nguyễn Thị Hồng'),
              ),
              Divider(height: 0),
              ListTile(
                leading: Icon(Icons.translate_rounded,
                    color: AppColors.teacherAccent),
                title: Text('Tiếng Anh'),
                subtitle: Text('Phạm Quốc Bảo'),
              ),
              Divider(height: 0),
              ListTile(
                leading: Icon(Icons.biotech_outlined,
                    color: AppColors.teacherAccent),
                title: Text('Sinh học'),
                subtitle: Text('Trần Thị Bình'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard(
      {required this.label, required this.value, required this.color});
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Column(
          children: [
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _StudentsTab extends StatefulWidget {
  const _StudentsTab({required this.className});
  final String className;

  @override
  State<_StudentsTab> createState() => _StudentsTabState();
}

class _StudentsTabState extends State<_StudentsTab> {
  late final Future<List<Map<String, dynamic>>> _future = _load();
  String _query = '';

  /// Tìm classId theo tên/mã lớp rồi tải danh sách học sinh của lớp đó.
  Future<List<Map<String, dynamic>>> _load() async {
    final api = sl<ApiService>();
    final classes = await api.classes();
    final match = classes.firstWhere(
      (c) =>
          (c['name'] ?? '').toString() == widget.className ||
          (c['code'] ?? '').toString() == widget.className,
      orElse: () => const <String, dynamic>{},
    );
    final id = (match['id'] ?? '').toString();
    if (id.isEmpty) return const [];
    return api.classStudents(id);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          color: AppColors.surface,
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: (v) =>
                      setState(() => _query = v.trim().toLowerCase()),
                  decoration: InputDecoration(
                    hintText: 'Tìm HS...',
                    prefixIcon: const Icon(Icons.search, size: 18),
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.divider),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.person_add_rounded,
                    color: AppColors.adminAccent),
                onPressed: () {},
              ),
            ],
          ),
        ),
        Expanded(
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: _future,
            builder: (context, snap) {
              if (snap.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snap.hasError) {
                return Center(
                    child: Text('Lỗi: ${snap.error}',
                        style:
                            const TextStyle(color: AppColors.textSecondary)));
              }
              final all = snap.data ?? [];
              final students = _query.isEmpty
                  ? all
                  : all.where((s) {
                      final name =
                          (s['fullName'] ?? '').toString().toLowerCase();
                      final code =
                          (s['studentCode'] ?? '').toString().toLowerCase();
                      return name.contains(_query) || code.contains(_query);
                    }).toList();
              if (students.isEmpty) {
                return const Center(
                    child: Text('Không có học sinh',
                        style: TextStyle(color: AppColors.textSecondary)));
              }
              return ListView.separated(
                itemCount: students.length,
                separatorBuilder: (_, __) => const Divider(height: 0),
                itemBuilder: (_, i) {
                  final s = students[i];
                  final name = (s['fullName'] ?? '').toString();
                  final code = (s['studentCode'] ?? '').toString();
                  return ListTile(
                    leading: CircleAvatar(
                      radius: 18,
                      backgroundColor:
                          AppColors.studentAccent.withValues(alpha: 0.14),
                      child: Text(
                        '${i + 1}',
                        style:
                            Theme.of(context).textTheme.labelMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.studentAccent,
                                ),
                      ),
                    ),
                    title: Text(
                      name,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      code,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: AppColors.textSecondary),
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded,
                        color: AppColors.textSecondary, size: 18),
                    onTap: () {},
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _TimetableSummaryTab extends StatelessWidget {
  const _TimetableSummaryTab();

  static const _days = ['T2', 'T3', 'T4', 'T5', 'T6'];
  static const _slots = {
    0: ['Toán', 'Vật lý', 'Ngữ văn', 'Tiếng Anh'],
    1: ['Tiếng Anh', 'Sinh học', 'Toán'],
    2: ['Toán', 'Ngữ văn', 'Hóa học'],
    3: ['Vật lý', 'Tiếng Anh', 'Lịch sử'],
    4: ['Ngữ văn', 'Toán', 'Địa lý', 'GDCD'],
  };

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              const Icon(Icons.check_circle_outline_rounded,
                  color: AppColors.success, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'TKB HK2 đã hoàn tất, không có xung đột',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        for (var d = 0; d < _days.length; d++) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 8, top: 8),
            child: Text(
              _days[d],
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.adminAccent,
                  ),
            ),
          ),
          ..._slots[d]!.asMap().entries.map(
                (e) => Card(
                  margin: const EdgeInsets.only(bottom: 6),
                  child: ListTile(
                    leading: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.adminAccent.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text('${e.key + 1}',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.adminAccent)),
                      ),
                    ),
                    title: Text(
                      e.value,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      'Tiết ${e.key + 1}',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: AppColors.textSecondary),
                    ),
                  ),
                ),
              ),
        ],
      ],
    );
  }
}
