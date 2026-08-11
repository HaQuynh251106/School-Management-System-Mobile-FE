import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_controller.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/network/api_service.dart';
import '../../../../shared/widgets/notification_center.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../../shared/widgets/adaptive_role_scaffold.dart';
import '../../../../shared/widgets/mobile_workspace_page.dart';
import '../../../../shared/widgets/quick_create.dart';
import '../../../../shared/widgets/real_dashboard_panel.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import 'class_detail.dart';
import 'admin_reports_view.dart';
import 'club_management_page.dart';
import 'exam_categories_page.dart';
import 'fee_period_detail.dart';
import 'notification_templates_page.dart';
import 'teaching_assignments_page.dart';
import 'timetable_scheduling.dart';
import 'year_end_page.dart';
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
    return AdaptiveRoleScaffold(
      index: _tab,
      onSelected: (i) => setState(() => _tab = i),
      accent: AppColors.adminAccent,
      floatingActionButton: _tab == 0
          ? const QuickCreateButton(
              role: 'ADMIN', accent: AppColors.adminAccent)
          : null,
      pages: [
        _DashboardTab(onNavigate: (index) => setState(() => _tab = index)),
        const _UsersTab(),
        const _StructureTab(),
        const _SettingsTab(),
      ],
      destinations: const [
        RoleDestination(
          icon: Icons.dashboard_outlined,
          selectedIcon: Icons.dashboard_rounded,
          label: 'Tổng quan',
        ),
        RoleDestination(
          icon: Icons.people_outline_rounded,
          selectedIcon: Icons.people_rounded,
          label: 'Người dùng',
        ),
        RoleDestination(
          icon: Icons.account_tree_outlined,
          selectedIcon: Icons.account_tree_rounded,
          label: 'Đào tạo',
        ),
        RoleDestination(
          icon: Icons.grid_view_outlined,
          selectedIcon: Icons.grid_view_rounded,
          label: 'Tiện ích',
        ),
      ],
    );
  }
}

// =================== TAB 1: DASHBOARD ===================

class _DashboardTab extends StatelessWidget {
  const _DashboardTab({required this.onNavigate});

  final ValueChanged<int> onNavigate;

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
        body: TabBarView(
          children: [
            _OverviewView(onNavigate: onNavigate),
            const AdminReportsView(),
            const _AuditLogView(),
          ],
        ),
      ),
    );
  }
}

class _OverviewView extends StatefulWidget {
  const _OverviewView({required this.onNavigate});

  final ValueChanged<int> onNavigate;

  @override
  State<_OverviewView> createState() => _OverviewViewState();
}

class _OverviewViewState extends State<_OverviewView> {
  late Future<Map<String, dynamic>> _future = sl<ApiService>().dashboard();

