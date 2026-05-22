import 'package:flutter/material.dart';

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

  static const _students = [
    ('HS2025001', 'Phạm Hoài An'),
    ('HS2025002', 'Nguyễn Minh Châu'),
    ('HS2025003', 'Trần Thị Dung'),
    ('HS2025004', 'Lê Quang Huy'),
    ('HS2025005', 'Võ Thị Kim'),
    ('HS2025006', 'Đỗ Văn Long'),
    ('HS2025007', 'Hoàng Thị Mai'),
    ('HS2025008', 'Bùi Ngọc Nam'),
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Lớp $className'),
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
            const _StudentsTab(students: _students),
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
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(className,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(gradeName,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text('GVCN: $homeroom',
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 13)),
                    Text('Sĩ số: $studentCount HS',
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const SectionHeader(title: 'Thống kê'),
        const SizedBox(height: 10),
        Row(
          children: const [
            Expanded(
                child: _StatCard(
                    label: 'TB lớp',
                    value: '7.8',
                    color: AppColors.success)),
            SizedBox(width: 10),
            Expanded(
                child: _StatCard(
                    label: 'Tỉ lệ CC',
                    value: '94%',
                    color: AppColors.primary)),
            SizedBox(width: 10),
            Expanded(
                child: _StatCard(
                    label: 'Vắng KP',
                    value: '3',
                    color: AppColors.error)),
          ],
        ),
        const SizedBox(height: 20),
        const SectionHeader(title: 'GV bộ môn'),
        const SizedBox(height: 8),
        Card(
          child: Column(
            children: const [
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
            Text(value,
                style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 20, color: color)),
            const SizedBox(height: 4),
            Text(label,
                style: const TextStyle(
                    fontSize: 11, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}

class _StudentsTab extends StatelessWidget {
  const _StudentsTab({required this.students});
  final List<(String, String)> students;

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
          child: ListView.separated(
            itemCount: students.length,
            separatorBuilder: (_, __) => const Divider(height: 0),
            itemBuilder: (_, i) {
              final (code, name) = students[i];
              return ListTile(
                leading: CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.studentAccent.withOpacity(0.14),
                  child: Text('${i + 1}',
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.studentAccent)),
                ),
                title: Text(name,
                    style: const TextStyle(
                        fontWeight: FontWeight.w500, fontSize: 14)),
                subtitle: Text(code,
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textSecondary)),
                trailing: const Icon(Icons.chevron_right_rounded,
                    color: AppColors.textSecondary, size: 18),
                onTap: () {},
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
            color: AppColors.success.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: const [
              Icon(Icons.check_circle_outline_rounded,
                  color: AppColors.success, size: 18),
              SizedBox(width: 8),
              Expanded(
                child: Text('TKB HK2 đã hoàn tất, không có xung đột',
                    style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        for (var d = 0; d < _days.length; d++) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 8, top: 8),
            child: Text(_days[d],
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppColors.adminAccent)),
          ),
          ..._slots[d]!.asMap().entries.map(
                (e) => Card(
                  margin: const EdgeInsets.only(bottom: 6),
                  child: ListTile(
                    leading: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.adminAccent.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text('${e.key + 1}',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.adminAccent)),
                      ),
                    ),
                    title: Text(e.value,
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w500)),
                    subtitle: Text('Tiết ${e.key + 1}',
                        style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary)),
                  ),
                ),
              ),
        ],
      ],
    );
  }
}
