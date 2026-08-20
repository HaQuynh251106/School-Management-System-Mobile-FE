import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/network/api_error_message.dart';
import '../../../../core/network/api_service.dart';
import '../../../../shared/widgets/accent_tab_bar.dart';
import '../../../../shared/widgets/notification_center.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../../shared/widgets/adaptive_role_scaffold.dart';
import '../../../../shared/widgets/quick_create.dart';
import '../../../../shared/widgets/real_dashboard_panel.dart';
import '../../../../shared/widgets/theme_mode_tile.dart';
import '../../../../shared/utils/vi_date_format.dart';
import '../../../accountant/presentation/pages/accountant_home.dart';
import '../../../academic_staff/presentation/pages/academic_plan_progress_page.dart';
import '../../../academic_staff/presentation/pages/academic_structure_workflow_page.dart';
import '../../../academic_staff/presentation/pages/exam_management_page.dart';
import '../../../academic_staff/presentation/pages/timetable_operations_page.dart';
import '../../../academic_staff/presentation/pages/year_end_management_page.dart';
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
import 'user_import_page.dart';
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
              role: 'ADMIN',
              accent: AppColors.adminAccent,
            )
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
          bottom: const AccentTabBar(
            accent: AppColors.adminAccent,
            tabs: [
              Tab(text: 'Tổng quan'),
              Tab(text: 'Báo cáo'),
              Tab(text: 'Nhật ký'),
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
    setState(() {
      _future = sl<ApiService>().dashboard();
    });
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
                const Text(
                  'Không thể tải tổng quan hệ thống',
                  textAlign: TextAlign.center,
                ),
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
                  switch (target) {
                    case 'users':
                      widget.onNavigate(1);
                    case 'finance':
                    case 'reconciliation':
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const FinanceOperationsPage(),
                        ),
                      );
                    case 'timetable':
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const TimetableOperationsPage(),
                        ),
                      );
                    case 'exams':
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ExamManagementPage(),
                        ),
                      );
                    default:
                      widget.onNavigate(2);
                  }
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

class _AuditLogView extends StatefulWidget {
  const _AuditLogView();

  @override
  State<_AuditLogView> createState() => _AuditLogViewState();
}

class _AuditLogViewState extends State<_AuditLogView> {
  final _search = TextEditingController();
  late Future<Map<String, dynamic>> _future = _load();

  Future<Map<String, dynamic>> _load() =>
      sl<ApiService>().auditLogsPage(query: _search.text, size: 100);