  Future<void> _refresh() async {
    setState(() => _future = sl<ApiService>().dashboard());
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refresh,
      child: FutureBuilder<Map<String, dynamic>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return ListView(
              padding: const EdgeInsets.all(24),
              children: [
                const Icon(Icons.error_outline_rounded, size: 44),
                const SizedBox(height: 12),
                const Text('Không thể tải dashboard dữ liệu thật',
                    textAlign: TextAlign.center),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _refresh,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Thử lại'),
                ),
              ],
            );
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              RealDashboardPanel(
                dashboard: snapshot.data!,
                accent: AppColors.adminAccent,
                onRetry: _refresh,
                onShortcut: (shortcut) {
                  final target = '${shortcut['target'] ?? ''}';
                  widget.onNavigate(target == 'users' ? 1 : 2);
                },
              ),
              const SizedBox(height: 80),
            ],
          );
        },
      ),
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
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
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
                Text(subtitle, style: TextStyle(fontSize: 11, color: color)),
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
          backgroundColor: color.withValues(alpha: 0.12),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(title, style: const TextStyle(fontSize: 13)),
        subtitle: Text(time,
            style:
                const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
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
        const Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
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
        const Card(
          child: Column(
            children: [
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
                  child: const LinearProgressIndicator(
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
              backgroundColor: color.withValues(alpha: 0.12),
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
          color: _color.withValues(alpha: 0.12),
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
      'MoMo callback OK — Hóa đơn HD-2025-HK2-0042',
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
                  backgroundColor: color.withValues(alpha: 0.12),
                  child: Icon(_actionIcon(action), color: color, size: 16),
                ),
                title: Text(msg,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w500)),
                subtitle: Text('@$actor • $module • $action',
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

class _UsersTab extends StatefulWidget {
  const _UsersTab();

  @override
  State<_UsersTab> createState() => _UsersTabState();
}

class _UsersTabState extends State<_UsersTab> {
  late Future<List<Map<String, dynamic>>> _future = sl<ApiService>().users();

  void _refresh() {
    setState(() {
      _future = sl<ApiService>().users();
    });
  }

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
          onPressed: () => openQuickCreate(
            context,
            role: 'ADMIN',
            accent: AppColors.adminAccent,
            initialType: 'USER',
            onCreated: _refresh,
          ),
          icon: const Icon(Icons.person_add_rounded),
          label: const Text('Thêm'),
          backgroundColor: AppColors.adminAccent,
        ),
        body: FutureBuilder<List<Map<String, dynamic>>>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snap.hasError) {
              return Center(
                child: Text('Lỗi tải người dùng: ${snap.error}',
                    style: const TextStyle(color: AppColors.textSecondary)),
              );
            }
            final all = snap.data ?? const [];
            return TabBarView(
              children: [
                _UserList(users: all, onChanged: _refresh),
                _UserList(
                    users: all.where((u) => u['role'] == 'TEACHER').toList(),
                    onChanged: _refresh),
                _UserList(
                    users: all.where((u) => u['role'] == 'STUDENT').toList(),
                    onChanged: _refresh),
                _UserList(
                    users: all.where((u) => u['role'] == 'PARENT').toList(),
                    onChanged: _refresh),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _UserList extends StatelessWidget {
  const _UserList({required this.users, this.onChanged});
  final List<Map<String, dynamic>> users;
  final VoidCallback? onChanged;

  Future<void> _toggleLock(BuildContext context, String id, bool locked) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      if (locked) {
        await sl<ApiService>().unlockUser(id);
      } else {
        await sl<ApiService>().lockUser(id);
      }
      messenger.showSnackBar(
        SnackBar(
          content: Text(locked ? 'Đã mở khóa tài khoản' : 'Đã khóa tài khoản'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      onChanged?.call();
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('Lỗi: $e'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

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
        final u = users[i];
        final id = (u['id'] ?? '').toString();
        final name = (u['fullName'] ?? '').toString();
        final username = (u['username'] ?? '').toString();
        final role = (u['role'] ?? '').toString();
        final code = (u['studentCode'] ?? u['teacherCode'] ?? '').toString();
        final status = (u['status'] ?? '').toString().toUpperCase();
        final locked = status == 'LOCKED' || status == 'DISABLED';
        final color = _roleColor(role);
        return ListTile(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => AdminUserDetail(
                id: id,
                name: name,
                code: code,
                role: role,
                username: username,
                email: u['email']?.toString(),
                phone: u['phone']?.toString(),
                className: u['className']?.toString(),
                dateOfBirth: u['dateOfBirth']?.toString(),
                gender: u['gender']?.toString(),
                address: u['address']?.toString(),
                enrollmentDate: u['enrollmentDate']?.toString(),
                guardianName: u['guardianName']?.toString(),
                guardianPhone: u['guardianPhone']?.toString(),
                mainSubject: u['mainSubject']?.toString(),
                status: status,
              ),
            ),
          ),
          leading: CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.14),
            child: Text(name.isEmpty ? '?' : name[0],
                style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          ),
          title:
              Text(name, style: const TextStyle(fontWeight: FontWeight.w500)),
          subtitle: Text('@$username${code.isEmpty ? '' : ' • $code'}',
              style: const TextStyle(
                  fontSize: 12, color: AppColors.textSecondary)),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (locked)
                const Padding(
                  padding: EdgeInsets.only(right: 4),
                  child: Icon(Icons.lock_rounded,
                      color: AppColors.error, size: 16),
                ),
              Chip(
                label: Text(_roleLabel(role),
                    style: TextStyle(fontSize: 11, color: color)),
                backgroundColor: color.withValues(alpha: 0.1),
                padding: EdgeInsets.zero,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                side: BorderSide.none,
              ),
              if (id.isNotEmpty)
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert,
                      color: AppColors.textSecondary, size: 18),
                  onSelected: (_) => _toggleLock(context, id, locked),
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      value: 'toggle',
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                            locked
                                ? Icons.lock_open_rounded
                                : Icons.lock_outline_rounded,
                            color:
                                locked ? AppColors.success : AppColors.warning),
                        title: Text(locked ? 'Mở khóa' : 'Khóa tài khoản',
                            style: TextStyle(
                                color: locked
                                    ? AppColors.success
                                    : AppColors.warning)),
                      ),
                    ),
                  ],
                )
              else
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
        _ => 'Quản trị',
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

class _AcademicYearView extends StatefulWidget {
  const _AcademicYearView();

  @override
  State<_AcademicYearView> createState() => _AcademicYearViewState();
}

class _AcademicYearViewState extends State<_AcademicYearView> {
  late final Future<List<List<Map<String, dynamic>>>> _future = Future.wait([
    sl<ApiService>().academicYears(),
    sl<ApiService>().semesters(),
  ]);

  /// Format an ISO date string into 'dd/MM/yyyy'; returns raw/empty as-is.
  String _date(Object? raw) {
    final s = (raw ?? '').toString();
    if (s.isEmpty) return '';
    final dt = DateTime.tryParse(s);
    if (dt == null) return s;
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(dt.day)}/${two(dt.month)}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<List<Map<String, dynamic>>>>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          return Center(
            child: Text('Lỗi tải năm học: ${snap.error}',
                style: const TextStyle(color: AppColors.textSecondary)),
          );
        }
        final data = snap.data ?? const [];
        final years =
            data.isNotEmpty ? data[0] : const <Map<String, dynamic>>[];
        final semesters =
            data.length > 1 ? data[1] : const <Map<String, dynamic>>[];

        // Năm học đang hoạt động: ưu tiên status ACTIVE, fallback phần tử đầu.
        final active = years.cast<Map<String, dynamic>?>().firstWhere(
              (y) => (y?['status'] ?? '').toString().toUpperCase() == 'ACTIVE',
              orElse: () => years.isNotEmpty ? years.first : null,
            );
        final others = years.where((y) => !identical(y, active)).toList();

        const semColors = [AppColors.success, AppColors.warning];

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const SectionHeader(title: 'Năm học hiện hành'),
            const SizedBox(height: 10),
            if (active == null)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Chưa có năm học',
                      style: TextStyle(color: AppColors.textSecondary)),
                ),
              )
            else
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
                              color: AppColors.success.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                                (active['status'] ?? 'ACTIVE')
                                    .toString()
                                    .toUpperCase(),
                                style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.success)),
                          ),
                          const Spacer(),
                          Text(
                              '${_date(active['startDate'])} – ${_date(active['endDate'])}',
                              style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text((active['name'] ?? active['code'] ?? '').toString(),
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 15)),
                      if (semesters.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (var i = 0; i < semesters.length; i++)
                              _SemChip(
                                (semesters[i]['code'] ??
                                        semesters[i]['name'] ??
                                        '')
                                    .toString(),
                                (semesters[i]['name'] ?? '').toString(),
                                semColors[i % semColors.length],
                              ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 20),
            const SectionHeader(title: 'Ngày nghỉ trong năm', action: 'Thêm'),
            const SizedBox(height: 10),
            const Card(
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.celebration_rounded,
                        color: AppColors.warning),
                    title: Text('Nghỉ Tết Nguyên Đán'),
                    subtitle: Text('25/01 – 04/02/2026 (11 ngày)'),
                  ),
                  Divider(height: 0),
                  ListTile(
                    leading: Icon(Icons.flag_rounded, color: AppColors.warning),
                    title: Text('Giỗ tổ Hùng Vương'),
                    subtitle: Text('18/04/2026'),
                  ),
                  Divider(height: 0),
                  ListTile(
                    leading: Icon(Icons.beach_access_rounded,
                        color: AppColors.warning),
                    title: Text('Nghỉ lễ 30/4 – 1/5'),
                    subtitle: Text('30/04 – 03/05/2026'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const SectionHeader(title: 'Lịch sử năm học'),
            const SizedBox(height: 10),
            if (others.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Không có năm học khác',
                      style: TextStyle(color: AppColors.textSecondary)),
                ),
              )
            else
              Card(
                child: Column(
                  children: [
                    for (var i = 0; i < others.length; i++) ...[
                      ListTile(
                        leading: const Icon(Icons.archive_outlined,
                            color: AppColors.textSecondary),
                        title: Text(
                            (others[i]['name'] ?? others[i]['code'] ?? '')
                                .toString()),
                        subtitle: Text((others[i]['status'] ?? '')
                            .toString()
                            .toUpperCase()),
                      ),
                      if (i < others.length - 1) const Divider(height: 0),
                    ],
                  ],
                ),
              ),
          ],
        );
      },
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
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(code,
              style: TextStyle(
                  color: color, fontWeight: FontWeight.bold, fontSize: 12)),
          Text(dates,
              style:
                  TextStyle(color: color.withValues(alpha: 0.8), fontSize: 10)),
        ],
      ),
    );
  }
}

