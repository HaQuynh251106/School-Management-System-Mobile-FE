import 'package:flutter/material.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/theme/app_colors.dart';

class _Course {
  const _Course({
    required this.id,
    required this.name,
    required this.schedule,
    required this.fee,
    required this.capacity,
    required this.description,
    required this.isOpen,
  });
  final String id;
  final String name;
  final String schedule;
  final int fee;
  final int capacity;
  final String description;
  final bool isOpen;

  factory _Course.fromJson(Map<String, dynamic> m) => _Course(
        id: (m['id'] ?? '').toString(),
        name: (m['name'] ?? '').toString(),
        schedule: (m['schedule'] ?? '').toString(),
        fee: (m['fee'] is num) ? (m['fee'] as num).toInt() : 0,
        capacity: (m['capacity'] is num) ? (m['capacity'] as num).toInt() : 0,
        description: (m['description'] ?? '').toString(),
        isOpen: (m['status'] ?? '').toString() == 'OPEN',
      );
}

class StudentExtracurricularPage extends StatefulWidget {
  const StudentExtracurricularPage({super.key});

  @override
  State<StudentExtracurricularPage> createState() =>
      _StudentExtracurricularPageState();
}

class _StudentExtracurricularPageState
    extends State<StudentExtracurricularPage> {
  late Future<List<Map<String, dynamic>>> _future = sl<ApiService>().clubs();

  void _refresh() {
    setState(() {
      _future = sl<ApiService>().clubs();
    });
  }

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Khóa ngoại khóa'),
        backgroundColor: AppColors.studentAccent,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(
                child: Text('Lỗi: ${snap.error}',
                    style: const TextStyle(color: AppColors.textSecondary)));
          }
          final clubs = (snap.data ?? []).map(_Course.fromJson).toList();
          return _buildList(clubs);
        },
      ),
    );
  }

  Widget _buildList(List<_Course> courses) {
    if (courses.isEmpty) {
      return const Center(
        child: Text('Chưa có khóa ngoại khóa nào',
            style: TextStyle(color: AppColors.textSecondary)),
      );
    }
    return RefreshIndicator(
      onRefresh: () async => _refresh(),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: courses.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) {
          final c = courses[i];
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
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color:
                              AppColors.studentAccent.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.sports_basketball_rounded,
                            color: AppColors.studentAccent),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(c.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 14)),
                            if (c.description.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(c.description,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textSecondary)),
                            ],
                          ],
                        ),
                      ),
                      if (!c.isOpen)
                        const Icon(Icons.lock_outline_rounded,
                            color: AppColors.textSecondary, size: 18),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.access_time_rounded,
                          size: 13, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(c.schedule, style: const TextStyle(fontSize: 12)),
                      const Spacer(),
                      Text(
                        _formatVnd(c.fee),
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.studentAccent),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.groups_outlined,
                          size: 13, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text('Sĩ số tối đa: ${c.capacity}',
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.textSecondary)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: c.isOpen ? () => _register(c) : null,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.studentAccent,
                      ),
                      icon:
                          const Icon(Icons.app_registration_rounded, size: 16),
                      label: Text(c.isOpen ? 'Đăng ký' : 'Đã đóng'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _register(_Course c) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await sl<ApiService>().registerClub(c.id);
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content:
              Text('Đã đăng ký ${c.name}. Hóa đơn sẽ gửi cho PH trong 24h.'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
      _refresh();
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text('Đăng ký thất bại: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
