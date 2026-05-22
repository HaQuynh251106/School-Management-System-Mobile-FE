import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/notification_center.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../../shared/widgets/stat_card.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import 'class_detail.dart';
import 'exam_categories_page.dart';
import 'extracurricular_admin.dart';
import 'fee_period_detail.dart';
import 'notification_templates_page.dart';
import 'timetable_scheduling.dart';
import 'user_detail.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _tab,
        children: const [
          _DashboardTab(),
          _UsersTab(),
          _StructureTab(),
          _SettingsTab(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        indicatorColor: AppColors.adminAccent.withOpacity(0.15),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard, color: AppColors.adminAccent),
            label: 'Tổng quan',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline_rounded),
            selectedIcon:
                Icon(Icons.people_rounded, color: AppColors.adminAccent),
            label: 'Người dùng',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_tree_outlined),
            selectedIcon:
                Icon(Icons.account_tree, color: AppColors.adminAccent),
            label: 'Cơ cấu',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings, color: AppColors.adminAccent),
            label: 'Cài đặt',
          ),
        ],
      ),
    );
  }
}

// =================== TAB 1: DASHBOARD ===================

class _DashboardTab extends StatelessWidget {
  const _DashboardTab();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Tổng quan hệ thống'),
          backgroundColor: AppColors.adminAccent,
          actions: const [_AdminNotiAction()],
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white60,
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'Tổng quan'),
              Tab(text: 'Báo cáo'),
              Tab(text: 'Audit'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _OverviewView(),
            _ReportsView(),
            _AuditLogView(),
          ],
        ),
      ),
    );
  }
}

class _OverviewView extends StatelessWidget {
  const _OverviewView();

  @override
  Widget build(BuildContext context) {
    final user = (context.read<AuthBloc>().state as AuthAuthenticated).user;
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
              const CircleAvatar(
                backgroundColor: Colors.white24,
                radius: 26,
                child: Icon(Icons.admin_panel_settings,
                    color: Colors.white, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Xin chào, ${user.fullName}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 15)),
                    const SizedBox(height: 2),
                    const Text('Quản trị viên hệ thống',
                        style: TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const SectionHeader(title: 'Thống kê nhanh'),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.4,
          children: const [
            StatCard(
              label: 'Học sinh',
              value: '1.248',
              icon: Icons.school_rounded,
              color: AppColors.studentAccent,
            ),
            StatCard(
              label: 'Giáo viên',
              value: '84',
              icon: Icons.person_rounded,
              color: AppColors.teacherAccent,
            ),
            StatCard(
              label: 'Lớp học',
              value: '32',
              icon: Icons.class_rounded,
              color: AppColors.adminAccent,
            ),
            StatCard(
              label: 'Phụ huynh',
              value: '963',
              icon: Icons.family_restroom_rounded,
              color: AppColors.parentAccent,
            ),
          ],
        ),
        const SizedBox(height: 20),
        const SectionHeader(title: 'Cảnh báo'),
        const SizedBox(height: 10),
        _AlertCard(
          color: AppColors.error,
          icon: Icons.warning_amber_rounded,
          title: '266 hóa đơn quá hạn',
          subtitle: 'Tổng ~ 1,2 tỷ đồng — cần gửi nhắc nợ',
        ),
        const SizedBox(height: 8),
        _AlertCard(
          color: AppColors.warning,
          icon: Icons.event_busy_rounded,
          title: '12 GV chưa nhập điểm GK',
          subtitle: 'Hạn chót 25/05',
        ),
        const SizedBox(height: 20),
        const SectionHeader(
            title: 'Hoạt động gần đây', action: 'Xem tất cả'),
        const SizedBox(height: 12),
        Column(
          children: const [
            _ActivityRow(
              icon: Icons.person_add_rounded,
              title: 'Thêm 15 HS vào lớp 10A1',
              time: '2 giờ trước',
              color: AppColors.studentAccent,
            ),
            _ActivityRow(
              icon: Icons.schedule_rounded,
              title: 'Xếp TKB HK2 hoàn tất',
              time: 'Hôm nay',
              color: AppColors.adminAccent,
            ),
            _ActivityRow(
              icon: Icons.receipt_long_rounded,
              title: 'Phát hành hóa đơn HK2',
              time: 'Hôm qua',
              color: AppColors.parentAccent,
            ),
          ],
        ),
      ],
    );
  }
}

