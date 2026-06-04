import 'package:flutter/material.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/theme/app_colors.dart';

class _AdminCourse {
  const _AdminCourse({
    required this.name,
    required this.fee,
    required this.capacity,
    required this.description,
    required this.schedule,
    required this.status,
  });
  final String name;
  final int fee;
  final int capacity;
  final String description;
  final String schedule;
  final String status;

  factory _AdminCourse.fromJson(Map<String, dynamic> m) => _AdminCourse(
        name: (m['name'] ?? '').toString(),
        fee: (m['fee'] is num) ? (m['fee'] as num).toInt() : 0,
        capacity: (m['capacity'] is num) ? (m['capacity'] as num).toInt() : 0,
        description: (m['description'] ?? '').toString(),
        schedule: (m['schedule'] ?? '').toString(),
        status: (m['status'] ?? '').toString(),
      );
}

class ExtracurricularAdminPage extends StatefulWidget {
  const ExtracurricularAdminPage({super.key});

  @override
  State<ExtracurricularAdminPage> createState() =>
      _ExtracurricularAdminPageState();
}

class _ExtracurricularAdminPageState extends State<ExtracurricularAdminPage> {
  late final Future<List<Map<String, dynamic>>> _future =
      sl<ApiService>().clubs();

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
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _future,
      builder: (context, snap) {
        final loading = snap.connectionState != ConnectionState.done;
        final courses = (snap.data ?? []).map(_AdminCourse.fromJson).toList();
        final open = courses.where((c) => c.status == 'OPEN').toList();
        final closed = courses.where((c) => c.status == 'CLOSED').toList();
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
            body: loading
                ? const Center(child: CircularProgressIndicator())
                : snap.hasError
                    ? Center(
                        child: Text('Lỗi: ${snap.error}',
                            style: const TextStyle(
                                color: AppColors.textSecondary)))
                    : TabBarView(
                        children: [
                          _buildList(context, open),
                          _buildList(context, closed),
                        ],
                      ),
          ),
        );
      },
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
                          Text(
                              c.schedule.isEmpty
                                  ? c.description
                                  : '${c.schedule}${c.description.isEmpty ? '' : ' • ${c.description}'}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
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
                          const Text('Doanh thu tối đa',
                              style: TextStyle(
                                  fontSize: 10,
                                  color: AppColors.textSecondary)),
                          Text(_formatVnd(c.fee * c.capacity),
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
                    const Icon(Icons.groups_outlined,
                        size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 6),
                    Text('Sĩ số tối đa: ${c.capacity} HS',
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