class _ClassesView extends StatefulWidget {
  const _ClassesView();

  @override
  State<_ClassesView> createState() => _ClassesViewState();
}

class _ClassesViewState extends State<_ClassesView> {
  final _api = sl<ApiService>();
  late Future<List<Map<String, dynamic>>> _future;
  late Future<List<Map<String, dynamic>>> _teachersFuture;

  @override
  void initState() {
    super.initState();
    _future = _api.classes();
    _teachersFuture = _api.users(role: 'TEACHER');
  }

  void _reloadClasses() {
    setState(() => _future = _api.classes());
  }

  Future<void> _assignHomeroomTeacher(Map<String, dynamic> schoolClass) async {
    final teachers = await _teachersFuture;
    if (!mounted) return;
    String selectedTeacherId =
        (schoolClass['homeroomTeacherId'] ?? '').toString();
    final activeTeachers =
        teachers.where((teacher) => teacher['status'] == 'ACTIVE').toList();
    if (!activeTeachers
        .any((teacher) => teacher['id']?.toString() == selectedTeacherId)) {
      selectedTeacherId = '';
    }
    final shouldSave = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Phân công GVCN · ${schoolClass['code'] ?? ''}'),
          content: DropdownButtonFormField<String>(
            initialValue: selectedTeacherId.isEmpty ? null : selectedTeacherId,
            isExpanded: true,
            decoration: const InputDecoration(labelText: 'Giáo viên chủ nhiệm'),
            items: activeTeachers
                .map((teacher) => DropdownMenuItem(
                      value: teacher['id']?.toString(),
                      child: Text(
                        '${teacher['fullName'] ?? ''} · ${teacher['mainSubject'] ?? 'Chưa có chuyên ngành'}',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ))
                .toList(),
            onChanged: (value) =>
                setDialogState(() => selectedTeacherId = value ?? ''),
          ),
          actions: [
            if ((schoolClass['homeroomTeacherId'] ?? '').toString().isNotEmpty)
              TextButton(
                onPressed: () {
                  selectedTeacherId = '';
                  Navigator.pop(dialogContext, true);
                },
                child: const Text('Bỏ phân công'),
              ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Hủy'),
            ),
            FilledButton(
              onPressed: selectedTeacherId.isEmpty
                  ? null
                  : () => Navigator.pop(dialogContext, true),
              child: const Text('Lưu'),
            ),
          ],
        ),
      ),
    );
    if (shouldSave != true) return;
    try {
      if (selectedTeacherId.isEmpty) {
        await _api.clearHomeroomTeacher(schoolClass['id'].toString());
      } else {
        await _api.assignHomeroomTeacher(
            schoolClass['id'].toString(), selectedTeacherId);
      }
      if (!mounted) return;
      _reloadClasses();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Đã cập nhật giáo viên chủ nhiệm.'),
        behavior: SnackBarBehavior.floating,
      ));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Không thể cập nhật: $error'),
        backgroundColor: AppColors.error,
      ));
    }
  }

  String _gradeName(Object? gradeLevel) {
    final g = (gradeLevel ?? '').toString();
    if (g.isEmpty) return '';
    return 'Khối $g';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          return Center(
            child: Text('Lỗi tải lớp: ${snap.error}',
                style: const TextStyle(color: AppColors.textSecondary)),
          );
        }
        final classes = snap.data ?? const [];
        if (classes.isEmpty) {
          return const Center(
              child: Text('Chưa có lớp',
                  style: TextStyle(color: AppColors.textSecondary)));
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: classes.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (_, i) {
            final c = classes[i];
            final name = (c['name'] ?? c['code'] ?? '').toString();
            final gradeName = _gradeName(c['gradeLevel']);
            final homeroom =
                (c['homeroomTeacherName'] ?? c['homeroomTeacherId'] ?? '')
                    .toString();
            final count = (c['studentCount'] is num)
                ? (c['studentCount'] as num).toInt()
                : 0;
            return Card(
              margin: EdgeInsets.zero,
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => AdminClassDetail(
                      className: name,
                      gradeName: gradeName,
                      homeroom: homeroom,
                      studentCount: count,
                    ),
                  ),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        AppColors.adminAccent.withValues(alpha: 0.12),
                    child: Text(
                      name.isEmpty ? '?' : name,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: AppColors.adminAccent,
                            fontWeight: FontWeight.w700,
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
                    '$gradeName${homeroom.isEmpty ? '' : ' • GVCN: $homeroom'}',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: AppColors.textSecondary),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.adminAccent.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '$count HS',
                          style:
                              Theme.of(context).textTheme.labelMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.adminAccent,
                                  ),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Phân công giáo viên chủ nhiệm',
                        onPressed: () => _assignHomeroomTeacher(c),
                        icon: const Icon(Icons.manage_accounts_outlined,
                            color: AppColors.adminAccent, size: 20),
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
      },
    );
  }
}

