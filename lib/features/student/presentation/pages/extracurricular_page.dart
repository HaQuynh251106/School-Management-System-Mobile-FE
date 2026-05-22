import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/section_header.dart';

class _Course {
  const _Course({
    required this.name,
    required this.schedule,
    required this.fee,
    required this.spots,
    required this.total,
    required this.instructor,
    this.registered = false,
  });
  final String name;
  final String schedule;
  final int fee;
  final int spots;
  final int total;
  final String instructor;
  final bool registered;
}

class StudentExtracurricularPage extends StatefulWidget {
  const StudentExtracurricularPage({super.key});

  @override
  State<StudentExtracurricularPage> createState() =>
      _StudentExtracurricularPageState();
}

class _StudentExtracurricularPageState
    extends State<StudentExtracurricularPage> {
  late List<_Course> _open = const [
    _Course(
      name: 'Robotics — Trình độ cơ bản',
      schedule: 'T7 14:00–16:00',
      fee: 600000,
      spots: 12,
      total: 20,
      instructor: 'Lê Văn Minh',
    ),
    _Course(
      name: 'Vẽ truyện tranh',
      schedule: 'T7 09:00–11:00',
      fee: 450000,
      spots: 18,
      total: 25,
      instructor: 'Nguyễn Thị Hồng',
    ),
    _Course(
      name: 'STEM — Lập trình Python',
      schedule: 'CN 14:00–16:00',
      fee: 750000,
      spots: 5,
      total: 15,
      instructor: 'Phạm Quốc Bảo',
    ),
    _Course(
      name: 'Bóng rổ trường',
      schedule: 'T6 16:00–17:30',
      fee: 350000,
      spots: 22,
      total: 25,
      instructor: 'Trần Văn Hùng',
    ),
  ];

  late List<_Course> _myCourses = const [
    _Course(
      name: 'Câu lạc bộ Tiếng Anh',
      schedule: 'T5 16:00–17:30',
      fee: 500000,
      spots: 15,
      total: 20,
      instructor: 'Native Speaker',
      registered: true,
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
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Khóa ngoại khóa'),
          backgroundColor: AppColors.studentAccent,
          bottom: TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white60,
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'Khóa mở (${_open.length})'),
              Tab(text: 'Của tôi (${_myCourses.length})'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildList(_open, false),
            _buildList(_myCourses, true),
          ],
        ),
      ),
    );
  }

  Widget _buildList(List<_Course> courses, bool isMine) {
    if (courses.isEmpty) {
      return const Center(
        child: Text('Chưa đăng ký khóa nào',
            style: TextStyle(color: AppColors.textSecondary)),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: courses.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        final c = courses[i];
        final percent = c.spots / c.total;
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
                        color: AppColors.studentAccent.withOpacity(0.12),
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
                          const SizedBox(height: 2),
                          Text('GV: ${c.instructor}',
                              style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                    if (isMine)
                      const Icon(Icons.check_circle_rounded,
                          color: AppColors.success),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.access_time_rounded,
                        size: 13, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(c.schedule,
                        style: const TextStyle(fontSize: 12)),
                    const Spacer(),
                    Text(
                      _formatVnd(c.fee),
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.studentAccent),
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
                              : AppColors.studentAccent,
                          backgroundColor: AppColors.divider,
                          minHeight: 6,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text('${c.spots}/${c.total} chỗ',
                        style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary)),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: isMine
                      ? OutlinedButton.icon(
                          onPressed: () => _unregister(c),
                          icon: const Icon(Icons.cancel_outlined, size: 16),
                          label: const Text('Hủy đăng ký'),
                        )
                      : FilledButton.icon(
                          onPressed: c.spots >= c.total
                              ? null
                              : () => _register(c),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.studentAccent,
                          ),
                          icon: const Icon(Icons.app_registration_rounded,
                              size: 16),
                          label: Text(
                              c.spots >= c.total ? 'Hết chỗ' : 'Đăng ký'),
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _register(_Course c) {
    setState(() {
      _open = _open.where((x) => x.name != c.name).toList();
      _myCourses = [
        ..._myCourses,
        _Course(
          name: c.name,
          schedule: c.schedule,
          fee: c.fee,
          spots: c.spots + 1,
          total: c.total,
          instructor: c.instructor,
          registered: true,
        ),
      ];
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'Đã đăng ký ${c.name}. Hóa đơn sẽ gửi cho PH trong 24h.'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _unregister(_Course c) {
    setState(() {
      _myCourses = _myCourses.where((x) => x.name != c.name).toList();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã hủy đăng ký ${c.name}'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