class _AlertCard extends StatelessWidget {
  const _AlertCard({
    required this.color,
    required this.icon,
    required this.title,
    required this.subtitle,
  });
  final Color color;
  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 13)),
                Text(subtitle,
                    style: TextStyle(fontSize: 11, color: color)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded,
              color: AppColors.textSecondary),
        ],
      ),
    );
  }
}

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({
    required this.icon,
    required this.title,
    required this.time,
    required this.color,
  });
  final IconData icon;
  final String title;
  final String time;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.12),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(title, style: const TextStyle(fontSize: 13)),
        subtitle: Text(time,
            style: const TextStyle(
                fontSize: 11, color: AppColors.textSecondary)),
      ),
    );
  }
}

class _ReportsView extends StatelessWidget {
  const _ReportsView();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SectionHeader(title: 'Phổ điểm toàn trường — HK1'),
        const SizedBox(height: 10),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: const [
                _HistRow(
                  label: 'Yếu (<5)',
                  count: 45,
                  total: 1248,
                  color: AppColors.error,
                ),
                SizedBox(height: 8),
                _HistRow(
                  label: 'TB (5–6.5)',
                  count: 215,
                  total: 1248,
                  color: AppColors.late,
                ),
                SizedBox(height: 8),
                _HistRow(
                  label: 'Khá (6.5–8)',
                  count: 489,
                  total: 1248,
                  color: AppColors.warning,
                ),
                SizedBox(height: 8),
                _HistRow(
                  label: 'Giỏi (≥8)',
                  count: 499,
                  total: 1248,
                  color: AppColors.success,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        const SectionHeader(title: 'Chuyên cần theo khối'),
        const SizedBox(height: 10),
        Card(
          child: Column(
            children: const [
              _AttRow(grade: 'Khối 10', rate: 0.96),
              Divider(height: 0),
              _AttRow(grade: 'Khối 11', rate: 0.92),
              Divider(height: 0),
              _AttRow(grade: 'Khối 12', rate: 0.98),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const SectionHeader(title: 'Doanh thu hóa đơn HK2 (đến nay)'),
        const SizedBox(height: 10),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Đã thu',
                    style: TextStyle(
                        fontSize: 12, color: AppColors.textSecondary)),
                const Text('4.419.000.000 ₫',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.success)),
                const SizedBox(height: 4),
                const Text('/ 5.616.000.000 ₫ tổng',
                    style: TextStyle(
                        fontSize: 11, color: AppColors.textSecondary)),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: 4419 / 5616,
                    color: AppColors.success,
                    backgroundColor: AppColors.divider,
                    minHeight: 10,
                  ),
                ),
                const SizedBox(height: 6),
                const Text('78,7% — Còn 266 HS chưa thanh toán',
                    style: TextStyle(
                        fontSize: 11, color: AppColors.textSecondary)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        const SectionHeader(title: 'Xuất báo cáo'),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _exportSnack(context, 'Excel'),
                icon: const Icon(Icons.table_chart_outlined),
                label: const Text('Excel'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _exportSnack(context, 'PDF'),
                icon: const Icon(Icons.picture_as_pdf_outlined),
                label: const Text('PDF'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _exportSnack(BuildContext context, String fmt) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đang chuẩn bị file $fmt...'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _HistRow extends StatelessWidget {
  const _HistRow({
    required this.label,
    required this.count,
    required this.total,
    required this.color,
  });
  final String label;
  final int count;
  final int total;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final pct = count / total;
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(label, style: const TextStyle(fontSize: 12)),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct,
              color: color,
              backgroundColor: color.withOpacity(0.12),
              minHeight: 16,
            ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 60,
          child: Text(
            '$count (${(pct * 100).toStringAsFixed(0)}%)',
            style: TextStyle(
                fontSize: 11, fontWeight: FontWeight.bold, color: color),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}

class _AttRow extends StatelessWidget {
  const _AttRow({required this.grade, required this.rate});
  final String grade;
  final double rate;

  Color get _color {
    if (rate >= 0.95) return AppColors.success;
    if (rate >= 0.85) return AppColors.warning;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(grade, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: _color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text('${(rate * 100).toStringAsFixed(0)}%',
            style: TextStyle(
                fontWeight: FontWeight.bold, color: _color, fontSize: 13)),
      ),
    );
  }
}

class _AuditLogView extends StatelessWidget {
  const _AuditLogView();

  static const _entries = [
    (
      'admin',
      'LOGIN',
      'identity',
      'Đăng nhập thành công',
      '22/05 09:15',
      AppColors.success
    ),
    (
      'admin',
      'CREATE',
      'identity.user',
      'Tạo user gv.tuyet (TEACHER)',
      '22/05 08:50',
      AppColors.primary
    ),
    (
      'gv.hoa',
      'UPDATE',
      'academic.grade',
      'Sửa điểm GK Toán cho HS u-student-3 (8.5 → 9.0)',
      '21/05 14:32',
      AppColors.warning
    ),
    (
      'admin',
      'EXPORT',
      'reports',
      'Xuất báo cáo phổ điểm HK1 (PDF)',
      '21/05 10:05',
      AppColors.adminAccent
    ),
    (
      'gv.minh',
      'DELETE',
      'academic.assignment',
      'Xóa Assignment a-77',
      '20/05 16:18',
      AppColors.error
    ),
    (
      'system',
      'PAYMENT',
      'finance.payment',
      'VNPAY callback OK — Invoice HD-2025-HK2-0042',
      '20/05 09:30',
      AppColors.success
    ),
    (
      'admin',
      'LOGIN_FAILED',
      'identity',
      'Đăng nhập sai mật khẩu (IP 113.161.x.x)',
      '19/05 22:11',
      AppColors.error
    ),
  ];

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
                    hintText: 'Tìm theo actor, entity...',
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
                icon: const Icon(Icons.filter_list_rounded),
                onPressed: () {},
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            itemCount: _entries.length,
            separatorBuilder: (_, __) => const Divider(height: 0),
            itemBuilder: (_, i) {
              final (actor, action, module, msg, time, color) = _entries[i];
              return ListTile(
                leading: CircleAvatar(
                  radius: 16,
                  backgroundColor: color.withOpacity(0.12),
                  child: Icon(_actionIcon(action), color: color, size: 16),
                ),
                title: Text(msg,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w500)),
                subtitle: Text(
                    '@$actor • $module • $action',
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textSecondary)),
                trailing: Text(time,
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textSecondary)),
              );
            },
          ),
        ),
      ],
    );
  }

  IconData _actionIcon(String action) => switch (action) {
        'LOGIN' || 'LOGIN_FAILED' => Icons.login_rounded,
        'CREATE' => Icons.add_circle_outline_rounded,
        'UPDATE' => Icons.edit_outlined,
        'DELETE' => Icons.delete_outline,
        'EXPORT' => Icons.file_download_outlined,
        'PAYMENT' => Icons.payment_rounded,
        _ => Icons.history_rounded,
      };
}