class _SubjectsRoomsView extends StatefulWidget {
  const _SubjectsRoomsView();

  @override
  State<_SubjectsRoomsView> createState() => _SubjectsRoomsViewState();
}

class _SubjectsRoomsViewState extends State<_SubjectsRoomsView> {
  late final Future<List<List<Map<String, dynamic>>>> _future = Future.wait([
    sl<ApiService>().subjects(),
    sl<ApiService>().rooms(),
  ]);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<List<Map<String, dynamic>>>>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          return Center(
            child: Text('Lỗi tải dữ liệu: ${snap.error}',
                style: const TextStyle(color: AppColors.textSecondary)),
          );
        }
        final data = snap.data ?? const [];
        final subjects =
            data.isNotEmpty ? data[0] : const <Map<String, dynamic>>[];
        final rooms =
            data.length > 1 ? data[1] : const <Map<String, dynamic>>[];
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const SectionHeader(title: 'Môn học', action: 'Thêm môn'),
            const SizedBox(height: 10),
            Card(
              child: subjects.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(
                          child: Text('Chưa có môn học',
                              style:
                                  TextStyle(color: AppColors.textSecondary))),
                    )
                  : Column(
                      children: [
                        for (var i = 0; i < subjects.length; i++) ...[
                          _SubjectRow(
                            name: (subjects[i]['name'] ??
                                    subjects[i]['code'] ??
                                    '')
                                .toString(),
                            code: (subjects[i]['code'] ?? '').toString(),
                          ),
                          if (i < subjects.length - 1) const Divider(height: 0),
                        ],
                      ],
                    ),
            ),
            const SizedBox(height: 20),
            const SectionHeader(title: 'Phòng học', action: 'Thêm phòng'),
            const SizedBox(height: 10),
            Card(
              child: rooms.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(
                          child: Text('Chưa có phòng học',
                              style:
                                  TextStyle(color: AppColors.textSecondary))),
                    )
                  : Column(
                      children: [
                        for (var i = 0; i < rooms.length; i++) ...[
                          _RoomRow(
                            code: (rooms[i]['code'] ?? '').toString(),
                            name: (rooms[i]['name'] ?? '').toString(),
                            cap: (rooms[i]['capacity'] is num)
                                ? (rooms[i]['capacity'] as num).toInt()
                                : 0,
                          ),
                          if (i < rooms.length - 1) const Divider(height: 0),
                        ],
                      ],
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _SubjectRow extends StatelessWidget {
  const _SubjectRow({
    required this.name,
    required this.code,
  });
  final String name;
  final String code;

  @override
  Widget build(BuildContext context) {
    final initials = code.isEmpty
        ? (name.isEmpty ? '?' : name.substring(0, 1))
        : code.substring(0, code.length >= 2 ? 2 : 1);
    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.adminAccent.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(initials,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                  color: AppColors.adminAccent)),
        ),
      ),
      title: Text(name,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      subtitle: Text(code,
          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
    );
  }
}

