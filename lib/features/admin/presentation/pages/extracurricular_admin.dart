import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/section_header.dart';

class _AdminCourse {
  const _AdminCourse({
    required this.code,
    required this.name,
    required this.fee,
    required this.enrolled,
    required this.max,
    required this.instructor,
    required this.status,
  });
  final String code;
  final String name;
  final int fee;
  final int enrolled;
  final int max;
  final String instructor;
  final String status;
}

class ExtracurricularAdminPage extends StatelessWidget {
  const ExtracurricularAdminPage({super.key});

  static const _courses = [
    _AdminCourse(
      code: 'EXT-RBT-2025',
      name: 'Robotics — Trình độ cơ bản',
      fee: 600000,
      enrolled: 12,
      max: 20,
      instructor: 'Lê Văn Minh',
      status: 'OPEN',
    ),
    _AdminCourse(
      code: 'EXT-ART-2025',
      name: 'Vẽ truyện tranh',
      fee: 450000,
      enrolled: 18,
      max: 25,
      instructor: 'Nguyễn Thị Hồng',
      status: 'OPEN',
    ),
    _AdminCourse(
      code: 'EXT-STEM-2025',
      name: 'STEM — Lập trình Python',
      fee: 750000,
      enrolled: 5,
      max: 15,
      instructor: 'Phạm Quốc Bảo',
      status: 'OPEN',
    ),
    _AdminCourse(
      code: 'EXT-BB-2025',
      name: 'Bóng rổ trường',
      fee: 350000,
      enrolled: 22,
      max: 25,
      instructor: 'Trần Văn Hùng',
      status: 'OPEN',
    ),
    _AdminCourse(
      code: 'EXT-EN-2024',
      name: 'CLB Tiếng Anh',
      fee: 500000,
      enrolled: 15,
      max: 20,
      instructor: 'Native Speaker',
      status: 'CLOSED',
    ),
  ];

  String _formatVnd(int amount) {
    final s = amount.toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return '${buf.toString()} ₫';
  }

  @override
  Widget build(BuildContext context) {
    final open = _courses.where((c) => c.status == 'OPEN').toList();
    final closed = _courses.where((c) => c.status == 'CLOSED').toList();
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Khóa ngoại khóa'),
          backgroundColor: AppColors.adminAccent,
          bottom: TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white60,
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'Đang mở (${open.length})'),
              Tab(text: 'Đã đóng (${closed.length})'),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _showCreate(context),
          backgroundColor: AppColors.adminAccent,
          icon: const Icon(Icons.add_rounded),
          label: const Text('Tạo khóa'),
        ),
        body: TabBarView(
          children: [
            _buildList(context, open),
            _buildList(context, closed),
          ],
        ),
      ),
    );
  }

  Widget _buildList(BuildContext context, List<_AdminCourse> items) {
    if (items.isEmpty) {
      return const Center(
          child: Text('Không có khóa',
              style: TextStyle(color: AppColors.textSecondary)));
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) {
        final c = items[i];
        final percent = c.enrolled / c.max;
        return Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.adminAccent.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.sports_basketball_rounded,
                          color: AppColors.adminAccent),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(c.name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14)),
                          const SizedBox(height: 2),
                          Text('${c.code} • GV: ${c.instructor}',
                              style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                    const Icon(Icons.more_vert,
                        color: AppColors.textSecondary, size: 18),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Học phí',
                              style: TextStyle(
                                  fontSize: 10,
                                  color: AppColors.textSecondary)),
                          Text(_formatVnd(c.fee),
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: AppColors.adminAccent)),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Doanh thu dự kiến',
                              style: TextStyle(
                                  fontSize: 10,
                                  color: AppColors.textSecondary)),
                          Text(_formatVnd(c.fee * c.enrolled),
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: AppColors.success)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: percent,
                          color: percent >= 0.8
                              ? AppColors.error
                              : AppColors.adminAccent,
                          backgroundColor: AppColors.divider,
                          minHeight: 6,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text('${c.enrolled}/${c.max} HS',
                        style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textSecondary)),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showCreate(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
            20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Tạo khóa ngoại khóa',
                  style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              const TextField(
                decoration: InputDecoration(labelText: 'Tên khóa', isDense: true),
              ),
              const SizedBox(height: 10),
              const Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                          labelText: 'Học phí (₫)', isDense: true),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                          labelText: 'Sĩ số tối đa', isDense: true),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const TextField(
                decoration:
                    InputDecoration(labelText: 'GV phụ trách', isDense: true),
              ),
              const SizedBox(height: 10),
              const TextField(
                decoration:
                    InputDecoration(labelText: 'Mô tả', isDense: true),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content:
                            Text('Đã tạo khóa. PH có thể đăng ký ngay.'),
                        backgroundColor: AppColors.success,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.adminAccent,
                  ),
                  child: const Text('Tạo & phát hành'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