// =================== TAB 2: USERS ===================

class _UsersTab extends StatelessWidget {
  const _UsersTab();

  static const _users = [
    ('Trần Thị Hoa', 'GV001', 'TEACHER', 'gv.hoa'),
    ('Lê Văn Minh', 'GV002', 'TEACHER', 'gv.minh'),
    ('Nguyễn Thị Hồng', 'GV003', 'TEACHER', 'gv.hong'),
    ('Phạm Quốc Bảo', 'GV004', 'TEACHER', 'gv.bao'),
    ('Phạm Hoài An', 'HS2025001', 'STUDENT', 'hs.an'),
    ('Phạm Hoài Bình', 'HS2025002', 'STUDENT', 'hs.binh'),
    ('Nguyễn Minh Châu', 'HS2025003', 'STUDENT', 'hs.chau'),
    ('Trần Thị Dung', 'HS2025004', 'STUDENT', 'hs.dung'),
    ('Phạm Văn Quân', '', 'PARENT', 'ph.pham'),
    ('Nguyễn Văn Đức', '', 'PARENT', 'ph.nguyen'),
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Quản lý người dùng'),
          backgroundColor: AppColors.adminAccent,
          actions: [
            IconButton(icon: const Icon(Icons.search), onPressed: () {}),
            IconButton(
                icon: const Icon(Icons.upload_file_outlined),
                tooltip: 'Import Excel',
                onPressed: () {}),
            const _AdminNotiAction(),
          ],
          bottom: const TabBar(
            isScrollable: true,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white60,
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'Tất cả'),
              Tab(text: 'Giáo viên'),
              Tab(text: 'Học sinh'),
              Tab(text: 'Phụ huynh'),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {},
          icon: const Icon(Icons.person_add_rounded),
          label: const Text('Thêm'),
          backgroundColor: AppColors.adminAccent,
        ),
        body: TabBarView(
          children: [
            _UserList(users: _users),
            _UserList(users: _users.where((u) => u.$3 == 'TEACHER').toList()),
            _UserList(users: _users.where((u) => u.$3 == 'STUDENT').toList()),
            _UserList(users: _users.where((u) => u.$3 == 'PARENT').toList()),
          ],
        ),
      ),
    );
  }
}