class _RoomRow extends StatelessWidget {
  const _RoomRow({
    required this.code,
    required this.name,
    required this.cap,
  });
  final String code;
  final String name;
  final int cap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading:
          const Icon(Icons.meeting_room_outlined, color: AppColors.adminAccent),
      title: Text(code, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: name.isEmpty
          ? null
          : Text(name,
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

class _FinanceView extends StatefulWidget {
  const _FinanceView();

  @override
  State<_FinanceView> createState() => _FinanceViewState();
}

class _FinanceViewState extends State<_FinanceView> {
  late Future<List<Map<String, dynamic>>> _future =
      sl<ApiService>().feePeriods();

  void _refresh() {
    setState(() {
      _future = sl<ApiService>().feePeriods();
    });
  }

  Future<void> _generateInvoices(String id) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final created = await sl<ApiService>().generateInvoices(id);
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text('Đã phát hành ${created.length} hóa đơn'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text('Lỗi phát hành hóa đơn: $e'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          return Center(
            child: Text('Lỗi tải đợt thu: ${snap.error}',
                style: const TextStyle(color: AppColors.textSecondary)),
          );
        }
        final periods = snap.data ?? const [];
        return RefreshIndicator(
          onRefresh: () async => _refresh(),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              SectionHeader(
                title: 'Đợt thu',
                action: 'Tạo mới',
                onAction: () => openQuickCreate(
                  context,
                  role: 'ADMIN',
                  accent: AppColors.adminAccent,
                  initialType: 'FEE',
                  onCreated: _refresh,
                ),
              ),
              const SizedBox(height: 10),
              if (periods.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                      child: Text('Chưa có đợt thu',
                          style: TextStyle(color: AppColors.textSecondary))),
                ),
              ...periods.map((p) {
                final id = (p['id'] ?? '').toString();
                final code = (p['code'] ?? '').toString();
                final name = (p['name'] ?? '').toString();
                final status = (p['status'] ?? '').toString();
                final isOpen = status.toUpperCase() == 'OPEN';
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => AdminFeePeriodDetail(
                          periodId: id,
                        ),
                      ),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: (isOpen
                                ? AppColors.success
                                : AppColors.textSecondary)
                            .withValues(alpha: 0.12),
                        child: Icon(
                          isOpen
                              ? Icons.receipt_long_rounded
                              : Icons.archive_outlined,
                          color: isOpen
                              ? AppColors.success
                              : AppColors.textSecondary,
                        ),
                      ),
                      title: Text(name,
                          style: const TextStyle(fontWeight: FontWeight.w500)),
                      subtitle: Text(code,
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
                                  .withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(status,
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
          ),
        );
      },
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
                              fontSize: 12, color: AppColors.textSecondary)),
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
                icon: Icons.contrast_rounded,
                label: 'Chuyển giao diện sáng / tối',
                onTap: () => sl<ThemeController>().toggle(
                  MediaQuery.platformBrightnessOf(context),
                ),
              ),
              _AdminSettingsTile(
                icon: Icons.auto_awesome_rounded,
                label: 'Trung tâm công việc',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const MobileWorkspacePage(
                      role: 'ADMIN',
                      accent: AppColors.adminAccent,
                    ),
                  ),
                ),
              ),
              _AdminSettingsTile(
                icon: Icons.person_add_alt_1_rounded,
                label: 'Phân công giáo viên bộ môn',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (_) => const TeachingAssignmentsPage()),
                ),
              ),
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
                  MaterialPageRoute(builder: (_) => const ExamCategoriesPage()),
                ),
              ),
              _AdminSettingsTile(
                icon: Icons.school_rounded,
                label: 'Tổng kết và xét lên lớp',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const YearEndPage()),
                ),
              ),
              _AdminSettingsTile(
                icon: Icons.groups_rounded,
                label: 'Quản lý câu lạc bộ',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ClubManagementPage()),
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
                icon: Icons.account_balance_wallet_outlined,
                label: 'Thanh toán MoMo',
                onTap: () => _todoSnack(context, 'Cấu hình MoMo Sandbox'),
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
                  icon: Icons.vpn_key_outlined, label: 'JWT — Cấu hình token'),
              _SettingsItem(
                  icon: Icons.shield_outlined, label: 'Chính sách mật khẩu'),
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
          const ListTile(
            leading: Icon(Icons.info_outline_rounded,
                color: AppColors.textSecondary),
            title: Text('Phiên bản'),
            trailing:
                Text('0.1.0', style: TextStyle(color: AppColors.textSecondary)),
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
                    color: Colors.white.withValues(alpha: 0.85), fontSize: 13),
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
        const Card(
          child: Column(
            children: [
              _StatusRow(
                  label: 'Khối 10',
                  done: 6,
                  total: 6,
                  color: AppColors.success),
              Divider(height: 0),
              _StatusRow(
                  label: 'Khối 11',
                  done: 6,
                  total: 7,
                  color: AppColors.warning),
              Divider(height: 0),
              _StatusRow(
                  label: 'Khối 12',
                  done: 8,
                  total: 8,
                  color: AppColors.success),
              Divider(height: 0),
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
        const Card(
          child: Column(
            children: [
              ListTile(
                leading:
                    Icon(Icons.warning_amber_rounded, color: AppColors.error),
                title: Text('GV Trần Thị Hoa — trùng tiết 3 T2'),
                subtitle: Text('10A1 vs 8A1 — cần đổi GV hoặc tiết',
                    style: TextStyle(fontSize: 11)),
              ),
              Divider(height: 0),
              ListTile(
                leading:
                    Icon(Icons.warning_amber_rounded, color: AppColors.error),
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
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: LinearProgressIndicator(
        value: done / total,
        color: color,
        backgroundColor: AppColors.divider,
        minHeight: 5,
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
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
    return const LiveNotificationAction(
        accent: AppColors.adminAccent, padding: 8);
  }
}