  void _reload() => setState(() => _future = _load());

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
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
                  controller: _search,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => _reload(),
                  decoration: InputDecoration(
                    hintText: 'Tìm người thực hiện hoặc nội dung',
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
                icon: const Icon(Icons.refresh_rounded),
                tooltip: 'Làm mới',
                onPressed: _reload,
              ),
            ],
          ),
        ),
        Expanded(
          child: FutureBuilder<Map<String, dynamic>>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(
                  child: FilledButton.icon(
                    onPressed: _reload,
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Tải lại lịch sử'),
                  ),
                );
              }
              final rows = (snapshot.data?['items'] as List? ?? const [])
                  .whereType<Map>()
                  .map((item) => item.cast<String, dynamic>())
                  .toList();
              if (rows.isEmpty) {
                return const Center(
                  child: Text('Chưa có thay đổi quan trọng phù hợp'),
                );
              }
              return RefreshIndicator(
                onRefresh: () async => _reload(),
                child: ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: rows.length,
                  separatorBuilder: (_, __) => const Divider(height: 0),
                  itemBuilder: (_, i) {
                    final row = rows[i];
                    final action = '${row['action'] ?? ''}';
                    final color = _actionColor(action);
                    final actor = '${row['actorName'] ?? 'Hệ thống'}';
                    final detail = '${row['detail'] ?? ''}'.trim();
                    final entity = '${row['entityType'] ?? ''}'.trim();
                    return ListTile(
                      leading: CircleAvatar(
                        radius: 18,
                        backgroundColor: color.withValues(alpha: 0.12),
                        child: Icon(
                          _actionIcon(action),
                          color: color,
                          size: 18,
                        ),
                      ),
                      title: Text(
                        detail.isEmpty ? _actionLabel(action) : detail,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        [actor, if (entity.isNotEmpty) entity].join(' · '),
                      ),
                      trailing: Text(
                        formatViDateTime(row['createdAt']),
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  IconData _actionIcon(String action) {
    if (action.startsWith('GRADE_')) return Icons.grade_rounded;
    if (action.startsWith('PAYMENT')) return Icons.receipt_long_rounded;
    if (action == 'ATTENDANCE_CHANGE') return Icons.fact_check_rounded;
    if (action == 'TIMETABLE_CHANGE') return Icons.calendar_month_rounded;
    if (action == 'EXAM_CHANGE') return Icons.quiz_rounded;
    if (action.startsWith('USER_')) return Icons.manage_accounts_rounded;
    if (action == 'DELETE') return Icons.delete_outline;
    if (action == 'EXPORT') return Icons.file_download_outlined;
    return Icons.history_rounded;
  }

  Color _actionColor(String action) {
    if (action == 'PAYMENT_CONFIRMED' || action == 'GRADE_CREATE') {
      return AppColors.success;
    }
    if (action == 'PAYMENT_REJECTED' ||
        action == 'DELETE' ||
        action == 'USER_SECURITY') {
      return AppColors.error;
    }
    if (action == 'PAYMENT_REFUND' || action == 'GRADE_UPDATE') {
      return AppColors.warning;
    }
    return AppColors.adminAccent;
  }

  String _actionLabel(String action) => switch (action) {
    'GRADE_CREATE' => 'Thêm điểm',
    'GRADE_UPDATE' => 'Sửa điểm',
    'PAYMENT_CONFIRMED' => 'Xác nhận thanh toán',
    'PAYMENT_REJECTED' => 'Từ chối thanh toán',
    'PAYMENT_REFUND' => 'Hoàn tiền',
    'FINANCE_CHANGE' => 'Thay đổi khoản thu',
    'ATTENDANCE_CHANGE' => 'Sửa điểm danh',
    'TIMETABLE_CHANGE' => 'Thay đổi thời khóa biểu',
    'ACADEMIC_PLAN' => 'Thay đổi kế hoạch đào tạo',
    'ACADEMIC_STRUCTURE' => 'Thay đổi cơ cấu năm học',
    'YEAR_END' => 'Tổng kết năm học',
    'EXAM_CHANGE' => 'Thay đổi kỳ thi',
    'USER_CHANGE' => 'Thay đổi người dùng',
    'USER_SECURITY' => 'Thay đổi bảo mật',
    'ASSIGNMENT_CHANGE' => 'Thay đổi bài tập',
    'LEAVE_CHANGE' => 'Xử lý đơn nghỉ',
    'CLUB_CHANGE' => 'Thay đổi câu lạc bộ',
    'ANNOUNCEMENT' => 'Phát hành thông báo',
    'CREATE' => 'Tạo dữ liệu mới',
    'UPDATE' => 'Cập nhật dữ liệu',
    'DELETE' => 'Xóa dữ liệu',
    'PAYMENT' => 'Cập nhật thanh toán',
    'EXPORT' => 'Xuất báo cáo',
    _ => 'Thay đổi quan trọng',
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
  final _search = TextEditingController();
  bool _searching = false;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

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
          title: _searching
              ? TextField(
                  controller: _search,
                  autofocus: true,
                  style: const TextStyle(color: Colors.white),
                  cursorColor: Colors.white,
                  decoration: const InputDecoration(
                    hintText: 'Tìm tên, tài khoản hoặc mã',
                    hintStyle: TextStyle(color: Colors.white70),
                    border: InputBorder.none,
                  ),
                  onChanged: (_) => setState(() {}),
                )
              : const Text('Quản lý người dùng'),
          backgroundColor: AppColors.adminAccent,
          actions: [
            IconButton(
              icon: Icon(_searching ? Icons.close_rounded : Icons.search),
              tooltip: _searching ? 'Đóng tìm kiếm' : 'Tìm người dùng',
              onPressed: () => setState(() {
                _searching = !_searching;
                if (!_searching) _search.clear();
              }),
            ),
            IconButton(
              icon: const Icon(Icons.upload_file_outlined),
              tooltip: 'Import Excel',
              onPressed: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const UserImportPage()),
                );
                _refresh();
              },
            ),
            const _AdminNotiAction(),
          ],
          bottom: const AccentTabBar(
            accent: AppColors.adminAccent,
            isScrollable: true,
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
          foregroundColor: Colors.white,
        ),
        body: FutureBuilder<List<Map<String, dynamic>>>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snap.hasError) {
              return Center(
                child: Text(
                  apiErrorMessage(
                    snap.error,
                    fallback: 'Không thể tải danh sách người dùng.',
                  ),
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              );
            }
            final query = _search.text.trim().toLowerCase();
            final source = snap.data ?? const <Map<String, dynamic>>[];
            final all = query.isEmpty
                ? source
                : source.where((user) {
                    final haystack = [
                      user['fullName'],
                      user['username'],
                      user['userCode'],
                      user['studentCode'],
                      user['teacherCode'],
                    ].whereType<Object>().join(' ').toLowerCase();
                    return haystack.contains(query);
                  }).toList();
            return TabBarView(
              children: [
                _UserList(users: all, onChanged: _refresh),
                _UserList(
                  users: all.where((u) => u['role'] == 'TEACHER').toList(),
                  onChanged: _refresh,
                ),
                _UserList(
                  users: all.where((u) => u['role'] == 'STUDENT').toList(),
                  onChanged: _refresh,
                ),
                _UserList(
                  users: all.where((u) => u['role'] == 'PARENT').toList(),
                  onChanged: _refresh,
                ),
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
    } catch (error) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            apiErrorMessage(
              error,
              fallback: 'Không thể cập nhật tài khoản. Vui lòng thử lại.',
            ),
          ),
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
        child: Text(
          'Không có người dùng phù hợp',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
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
        final color = _roleColor(context, role);
        final colors = Theme.of(context).colorScheme;
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
            child: Text(
              name.isEmpty ? '?' : name[0],
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
          ),
          title: Text(
            name,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          subtitle: Text(
            '@$username${code.isEmpty ? '' : ' • $code'}',
            style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (locked)
                const Padding(
                  padding: EdgeInsets.only(right: 4),
                  child: Icon(
                    Icons.lock_rounded,
                    color: AppColors.error,
                    size: 16,
                  ),
                ),
              Chip(
                label: Text(
                  _roleLabel(role),
                  style: TextStyle(fontSize: 11, color: color),
                ),
                backgroundColor: color.withValues(alpha: 0.1),
                padding: EdgeInsets.zero,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                side: BorderSide.none,
              ),
              if (id.isNotEmpty)
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert,
                    color: colors.onSurfaceVariant,
                    size: 18,
                  ),
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
                          color: locked ? AppColors.success : AppColors.warning,
                        ),
                        title: Text(
                          locked ? 'Mở khóa' : 'Khóa tài khoản',
                          style: TextStyle(
                            color: locked
                                ? AppColors.success
                                : AppColors.warning,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              else
                Icon(
                  Icons.chevron_right_rounded,
                  color: colors.onSurfaceVariant,
                  size: 18,
                ),
            ],
          ),
        );
      },
    );
  }

  Color _roleColor(BuildContext context, String role) =>
      AppColors.adaptiveAccent(context, switch (role) {
        'TEACHER' => AppColors.teacherAccent,
        'STUDENT' => AppColors.studentAccent,
        'PARENT' => AppColors.parentAccent,
        _ => AppColors.adminAccent,
      });

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
          bottom: const AccentTabBar(
            accent: AppColors.adminAccent,
            isScrollable: true,
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
    sl<ApiService>().announcements(),
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
            child: Text(
              apiErrorMessage(
                snap.error,
                fallback: 'Không thể tải dữ liệu năm học.',
              ),
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          );
        }
        final data = snap.data ?? const [];
        final years = data.isNotEmpty
            ? data[0]
            : const <Map<String, dynamic>>[];
        final semesters = data.length > 1
            ? data[1]
            : const <Map<String, dynamic>>[];
        final holidays = data.length > 2
            ? data[2].where((item) => item['category'] == 'HOLIDAY').toList()
            : const <Map<String, dynamic>>[];

        // Năm học đang hoạt động: ưu tiên status ACTIVE, fallback phần tử đầu.
        final active = years.cast<Map<String, dynamic>?>().firstWhere(
          (y) => (y?['status'] ?? '').toString().toUpperCase() == 'ACTIVE',
          orElse: () => years.isNotEmpty ? years.first : null,
        );
        final others = years.where((y) => !identical(y, active)).toList();
        final activeSemesters =
            active == null
                  ? const <Map<String, dynamic>>[]
                  : semesters
                        .where(
                          (semester) =>
                              semester['academicYearId'] == active['id'],
                        )
                        .toList()
              ..sort(
                (first, second) => ((first['sequence'] as num?)?.toInt() ?? 0)
                    .compareTo((second['sequence'] as num?)?.toInt() ?? 0),
              );

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
                  child: Text(
                    'Chưa có năm học',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
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
                              horizontal: 10,
                              vertical: 4,
                            ),
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
                                color: AppColors.success,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            formatViDateRange(
                              active['startDate'],
                              active['endDate'],
                            ),
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        (active['name'] ?? active['code'] ?? '').toString(),
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      if (activeSemesters.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (var i = 0; i < activeSemesters.length; i++)
                              _SemChip(
                                (activeSemesters[i]['code'] ??
                                        activeSemesters[i]['name'] ??
                                        '')
                                    .toString(),
                                (activeSemesters[i]['name'] ?? '').toString(),
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
            const SectionHeader(title: 'Ngày nghỉ đã công bố'),
            const SizedBox(height: 10),
            if (holidays.isEmpty)
              const Card(
                child: ListTile(
                  leading: Icon(Icons.event_available_outlined),
                  title: Text('Chưa có ngày nghỉ được công bố'),
                ),
              )
            else
              Card(
                child: Column(
                  children: [
                    for (var i = 0; i < holidays.length; i++) ...[
                      ListTile(
                        leading: const Icon(
                          Icons.celebration_rounded,
                          color: AppColors.warning,
                        ),
                        title: Text(
                          (holidays[i]['title'] ?? 'Ngày nghỉ').toString(),
                        ),
                        subtitle: Text(
                          formatViDateRange(
                            holidays[i]['holidayStartDate'],
                            holidays[i]['holidayEndDate'],
                          ),
                        ),
                      ),
                      if (i < holidays.length - 1) const Divider(height: 0),
                    ],
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
                  child: Text(
                    'Không có năm học khác',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              )
            else
              Card(
                child: Column(
                  children: [
                    for (var i = 0; i < others.length; i++) ...[
                      ListTile(
                        leading: const Icon(
                          Icons.archive_outlined,
                          color: AppColors.textSecondary,
                        ),
                        title: Text(
                          (others[i]['name'] ?? others[i]['code'] ?? '')
                              .toString(),
                        ),
                        subtitle: Text(
                          (others[i]['status'] ?? '').toString().toUpperCase(),
                        ),
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
          Text(
            code,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          Text(
            dates,
            style: TextStyle(color: color.withValues(alpha: 0.8), fontSize: 10),
          ),
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
    setState(() {
      _future = _api.classes();
    });
  }

  Future<void> _openClassForm([Map<String, dynamic>? schoolClass]) async {
    final editing = schoolClass != null;
    final academicYears = await _api.academicYears();
    if (!mounted) return;
    if (academicYears.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cần tạo năm học trước khi tạo lớp.')),
      );
      return;
    }
    var academicYearId = schoolClass?['academicYearId']?.toString() ?? '';
    if (!academicYears.any(
      (year) => year['id']?.toString() == academicYearId,
    )) {
      final active = academicYears.where(
        (year) => year['status']?.toString() == 'ACTIVE',
      );
      academicYearId =
          (active.isNotEmpty ? active.first : academicYears.first)['id']
              .toString();
    }
    final codeController = TextEditingController(
      text: schoolClass?['code']?.toString() ?? '',
    );
    final nameController = TextEditingController(
      text: schoolClass?['name']?.toString() ?? '',
    );
    final gradeController = TextEditingController(
      text: schoolClass?['gradeLevel']?.toString() ?? '',
    );
    final capacityController = TextEditingController(
      text: schoolClass?['capacity']?.toString() ?? '40',
    );
    final formKey = GlobalKey<FormState>();

    final shouldSave = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(editing ? 'Sửa lớp học' : 'Tạo lớp học'),
          content: SizedBox(
            width: 420,
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: academicYearId,
                      isExpanded: true,
                      decoration: const InputDecoration(labelText: 'Năm học'),
                      items: academicYears
                          .map(
                            (year) => DropdownMenuItem(
                              value: year['id']?.toString(),
                              child: Text(
                                (year['name'] ?? year['code'] ?? '').toString(),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (value) => setDialogState(
                        () => academicYearId = value ?? academicYearId,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: codeController,
                      autofocus: true,
                      textCapitalization: TextCapitalization.characters,
                      decoration: const InputDecoration(
                        labelText: 'Mã lớp',
                        hintText: 'Ví dụ: 10A11',
                      ),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? 'Vui lòng nhập mã lớp'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Tên hiển thị',
                        hintText: 'Để trống sẽ dùng mã lớp',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: gradeController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Khối'),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? 'Vui lòng nhập khối'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: capacityController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Sĩ số tối đa',
                      ),
                      validator: (value) {
                        final capacity = int.tryParse(value?.trim() ?? '');
                        return capacity == null || capacity <= 0
                            ? 'Sĩ số phải lớn hơn 0'
                            : null;
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Hủy'),
            ),
            FilledButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.pop(dialogContext, true);
                }
              },
              child: Text(editing ? 'Lưu thay đổi' : 'Tạo lớp'),
            ),
          ],
        ),
      ),
    );

    if (shouldSave != true) return;
    final code = codeController.text.trim().toUpperCase();
    final name = nameController.text.trim();
    final payload = <String, dynamic>{
      'code': code,
      'name': name.isEmpty ? code : name,
      'gradeLevel': gradeController.text.trim(),
      'capacity': int.parse(capacityController.text.trim()),
      'academicYearId': academicYearId,
      if (!editing && schoolClass?['homeroomTeacherId'] != null)
        'homeroomTeacherId': schoolClass!['homeroomTeacherId'],
      if (schoolClass?['studyShift'] != null)
        'studyShift': schoolClass!['studyShift'],
      if (schoolClass?['roomId'] != null) 'roomId': schoolClass!['roomId'],
    };

    try {
      if (editing) {
        await _api.updateClass(schoolClass['id'].toString(), payload);
      } else {
        await _api.createClass(payload);
      }
      if (!mounted) return;
      _reloadClasses();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(editing ? 'Đã cập nhật lớp.' : 'Đã tạo lớp $code.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            apiErrorMessage(
              error,
              fallback: 'Không thể lưu lớp học. Vui lòng thử lại.',
            ),
          ),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _deleteClass(Map<String, dynamic> schoolClass) async {
    final code = (schoolClass['code'] ?? '').toString();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Xóa lớp học?'),
        content: Text(
          'Bạn sắp xóa lớp $code. Chỉ có thể xóa lớp chưa có học sinh, lịch học hoặc dữ liệu liên quan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Xóa lớp'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await _api.deleteClass(schoolClass['id'].toString());
      if (!mounted) return;
      _reloadClasses();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Đã xóa lớp $code.')));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            apiErrorMessage(
              error,
              fallback:
                  'Không thể xóa lớp học. Hãy kiểm tra dữ liệu liên quan.',
            ),
          ),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _assignHomeroomTeacher(Map<String, dynamic> schoolClass) async {
    final teachers = await _teachersFuture;
    if (!mounted) return;
    String selectedTeacherId = (schoolClass['homeroomTeacherId'] ?? '')
        .toString();
    final activeTeachers = teachers
        .where((teacher) => teacher['status'] == 'ACTIVE')
        .toList();
    if (!activeTeachers.any(
      (teacher) => teacher['id']?.toString() == selectedTeacherId,
    )) {
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
                .map(
                  (teacher) => DropdownMenuItem(
                    value: teacher['id']?.toString(),
                    child: Text(
                      '${teacher['fullName'] ?? ''} · ${teacher['mainSubject'] ?? 'Chưa có chuyên ngành'}',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
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
          schoolClass['id'].toString(),
          selectedTeacherId,
        );
      }
      if (!mounted) return;
      _reloadClasses();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã cập nhật giáo viên chủ nhiệm.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            apiErrorMessage(
              error,
              fallback:
                  'Không thể cập nhật giáo viên chủ nhiệm. Vui lòng thử lại.',
            ),
          ),
          backgroundColor: AppColors.error,
        ),
      );
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
            child: Text(
              apiErrorMessage(
                snap.error,
                fallback: 'Không thể tải danh sách lớp.',
              ),
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          );
        }
        final classes = snap.data ?? const [];
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${classes.length} lớp học',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  FilledButton.icon(
                    onPressed: _openClassForm,
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Tạo lớp'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: classes.isEmpty
                  ? const Center(
                      child: Text(
                        'Chưa có lớp',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: classes.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (_, i) {
                        final c = classes[i];
                        final name = (c['name'] ?? c['code'] ?? '').toString();
                        final gradeName = _gradeName(c['gradeLevel']);
                        final homeroom =
                            (c['homeroomTeacherName'] ??
                                    c['homeroomTeacherId'] ??
                                    '')
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
                                  classId: c['id'].toString(),
                                  className: name,
                                  gradeName: gradeName,
                                  homeroom: homeroom,
                                  studentCount: count,
                                ),
                              ),
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: AppColors.adminAccent
                                    .withValues(alpha: 0.12),
                                child: Text(
                                  name.isEmpty ? '?' : name,
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.labelMedium
                                      ?.copyWith(
                                        color: AppColors.adminAccent,
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                              ),
                              title: Text(
                                name,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                              subtitle: Text(
                                '$gradeName${homeroom.isEmpty ? '' : ' • GVCN: $homeroom'}',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: AppColors.textSecondary),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.adminAccent.withValues(
                                        alpha: 0.1,
                                      ),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      '$count HS',
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.adminAccent,
                                          ),
                                    ),
                                  ),
                                  PopupMenuButton<String>(
                                    tooltip: 'Thao tác lớp',
                                    onSelected: (action) {
                                      if (action == 'homeroom') {
                                        _assignHomeroomTeacher(c);
                                      } else if (action == 'edit') {
                                        _openClassForm(c);
                                      } else if (action == 'delete') {
                                        _deleteClass(c);
                                      }
                                    },
                                    itemBuilder: (_) => const [
                                      PopupMenuItem(
                                        value: 'homeroom',
                                        child: ListTile(
                                          leading: Icon(
                                            Icons.manage_accounts_outlined,
                                          ),
                                          title: Text('Phân công GVCN'),
                                        ),
                                      ),
                                      PopupMenuItem(
                                        value: 'edit',
                                        child: ListTile(
                                          leading: Icon(Icons.edit_outlined),
                                          title: Text('Sửa lớp'),
                                        ),
                                      ),
                                      PopupMenuItem(
                                        value: 'delete',
                                        child: ListTile(
                                          leading: Icon(
                                            Icons.delete_outline,
                                            color: AppColors.error,
                                          ),
                                          title: Text('Xóa lớp'),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Icon(
                                    Icons.chevron_right_rounded,
                                    color: AppColors.textSecondary,
                                    size: 18,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
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
            child: Text(
              apiErrorMessage(
                snap.error,
                fallback: 'Không thể tải danh mục môn và phòng học.',
              ),
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          );
        }
        final data = snap.data ?? const [];
        final subjects = data.isNotEmpty
            ? data[0]
            : const <Map<String, dynamic>>[];
        final rooms = data.length > 1
            ? data[1]
            : const <Map<String, dynamic>>[];
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
                        child: Text(
                          'Chưa có môn học',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ),
                    )
                  : Column(
                      children: [
                        for (var i = 0; i < subjects.length; i++) ...[
                          _SubjectRow(
                            name:
                                (subjects[i]['name'] ??
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
                        child: Text(
                          'Chưa có phòng học',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ),
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
  const _SubjectRow({required this.name, required this.code});
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
          child: Text(
            initials,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 11,
              color: AppColors.adminAccent,
            ),
          ),
        ),
      ),
      title: Text(
        name,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        code,
        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
      ),
    );
  }
}

class _RoomRow extends StatelessWidget {
  const _RoomRow({required this.code, required this.name, required this.cap});
  final String code;
  final String name;
  final int cap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(
        Icons.meeting_room_outlined,
        color: AppColors.adminAccent,
      ),
      title: Text(code, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: name.isEmpty
          ? null
          : Text(
              name,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
      trailing: Text(
        '$cap chỗ',
        style: const TextStyle(
          fontSize: 12,
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _FinanceView extends StatefulWidget {
  const _FinanceView();

  @override
  State<_FinanceView> createState() => _FinanceViewState();
}

class _FinanceViewState extends State<_FinanceView> {
  late Future<List<Map<String, dynamic>>> _future = sl<ApiService>()
      .feePeriods();

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
    } catch (error) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            apiErrorMessage(
              error,
              fallback: 'Không thể phát hành hóa đơn. Vui lòng thử lại.',
            ),
          ),
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
            child: Text(
              apiErrorMessage(
                snap.error,
                fallback: 'Không thể tải danh sách đợt thu.',
              ),
              style: const TextStyle(color: AppColors.textSecondary),
            ),
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
                    child: Text(
                      'Chưa có đợt thu',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
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
                        builder: (_) => AdminFeePeriodDetail(periodId: id),
                      ),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor:
                            (isOpen
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
                      title: Text(
                        name,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      subtitle: Text(
                        code,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  (isOpen
                                          ? AppColors.success
                                          : AppColors.textSecondary)
                                      .withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              status,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: isOpen
                                    ? AppColors.success
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right_rounded,
                            color: AppColors.textSecondary,
                            size: 18,
                          ),
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
    final colors = Theme.of(context).colorScheme;
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
            color: colors.surface,
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.adminAccent,
                  child: Icon(
                    Icons.admin_panel_settings_rounded,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.fullName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: colors.onSurface,
                        ),
                      ),
                      Text(
                        user.email ?? user.username,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? colors.onSurface.withValues(alpha: .76)
                              : colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          _AdminSettingsGroup(
            title: 'Vận hành nhà trường',
            children: [
              const ThemeModeTile(accent: AppColors.adminAccent),
              _AdminSettingsTile(
                icon: Icons.account_tree_rounded,
                label: 'Tổ chức năm học và phân lớp',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const AcademicStructureWorkflowPage(),
                  ),
                ),
              ),
              _AdminSettingsTile(
                icon: Icons.person_add_alt_1_rounded,
                label: 'Phân công giáo viên bộ môn',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const TeachingAssignmentsPage(),
                  ),
                ),
              ),
              _AdminSettingsTile(
                icon: Icons.insights_rounded,
                label: 'Kế hoạch và tiến độ đào tạo',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const AcademicPlanProgressPage(),
                  ),
                ),
              ),
              _AdminSettingsTile(
                icon: Icons.auto_awesome_motion_rounded,
                label: 'Xếp và công bố thời khóa biểu',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const TimetableOperationsPage(),
                  ),
                ),
              ),
              _AdminSettingsTile(
                icon: Icons.event_note_rounded,
                label: 'Kỳ thi và lịch coi thi',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ExamManagementPage()),
                ),
              ),
              _AdminSettingsTile(
                icon: Icons.rule_folder_rounded,
                label: 'Loại điểm và hệ số',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ExamCategoriesPage()),
                ),
              ),
              _AdminSettingsTile(
                icon: Icons.school_rounded,
                label: 'Tổng kết năm học',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const YearEndManagementPage(),
                  ),
                ),
              ),
              _AdminSettingsTile(
                icon: Icons.account_balance_wallet_outlined,
                label: 'Tài chính và đối soát',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const FinanceOperationsPage(),
                  ),
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
                label: 'Mẫu thông báo',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const NotificationTemplatesPage(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ListTile(
            leading: Icon(
              Icons.info_outline_rounded,
              color: colors.onSurfaceVariant,
            ),
            title: const Text('Phiên bản'),
            trailing: Text(
              '0.1.0',
              style: TextStyle(color: colors.onSurfaceVariant),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.logout_rounded, color: AppColors.error),
            title: const Text(
              'Đăng xuất',
              style: TextStyle(color: AppColors.error),
            ),
            onTap: () => _confirmLogout(context),
          ),
          const SizedBox(height: 32),
        ],
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
            child: const Text(
              'Đăng xuất',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

// =================== TIMETABLE HUB (Cơ cấu sub-tab) ===================

class _TimetableHubView extends StatelessWidget {
  const _TimetableHubView();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Thời khóa biểu',
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
        Text(
          'Phân công giáo viên trước, xem phương án tự động rồi mới phát hành lịch chính thức.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 20),
        _TimetableActionCard(
          icon: Icons.person_add_alt_1_rounded,
          title: '1. Phân công giảng dạy',
          subtitle: 'Chọn giáo viên, môn, lớp và số tiết trong học kỳ.',
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const TeachingAssignmentsPage()),
          ),
        ),
        _TimetableActionCard(
          icon: Icons.auto_awesome_motion_rounded,
          title: '2. Tự xếp và công bố',
          subtitle:
              'Kiểm tra đầu vào, xem trước xung đột, tạo bản nháp và phát hành.',
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const TimetableOperationsPage()),
          ),
        ),
        _TimetableActionCard(
          icon: Icons.tune_rounded,
          title: '3. Điều chỉnh thủ công',
          subtitle: 'Chỉ dùng khi cần sửa từng tiết sau khi xem phương án.',
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const TimetableSchedulingPage()),
          ),
        ),
      ],
    );
  }
}

class _TimetableActionCard extends StatelessWidget {
  const _TimetableActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Card(
      child: ListTile(
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.adminAccent.withValues(alpha: .1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.adminAccent),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: onTap,
      ),
    ),
  );
}

// =================== SETTINGS HELPERS ===================

class _AdminSettingsGroup extends StatelessWidget {
  const _AdminSettingsGroup({required this.title, required this.children});
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              letterSpacing: 0.8,
            ),
          ),
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
    final colors = Theme.of(context).colorScheme;
    final iconColor = AppColors.adaptiveAccent(context, AppColors.adminAccent);
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(label),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: colors.onSurfaceVariant,
      ),
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
      accent: AppColors.adminAccent,
      padding: 8,
    );
  }
}