class _UserList extends StatelessWidget {
  const _UserList({required this.users});
  final List<(String, String, String, String)> users;

  @override
  Widget build(BuildContext context) {
    if (users.isEmpty) {
      return const Center(
          child: Text('Không có user',
              style: TextStyle(color: AppColors.textSecondary)));
    }
    return ListView.separated(
      itemCount: users.length,
      separatorBuilder: (_, __) => const Divider(height: 0),
      itemBuilder: (context, i) {
        final (name, code, role, username) = users[i];
        final color = _roleColor(role);
        return ListTile(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => AdminUserDetail(
                name: name,
                code: code,
                role: role,
                username: username,
              ),
            ),
          ),
          leading: CircleAvatar(
            backgroundColor: color.withOpacity(0.14),
            child: Text(name[0],
                style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          ),
          title: Text(name,
              style: const TextStyle(fontWeight: FontWeight.w500)),
          subtitle: Text(
              '@$username${code.isEmpty ? '' : ' • $code'}',
              style: const TextStyle(
                  fontSize: 12, color: AppColors.textSecondary)),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Chip(
                label: Text(_roleLabel(role),
                    style: TextStyle(fontSize: 11, color: color)),
                backgroundColor: color.withOpacity(0.1),
                padding: EdgeInsets.zero,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                side: BorderSide.none,
              ),
              const Icon(Icons.chevron_right_rounded,
                  color: AppColors.textSecondary, size: 18),
            ],
          ),
        );
      },
    );
  }

  Color _roleColor(String role) => switch (role) {
        'TEACHER' => AppColors.teacherAccent,
        'STUDENT' => AppColors.studentAccent,
        'PARENT' => AppColors.parentAccent,
        _ => AppColors.adminAccent,
      };

  String _roleLabel(String role) => switch (role) {
        'TEACHER' => 'GV',
        'STUDENT' => 'HS',
        'PARENT' => 'PH',
        _ => 'Admin',
      };
}

// =================== TAB 3: STRUCTURE ===================

class _StructureTab extends StatelessWidget {
  const _StructureTab();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Cơ cấu đào tạo'),
          backgroundColor: AppColors.adminAccent,
          actions: const [_AdminNotiAction()],
          bottom: const TabBar(
            isScrollable: true,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white60,
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'Năm học'),
              Tab(text: 'Lớp'),
              Tab(text: 'Môn & Phòng'),
              Tab(text: 'Xếp TKB'),
              Tab(text: 'Tài chính'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _AcademicYearView(),
            _ClassesView(),
            _SubjectsRoomsView(),
            _TimetableHubView(),
            _FinanceView(),
          ],
        ),
      ),
    );
  }
}

class _AcademicYearView extends StatelessWidget {
  const _AcademicYearView();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SectionHeader(title: 'Năm học hiện hành'),
        const SizedBox(height: 10),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text('ACTIVE',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.success)),
                    ),
                    const Spacer(),
                    const Text('05/09/2025 – 31/05/2026',
                        style: TextStyle(
                            color: AppColors.textSecondary, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 8),
                const Text('Năm học 2025-2026',
                    style: TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 15)),
                const SizedBox(height: 12),
                Row(
                  children: const [
                    _SemChip('HK1', '05/09 – 15/01', AppColors.success),
                    SizedBox(width: 8),
                    _SemChip('HK2', '20/01 – 31/05', AppColors.warning),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        const SectionHeader(
            title: 'Ngày nghỉ trong năm', action: 'Thêm'),
        const SizedBox(height: 10),
        Card(
          child: Column(
            children: const [
              ListTile(
                leading:
                    Icon(Icons.celebration_rounded, color: AppColors.warning),
                title: Text('Nghỉ Tết Nguyên Đán'),
                subtitle: Text('25/01 – 04/02/2026 (11 ngày)'),
              ),
              Divider(height: 0),
              ListTile(
                leading:
                    Icon(Icons.flag_rounded, color: AppColors.warning),
                title: Text('Giỗ tổ Hùng Vương'),
                subtitle: Text('18/04/2026'),
              ),
              Divider(height: 0),
              ListTile(
                leading:
                    Icon(Icons.beach_access_rounded, color: AppColors.warning),
                title: Text('Nghỉ lễ 30/4 – 1/5'),
                subtitle: Text('30/04 – 03/05/2026'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const SectionHeader(title: 'Lịch sử năm học'),
        const SizedBox(height: 10),
        Card(
          child: Column(
            children: const [
              ListTile(
                leading: Icon(Icons.archive_outlined,
                    color: AppColors.textSecondary),
                title: Text('2024-2025'),
                subtitle: Text('Đã đóng • 1.215 HS, 28 lớp'),
              ),
              Divider(height: 0),
              ListTile(
                leading: Icon(Icons.archive_outlined,
                    color: AppColors.textSecondary),
                title: Text('2023-2024'),
                subtitle: Text('Đã đóng • 1.180 HS, 27 lớp'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SemChip extends StatelessWidget {
  const _SemChip(this.code, this.dates, this.color);
  final String code;
  final String dates;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(code,
              style: TextStyle(
                  color: color, fontWeight: FontWeight.bold, fontSize: 12)),
          Text(dates,
              style: TextStyle(color: color.withOpacity(0.8), fontSize: 10)),
        ],
      ),
    );
  }
}

class _ClassesView extends StatelessWidget {
  const _ClassesView();

  static const _classes = [
    ('10A1', 'Khối 10', 'Trần Thị Hoa', 38),
    ('10A2', 'Khối 10', 'Lê Văn Minh', 40),
    ('10A3', 'Khối 10', 'Nguyễn Thị Hồng', 39),
    ('11B1', 'Khối 11', 'Phạm Quốc Bảo', 42),
    ('11B2', 'Khối 11', 'Trần Thị Bình', 41),
    ('12A1', 'Khối 12', 'Nguyễn Văn Tuấn', 36),
    ('8A1', 'Khối 8', 'Trần Thị Hoa', 35),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _classes.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) {
        final c = _classes[i];
        return Card(
          margin: EdgeInsets.zero,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => AdminClassDetail(
                  className: c.$1,
                  gradeName: c.$2,
                  homeroom: c.$3,
                  studentCount: c.$4,
                ),
              ),
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.adminAccent.withOpacity(0.12),
                child: Text(c.$1,
                    style: const TextStyle(
                        color: AppColors.adminAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 12)),
              ),
              title: Text(c.$1,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text('${c.$2} • GVCN: ${c.$3}',
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textSecondary)),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.adminAccent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text('${c.$4} HS',
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.adminAccent)),
                  ),
                  const Icon(Icons.chevron_right_rounded,
                      color: AppColors.textSecondary, size: 18),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SubjectsRoomsView extends StatelessWidget {
  const _SubjectsRoomsView();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SectionHeader(title: 'Môn học', action: 'Thêm môn'),
        const SizedBox(height: 10),
        Card(
          child: Column(
            children: const [
              _SubjectRow(name: 'Toán', code: 'MATH', main: true),
              Divider(height: 0),
              _SubjectRow(name: 'Vật lý', code: 'PHYS', main: true),
              Divider(height: 0),
              _SubjectRow(name: 'Hóa học', code: 'CHEM', main: true),
              Divider(height: 0),
              _SubjectRow(name: 'Sinh học', code: 'BIO', main: true),
              Divider(height: 0),
              _SubjectRow(name: 'Ngữ văn', code: 'LIT', main: true),
              Divider(height: 0),
              _SubjectRow(name: 'Tiếng Anh', code: 'ENG', main: true),
              Divider(height: 0),
              _SubjectRow(name: 'Lịch sử', code: 'HIST', main: false),
              Divider(height: 0),
              _SubjectRow(name: 'Địa lý', code: 'GEO', main: false),
              Divider(height: 0),
              _SubjectRow(
                  name: 'Giáo dục công dân', code: 'CIV', main: false),
              Divider(height: 0),
              _SubjectRow(
                  name: 'Thể dục', code: 'PE', main: false),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const SectionHeader(title: 'Phòng học', action: 'Thêm phòng'),
        const SizedBox(height: 10),
        Card(
          child: Column(
            children: const [
              _RoomRow(code: 'P201', floor: 'Tầng 2', type: 'CLASSROOM', cap: 45),
              Divider(height: 0),
              _RoomRow(code: 'P202', floor: 'Tầng 2', type: 'CLASSROOM', cap: 45),
              Divider(height: 0),
              _RoomRow(code: 'P105', floor: 'Tầng 1', type: 'CLASSROOM', cap: 40),
              Divider(height: 0),
              _RoomRow(code: 'Lab 1', floor: 'Tầng 3', type: 'LAB', cap: 30),
              Divider(height: 0),
              _RoomRow(code: 'Gym', floor: 'Tầng trệt', type: 'GYM', cap: 80),
            ],
          ),
        ),
      ],
    );
  }
}

class _SubjectRow extends StatelessWidget {
  const _SubjectRow({
    required this.name,
    required this.code,
    required this.main,
  });
  final String name;
  final String code;
  final bool main;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: (main ? AppColors.adminAccent : AppColors.textSecondary)
              .withOpacity(0.12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(code.substring(0, 2),
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                  color: main
                      ? AppColors.adminAccent
                      : AppColors.textSecondary)),
        ),
      ),
      title:
          Text(name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      subtitle: Text(code,
          style: const TextStyle(
              fontSize: 11, color: AppColors.textSecondary)),
      trailing: main
          ? const Chip(
              label: Text('Chính', style: TextStyle(fontSize: 10)),
              padding: EdgeInsets.zero,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              backgroundColor: Color(0x1A283593),
              side: BorderSide.none,
            )
          : null,
    );
  }
}

class _RoomRow extends StatelessWidget {
  const _RoomRow({
    required this.code,
    required this.floor,
    required this.type,
    required this.cap,
  });
  final String code;
  final String floor;
  final String type;
  final int cap;

  IconData get _icon => switch (type) {
        'LAB' => Icons.science_outlined,
        'GYM' => Icons.fitness_center_rounded,
        _ => Icons.meeting_room_outlined,
      };

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(_icon, color: AppColors.adminAccent),
      title: Text(code,
          style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text('$floor • $type',
          style: const TextStyle(
              fontSize: 11, color: AppColors.textSecondary)),
      trailing: Text('$cap chỗ',
          style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500)),
    );
  }
}

class _FinanceView extends StatelessWidget {
  const _FinanceView();

  static const _periods = [
    ('FP-HK2-2025', 'Học phí HK2 2025-2026', 'OPEN'),
    ('FP-INS-2025', 'Bảo hiểm 2025-2026', 'OPEN'),
    ('FP-HK1-2025', 'Học phí HK1 2025-2026', 'CLOSED'),
    ('FP-UNI-2025', 'Đồng phục đầu năm', 'CLOSED'),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SectionHeader(title: 'Đợt thu đang mở', action: 'Tạo mới'),
        const SizedBox(height: 10),
        ..._periods.map((p) {
          final isOpen = p.$3 == 'OPEN';
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => AdminFeePeriodDetail(
                    code: p.$1,
                    title: p.$2,
                    status: p.$3,
                  ),
                ),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor:
                      (isOpen ? AppColors.success : AppColors.textSecondary)
                          .withOpacity(0.12),
                  child: Icon(
                    isOpen ? Icons.receipt_long_rounded : Icons.archive_outlined,
                    color: isOpen
                        ? AppColors.success
                        : AppColors.textSecondary,
                  ),
                ),
                title: Text(p.$2,
                    style: const TextStyle(fontWeight: FontWeight.w500)),
                subtitle: Text(p.$1,
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textSecondary)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: (isOpen
                                ? AppColors.success
                                : AppColors.textSecondary)
                            .withOpacity(0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(p.$3,
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: isOpen
                                  ? AppColors.success
                                  : AppColors.textSecondary)),
                    ),
                    const Icon(Icons.chevron_right_rounded,
                        color: AppColors.textSecondary, size: 18),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}

// =================== TAB 4: SETTINGS ===================

class _SettingsTab extends StatelessWidget {
  const _SettingsTab();

  @override
  Widget build(BuildContext context) {
    final user = (context.read<AuthBloc>().state as AuthAuthenticated).user;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cài đặt'),
        backgroundColor: AppColors.adminAccent,
        actions: const [_AdminNotiAction()],
      ),
      body: ListView(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            color: AppColors.surface,
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.adminAccent,
                  child: Icon(Icons.admin_panel_settings_rounded,
                      color: Colors.white),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.fullName,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15)),
                      Text(user.email ?? user.username,
                          style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          _AdminSettingsGroup(
            title: 'Quản trị hệ thống',
            children: [
              _AdminSettingsTile(
                icon: Icons.schedule_rounded,
                label: 'Xếp Thời khóa biểu (A3)',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (_) => const TimetableSchedulingPage()),
                ),
              ),
              _AdminSettingsTile(
                icon: Icons.assignment_outlined,
                label: 'Cấu hình Khảo thí (A4)',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (_) => const ExamCategoriesPage()),
                ),
              ),
              _AdminSettingsTile(
                icon: Icons.sports_basketball_outlined,
                label: 'Khóa Ngoại khóa (A5)',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (_) => const ExtracurricularAdminPage()),
                ),
              ),
              _AdminSettingsTile(
                icon: Icons.notifications_active_outlined,
                label: 'Template thông báo',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (_) => const NotificationTemplatesPage()),
                ),
              ),
              _AdminSettingsTile(
                icon: Icons.api_outlined,
                label: 'Tích hợp VNPAY / MoMo',
                onTap: () => _todoSnack(context, 'Tích hợp VNPAY / MoMo'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const _SettingsSection(
            title: 'Bảo mật',
            items: [
              _SettingsItem(
                  icon: Icons.security_outlined, label: 'Phân quyền RBAC'),
              _SettingsItem(
                  icon: Icons.vpn_key_outlined,
                  label: 'JWT — Cấu hình token'),
              _SettingsItem(
                  icon: Icons.shield_outlined,
                  label: 'Chính sách mật khẩu'),
            ],
          ),
          const SizedBox(height: 16),
          const _SettingsSection(
            title: 'Tài khoản',
            items: [
              _SettingsItem(
                  icon: Icons.person_outline_rounded,
                  label: 'Thông tin tài khoản'),
              _SettingsItem(
                  icon: Icons.lock_outline_rounded, label: 'Đổi mật khẩu'),
            ],
          ),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.info_outline_rounded,
                color: AppColors.textSecondary),
            title: const Text('Phiên bản'),
            trailing: const Text('0.1.0',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          ListTile(
            leading: const Icon(Icons.logout_rounded, color: AppColors.error),
            title: const Text('Đăng xuất',
                style: TextStyle(color: AppColors.error)),
            onTap: () => _confirmLogout(context),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _todoSnack(BuildContext context, String label) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label — Đang phát triển'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn chắc muốn đăng xuất?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthBloc>().add(const AuthLogoutRequested());
            },
            child: const Text('Đăng xuất',
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({required this.title, required this.items});
  final String title;
  final List<_SettingsItem> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Text(title,
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.8)),
        ),
        ...items.expand((item) => [
              ListTile(
                leading: Icon(item.icon, color: AppColors.adminAccent),
                title: Text(item.label),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${item.label} — Đang phát triển'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
              const Divider(height: 0, indent: 56),
            ]),
      ],
    );
  }
}

class _SettingsItem {
  const _SettingsItem({required this.icon, required this.label});
  final IconData icon;
  final String label;
}

// =================== TIMETABLE HUB (Cơ cấu sub-tab) ===================

class _TimetableHubView extends StatelessWidget {
  const _TimetableHubView();

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('TKB HK2 2025-2026',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18)),
              const SizedBox(height: 6),
              Text(
                'Đã hoàn tất xếp 28/32 lớp — 4 lớp chưa xếp',
                style: TextStyle(
                    color: Colors.white.withOpacity(0.85), fontSize: 13),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const TimetableSchedulingPage(),
                    ),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.adminAccent,
                  ),
                  icon: const Icon(Icons.edit_calendar_rounded),
                  label: const Text('Mở trình xếp TKB'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const SectionHeader(title: 'Trạng thái xếp TKB'),
        const SizedBox(height: 10),
        Card(
          child: Column(
            children: [
              _StatusRow(
                  label: 'Khối 10',
                  done: 6,
                  total: 6,
                  color: AppColors.success),
              const Divider(height: 0),
              _StatusRow(
                  label: 'Khối 11',
                  done: 6,
                  total: 7,
                  color: AppColors.warning),
              const Divider(height: 0),
              _StatusRow(
                  label: 'Khối 12',
                  done: 8,
                  total: 8,
                  color: AppColors.success),
              const Divider(height: 0),
              _StatusRow(
                  label: 'Khối 6–9',
                  done: 8,
                  total: 11,
                  color: AppColors.warning),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const SectionHeader(title: 'Xung đột chờ giải quyết'),
        const SizedBox(height: 8),
        Card(
          child: Column(
            children: const [
              ListTile(
                leading: Icon(Icons.warning_amber_rounded,
                    color: AppColors.error),
                title: Text('GV Trần Thị Hoa — trùng tiết 3 T2'),
                subtitle: Text('10A1 vs 8A1 — cần đổi GV hoặc tiết',
                    style: TextStyle(fontSize: 11)),
              ),
              Divider(height: 0),
              ListTile(
                leading: Icon(Icons.warning_amber_rounded,
                    color: AppColors.error),
                title: Text('Phòng Lab 1 — trùng tiết 2 T4'),
                subtitle: Text('11B1 (Vật lý) vs 12A1 (Sinh)',
                    style: TextStyle(fontSize: 11)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({
    required this.label,
    required this.done,
    required this.total,
    required this.color,
  });
  final String label;
  final int done;
  final int total;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(label,
          style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: LinearProgressIndicator(
        value: done / total,
        color: color,
        backgroundColor: AppColors.divider,
        minHeight: 5,
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text('$done/$total',
            style: TextStyle(
                fontWeight: FontWeight.bold, color: color, fontSize: 13)),
      ),
    );
  }
}

// =================== SETTINGS HELPERS ===================

class _AdminSettingsGroup extends StatelessWidget {
  const _AdminSettingsGroup({required this.title, required this.children});
  final String title;
  final List<_AdminSettingsTile> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Text(title,
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.8)),
        ),
        ...children.expand((c) => [c, const Divider(height: 0, indent: 56)]),
      ],
    );
  }
}

class _AdminSettingsTile extends StatelessWidget {
  const _AdminSettingsTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.adminAccent),
      title: Text(label),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    );
  }
}

// =================== NOTIFICATION ACTION ===================

class _AdminNotiAction extends StatelessWidget {
  const _AdminNotiAction();

  @override
  Widget build(BuildContext context) {
    final unread = mockNotifications.where((n) => !n.read).length;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Stack(
        children: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const NotificationCenter(
                  accent: AppColors.adminAccent,
                  items: mockNotifications,
                ),
              ),
            ),
          ),
          if (unread > 0)
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: AppColors.error,
                  borderRadius: BorderRadius.circular(8),
                ),
                constraints: const BoxConstraints(minWidth: 14),
                child: Text('$unread',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center),
              ),
            ),
        ],
      ),
    );
  }
}
