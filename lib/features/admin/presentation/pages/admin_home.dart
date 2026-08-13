import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_controller.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/network/realtime_service.dart';
import '../../../../shared/widgets/notification_center.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../../shared/widgets/stat_card.dart';
import '../../../../shared/widgets/adaptive_role_scaffold.dart';
import '../../../../shared/widgets/mobile_workspace_page.dart';
import '../../../../shared/widgets/quick_create.dart';
import '../../../../shared/widgets/role_page_intro.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../auth/presentation/pages/change_password_page.dart';
import '../../../academic_staff/presentation/pages/academic_plan_progress_page.dart';
import '../../../academic_staff/presentation/pages/academic_structure_workflow_page.dart';
import '../../../academic_staff/presentation/pages/exam_auto_plan_page.dart';
import '../../../academic_staff/presentation/pages/timetable_operations_page.dart';
import '../../../accountant/presentation/pages/accountant_home.dart';
import 'class_detail.dart';
import 'exam_categories_page.dart';
import 'fee_period_detail.dart';
import 'notification_templates_page.dart';
import 'teaching_assignments_page.dart';
import 'timetable_scheduling.dart';
import 'year_end_page.dart';
import 'user_detail.dart';
import 'user_import_page.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  int _tab = 0;
  int _structureTab = 0;
  int _structureRevision = 0;
  final _usersTabKey = GlobalKey<_UsersTabState>();

  void _openStructure(int tab) => setState(() {
        _structureTab = tab;
        _structureRevision++;
        _tab = 2;
      });

  @override
  Widget build(BuildContext context) {
    return AdaptiveRoleScaffold(
      index: _tab,
      onSelected: (i) => setState(() => _tab = i),
      accent: AppColors.adminAccent,
      floatingActionButton: _tab == 1
          ? QuickCreateButton(
              role: 'ADMIN',
              accent: AppColors.adminAccent,
              userOnly: true,
              onCreated: () => _usersTabKey.currentState?._refresh(),
            )
          : null,
      pages: [
        _DashboardTab(
          onOpenUsers: () => setState(() => _tab = 1),
          onOpenClasses: () => _openStructure(1),
          onOpenFinance: () => _openStructure(4),
        ),
        _UsersTab(key: _usersTabKey),
        _StructureTab(
          key: ValueKey(_structureRevision),
          initialIndex: _structureTab,
        ),
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
  const _DashboardTab({
    required this.onOpenUsers,
    required this.onOpenClasses,
    required this.onOpenFinance,
  });
  final VoidCallback onOpenUsers;
  final VoidCallback onOpenClasses;
  final VoidCallback onOpenFinance;

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
              Tab(text: 'Lịch sử'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _OverviewView(
              onOpenUsers: onOpenUsers,
              onOpenClasses: onOpenClasses,
              onOpenFinance: onOpenFinance,
            ),
            const _ReportsView(),
            const _AuditLogView(),
          ],
        ),
      ),
    );
  }
}

class _OverviewView extends StatefulWidget {
  const _OverviewView({
    required this.onOpenUsers,
    required this.onOpenClasses,
    required this.onOpenFinance,
  });
  final VoidCallback onOpenUsers;
  final VoidCallback onOpenClasses;
  final VoidCallback onOpenFinance;

  @override
  State<_OverviewView> createState() => _OverviewViewState();
}

class _OverviewViewState extends State<_OverviewView> {
  late Future<Map<String, dynamic>> _future = sl<ApiService>().dashboard();

  void _refresh() => setState(() => _future = sl<ApiService>().dashboard());

  String _value(Map<String, dynamic> metric) {
    final value = (metric['value'] as num?)?.toDouble() ?? 0;
    return switch ('${metric['format']}') {
      'PERCENT' || 'PERCENT_OR_EMPTY' => '${value.toStringAsFixed(1)}%',
      'CURRENCY' => '${value.toStringAsFixed(0)} ₫',
      'DECIMAL_1' => value.toStringAsFixed(1),
      _ => value.toStringAsFixed(value == value.roundToDouble() ? 0 : 1),
    };
  }

  IconData _icon(String key) => switch (key) {
        'users' => Icons.people_rounded,
        'classes' => Icons.class_rounded,
        'attendance' => Icons.fact_check_rounded,
        'alerts' => Icons.warning_amber_rounded,
        _ => Icons.analytics_rounded,
      };

  Color _color(String tone) => switch (tone) {
        'red' => AppColors.error,
        'orange' => AppColors.warning,
        'green' => AppColors.success,
        'violet' => AppColors.adminAccent,
        _ => AppColors.primary,
      };

  VoidCallback _shortcut(BuildContext context, String key) => switch (key) {
        'users' => widget.onOpenUsers,
        'classes' => widget.onOpenClasses,
        'attendance' => () => DefaultTabController.of(context).animateTo(1),
        'alerts' => widget.onOpenFinance,
        _ => () {},
      };

  @override
  Widget build(BuildContext context) {
    final user = (context.read<AuthBloc>().state as AuthAuthenticated).user;
    return FutureBuilder<Map<String, dynamic>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: FilledButton.icon(
              onPressed: _refresh,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Tải lại tổng quan'),
            ),
          );
        }
        final metrics = (snapshot.data?['metrics'] as List? ?? const [])
            .cast<Map<String, dynamic>>();
        return RefreshIndicator(
          onRefresh: () async => _refresh(),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              RolePageIntro(
                title: 'Xin chào, ${user.fullName}',
                subtitle: '',
                accent: AppColors.adminAccent,
                icon: Icons.admin_panel_settings_rounded,
              ),
              const SizedBox(height: 20),
              const SectionHeader(title: 'Thông tin cần theo dõi'),
              const SizedBox(height: 12),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1.35,
                children: metrics
                    .map((metric) => StatCard(
                          label: '${metric['label']}',
                          value: _value(metric),
                          icon: _icon('${metric['key']}'),
                          color: _color('${metric['tone']}'),
                          onTap: _shortcut(context, '${metric['key']}'),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 20),
              const SectionHeader(title: 'Việc cần chú ý'),
              const SizedBox(height: 8),
              Card(
                child: Column(
                  children: metrics
                      .where((metric) =>
                          metric['key'] == 'attendance' ||
                          metric['key'] == 'alerts')
                      .map((metric) => ListTile(
                            onTap: _shortcut(context, '${metric['key']}'),
                            leading: Icon(_icon('${metric['key']}'),
                                color: _color('${metric['tone']}')),
                            title:
                                Text('${metric['label']}: ${_value(metric)}'),
                            subtitle: Text('${metric['hint'] ?? ''}'),
                            trailing: const Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 16),
                          ))
                      .toList(),
                ),
              ),
            ],
          ),
        );
      },
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
          Icon(Icons.chevron_right_rounded,
              color: Theme.of(context).colorScheme.onSurfaceVariant),
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
            style: TextStyle(
                fontSize: 11,
                color: Theme.of(context).colorScheme.onSurfaceVariant)),
      ),
    );
  }
}

class _ReportsView extends StatefulWidget {
  const _ReportsView();

  @override
  State<_ReportsView> createState() => _ReportsViewState();
}

class _ReportsViewState extends State<_ReportsView> {
  late Future<Map<String, dynamic>> _future = sl<ApiService>().dashboard();

  Future<void> _refresh() async {
    setState(() => _future = sl<ApiService>().dashboard());
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: FilledButton.icon(
              onPressed: _refresh,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Tải lại báo cáo'),
            ),
          );
        }
        final charts = (snapshot.data?['charts'] as List? ?? const [])
            .cast<Map<String, dynamic>>();
        return RefreshIndicator(
          onRefresh: _refresh,
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: charts.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, index) {
              final chart = charts[index];
              final rows = (chart['data'] as List? ?? const [])
                  .cast<Map<String, dynamic>>();
              final max = (chart['max'] as num?)?.toDouble() ?? 0;
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${chart['title']}',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15)),
                      Text('${chart['subtitle'] ?? ''}',
                          style: TextStyle(
                              fontSize: 11,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant)),
                      const SizedBox(height: 14),
                      if (rows.isEmpty)
                        Text('Chưa có dữ liệu.',
                            style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant)),
                      for (final row in rows) ...[
                        Row(
                          children: [
                            SizedBox(
                              width: 90,
                              child: Text('${row['label']}',
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 12)),
                            ),
                            Expanded(
                              child: LinearProgressIndicator(
                                value: max <= 0
                                    ? 0
                                    : ((row['value'] as num?)?.toDouble() ??
                                            0) /
                                        max,
                                minHeight: 12,
                                color: AppColors.adminAccent,
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .outlineVariant,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text('${row['value']}${chart['suffix'] ?? ''}',
                                style: const TextStyle(
                                    fontSize: 11, fontWeight: FontWeight.w600)),
                          ],
                        ),
                        const SizedBox(height: 8),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _AuditLogView extends StatefulWidget {
  const _AuditLogView();

  @override
  State<_AuditLogView> createState() => _AuditLogViewState();
}

class _AuditLogViewState extends State<_AuditLogView> {
  final _query = TextEditingController();
  late Future<Map<String, dynamic>> _future = sl<ApiService>().auditLogsPage();

  void _reload([String? value]) => setState(() =>
      _future = sl<ApiService>().auditLogsPage(query: value ?? _query.text));

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  Color _actionColor(String action) => switch (action) {
        'DELETE' || 'LOGIN_FAILED' => AppColors.error,
        'UPDATE' || 'EXPORT' => AppColors.warning,
        'CREATE' => AppColors.primary,
        'PAYMENT' || 'LOGIN' => AppColors.success,
        _ => AppColors.adminAccent,
      };

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          color: Theme.of(context).colorScheme.surface,
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _query,
                  onSubmitted: _reload,
                  decoration: InputDecoration(
                    hintText: 'Tìm theo người thực hiện hoặc nội dung...',
                    prefixIcon: const Icon(Icons.search, size: 18),
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.outlineVariant,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.refresh_rounded),
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
              final entries = (snapshot.data?['items'] as List? ?? const [])
                  .cast<Map<String, dynamic>>();
              if (entries.isEmpty) {
                return const Center(child: Text('Không có hoạt động phù hợp.'));
              }
              return RefreshIndicator(
                onRefresh: () async => _reload(),
                child: ListView.separated(
                  itemCount: entries.length,
                  separatorBuilder: (_, __) => const Divider(height: 0),
                  itemBuilder: (_, i) {
                    final entry = entries[i];
                    final action = '${entry['action'] ?? ''}';
                    final color = _actionColor(action);
                    final createdAt =
                        DateTime.tryParse('${entry['createdAt'] ?? ''}');
                    final time = createdAt == null
                        ? ''
                        : '${createdAt.toLocal().day.toString().padLeft(2, '0')}/'
                            '${createdAt.toLocal().month.toString().padLeft(2, '0')} '
                            '${createdAt.toLocal().hour.toString().padLeft(2, '0')}:'
                            '${createdAt.toLocal().minute.toString().padLeft(2, '0')}';
                    return ListTile(
                      leading: CircleAvatar(
                        radius: 16,
                        backgroundColor: color.withValues(alpha: 0.12),
                        child:
                            Icon(_actionIcon(action), color: color, size: 16),
                      ),
                      title: Text('${entry['detail'] ?? _actionLabel(action)}',
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w500)),
                      subtitle: Text(
                          '${entry['actorName'] ?? 'Hệ thống'} • ${_actionLabel(action)}',
                          style: TextStyle(
                            fontSize: 11,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          )),
                      trailing: Text(time,
                          style: TextStyle(
                            fontSize: 11,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          )),
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

  IconData _actionIcon(String action) => switch (action) {
        'LOGIN' || 'LOGIN_FAILED' => Icons.login_rounded,
        'CREATE' => Icons.add_circle_outline_rounded,
        'UPDATE' => Icons.edit_outlined,
        'DELETE' => Icons.delete_outline,
        'EXPORT' => Icons.file_download_outlined,
        'PAYMENT' => Icons.payment_rounded,
        _ => Icons.history_rounded,
      };

  String _actionLabel(String action) => switch (action) {
        'LOGIN' => 'Đăng nhập',
        'LOGIN_FAILED' => 'Đăng nhập không thành công',
        'CREATE' => 'Tạo mới',
        'UPDATE' => 'Cập nhật',
        'DELETE' => 'Xóa',
        'EXPORT' => 'Xuất báo cáo',
        'PAYMENT' => 'Thanh toán',
        _ => 'Hoạt động hệ thống',
      };
}

// =================== TAB 2: USERS ===================

class _UsersTab extends StatefulWidget {
  const _UsersTab({super.key});

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
          title: Text(
            MediaQuery.sizeOf(context).width < 340
                ? 'Người dùng'
                : 'Quản lý người dùng',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          backgroundColor: AppColors.adminAccent,
          actions: [
            IconButton(
                icon: const Icon(Icons.upload_file_outlined),
                tooltip: 'Nhập từ Excel',
                onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const UserImportPage()))),
            const _AdminNotiAction(),
          ],
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white60,
            indicatorColor: Colors.white,
            labelPadding: EdgeInsets.symmetric(horizontal: 4),
            tabs: [
              Tab(text: 'Tất cả'),
              Tab(text: 'Giáo viên'),
              Tab(text: 'Học sinh'),
              Tab(text: 'Phụ huynh'),
            ],
          ),
        ),
        body: FutureBuilder<List<Map<String, dynamic>>>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snap.hasError) {
              return Center(
                child: Text('Không thể tải danh sách người dùng.',
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant)),
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
        const SnackBar(
          content: Text('Không thể cập nhật tài khoản. Vui lòng thử lại.'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (users.isEmpty) {
      return Center(
          child: Text('Không có người dùng',
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant)));
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
        final code =
            (u['userCode'] ?? u['studentCode'] ?? u['teacherCode'] ?? '')
                .toString();
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
              style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant)),
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
                  icon: Icon(Icons.more_vert,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      size: 18),
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
                Icon(Icons.chevron_right_rounded,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    size: 18),
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
  const _StructureTab({super.key, this.initialIndex = 0});
  final int initialIndex;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      initialIndex: initialIndex,
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
    sl<ApiService>().announcements(),
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

  String _holidayRange(Map<String, dynamic> holiday) {
    final start = _date(holiday['holidayStartDate']);
    final end = _date(holiday['holidayEndDate']);
    if (start.isNotEmpty && end.isNotEmpty) return '$start – $end';
    final body = '${holiday['body'] ?? ''}'.trim();
    return body.isEmpty ? 'Chưa cấu hình ngày nghỉ' : body;
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
            child: Text('Không thể tải danh sách năm học.',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant)),
          );
        }
        final data = snap.data ?? const [];
        final years =
            data.isNotEmpty ? data[0] : const <Map<String, dynamic>>[];
        final semesters =
            data.length > 1 ? data[1] : const <Map<String, dynamic>>[];
        final holidays = data.length > 2
            ? data[2]
                .where((item) => '${item['category']}' == 'HOLIDAY')
                .toList()
            : const <Map<String, dynamic>>[];

        // Năm học đang hoạt động: ưu tiên status ACTIVE, fallback phần tử đầu.
        final active = years.cast<Map<String, dynamic>?>().firstWhere(
              (y) => (y?['status'] ?? '').toString().toUpperCase() == 'ACTIVE',
              orElse: () => years.isNotEmpty ? years.first : null,
            );
        final others = years.where((y) => !identical(y, active)).toList();
        final activeSemesters = active == null
            ? const <Map<String, dynamic>>[]
            : semesters
                .where((semester) =>
                    '${semester['academicYearId']}' == '${active['id']}')
                .toList();

        const semColors = [AppColors.success, AppColors.warning];

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const SectionHeader(title: 'Năm học hiện hành'),
            const SizedBox(height: 10),
            if (active == null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('Chưa có năm học',
                      style: TextStyle(
                          color:
                              Theme.of(context).colorScheme.onSurfaceVariant)),
                ),
              )
            else
              Card(
                child: InkWell(
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => _AcademicYearDetailPage(
                      year: active,
                      semesters: activeSemesters,
                      holidays: holidays,
                    ),
                  )),
                  borderRadius: BorderRadius.circular(12),
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
                                color:
                                    AppColors.success.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(_adminStatusLabel(active['status']),
                                  style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.success)),
                            ),
                            const Spacer(),
                            Text(
                                '${_date(active['startDate'])} – ${_date(active['endDate'])}',
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                    fontSize: 12)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                            (active['name'] ?? active['code'] ?? '').toString(),
                            style: const TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 15)),
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
                        const SizedBox(height: 10),
                        const Align(
                          alignment: Alignment.centerRight,
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            Text('Xem chi tiết'),
                            SizedBox(width: 4),
                            Icon(Icons.arrow_forward_rounded, size: 18),
                          ]),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 20),
            const SectionHeader(title: 'Ngày nghỉ trong năm'),
            const SizedBox(height: 10),
            if (holidays.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Chưa có thông báo nghỉ lễ được công bố'),
                ),
              )
            else
              Card(
                child: Column(
                  children: [
                    for (var i = 0; i < holidays.length; i++) ...[
                      ListTile(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                _HolidayDetailPage(holiday: holidays[i]),
                          ),
                        ),
                        leading: const Icon(Icons.celebration_rounded,
                            color: AppColors.warning),
                        title: Text('${holidays[i]['title'] ?? 'Ngày nghỉ'}'),
                        subtitle: Text(_holidayRange(holidays[i]),
                            maxLines: 2, overflow: TextOverflow.ellipsis),
                        trailing: const Icon(Icons.chevron_right_rounded),
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
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('Không có năm học khác',
                      style: TextStyle(
                          color:
                              Theme.of(context).colorScheme.onSurfaceVariant)),
                ),
              )
            else
              Card(
                child: Column(
                  children: [
                    for (var i = 0; i < others.length; i++) ...[
                      ListTile(
                        onTap: () {
                          final year = others[i];
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => _AcademicYearDetailPage(
                              year: year,
                              semesters: semesters
                                  .where((semester) =>
                                      '${semester['academicYearId']}' ==
                                      '${year['id']}')
                                  .toList(),
                              holidays: holidays,
                            ),
                          ));
                        },
                        leading: Icon(Icons.archive_outlined,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant),
                        title: Text(
                            (others[i]['name'] ?? others[i]['code'] ?? '')
                                .toString()),
                        subtitle: Text(_adminStatusLabel(others[i]['status'])),
                        trailing:
                            const Icon(Icons.chevron_right_rounded, size: 18),
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

class _AcademicYearDetailPage extends StatelessWidget {
  const _AcademicYearDetailPage({
    required this.year,
    required this.semesters,
    required this.holidays,
  });
  final Map<String, dynamic> year;
  final List<Map<String, dynamic>> semesters;
  final List<Map<String, dynamic>> holidays;

  String _date(Object? raw) {
    final value = '${raw ?? ''}';
    final date = DateTime.tryParse(value);
    if (date == null) return value.isEmpty ? '—' : value;
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _holidayRange(Map<String, dynamic> holiday) {
    final startRaw = '${holiday['holidayStartDate'] ?? ''}'.trim();
    final endRaw = '${holiday['holidayEndDate'] ?? ''}'.trim();
    if (startRaw.isNotEmpty && endRaw.isNotEmpty) {
      return '${_date(startRaw)} – ${_date(endRaw)}';
    }
    final body = '${holiday['body'] ?? ''}'.trim();
    return body.isEmpty ? 'Chưa cấu hình ngày nghỉ' : body;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Chi tiết năm học')),
        body: ListView(padding: const EdgeInsets.all(16), children: [
          RolePageIntro(
            title: '${year['name'] ?? year['code'] ?? 'Năm học'}',
            subtitle: '${_date(year['startDate'])} – ${_date(year['endDate'])}',
            accent: AppColors.adminAccent,
            icon: Icons.calendar_month_rounded,
          ),
          const SectionHeader(title: 'Học kỳ'),
          const SizedBox(height: 8),
          if (semesters.isEmpty)
            const Card(child: ListTile(title: Text('Chưa có học kỳ')))
          else
            ...semesters.map((semester) => Card(
                  child: ListTile(
                    leading: const CircleAvatar(
                        child: Icon(Icons.view_week_rounded)),
                    title: Text(
                        '${semester['name'] ?? semester['code'] ?? 'Học kỳ'}'),
                    subtitle: Text(
                        '${_date(semester['startDate'])} – ${_date(semester['endDate'])}'),
                    trailing: Chip(
                        label: Text(_adminStatusLabel(semester['status']))),
                  ),
                )),
          const SizedBox(height: 16),
          SectionHeader(title: 'Ngày nghỉ đã công bố (${holidays.length})'),
          const SizedBox(height: 8),
          if (holidays.isEmpty)
            const Card(
                child: ListTile(title: Text('Chưa có ngày nghỉ được công bố')))
          else
            ...holidays.map((holiday) => Card(
                  child: ListTile(
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => _HolidayDetailPage(holiday: holiday))),
                    leading: const Icon(Icons.celebration_rounded,
                        color: AppColors.warning),
                    title: Text('${holiday['title'] ?? 'Ngày nghỉ'}'),
                    subtitle: Text(_holidayRange(holiday),
                        maxLines: 2, overflow: TextOverflow.ellipsis),
                    trailing: const Icon(Icons.chevron_right_rounded),
                  ),
                )),
        ]),
      );
}

class _HolidayDetailPage extends StatelessWidget {
  const _HolidayDetailPage({required this.holiday});
  final Map<String, dynamic> holiday;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Chi tiết ngày nghỉ')),
        body: ListView(padding: const EdgeInsets.all(16), children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${holiday['title'] ?? 'Ngày nghỉ'}',
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 10),
                    Text('${holiday['body'] ?? 'Không có mô tả'}'),
                    const Divider(height: 28),
                    Text('Từ ngày: ${holiday['holidayStartDate'] ?? '—'}'),
                    Text('Đến ngày: ${holiday['holidayEndDate'] ?? '—'}'),
                    Text(
                        'Đối tượng: ${_holidayAudienceLabel(holiday['audience'])}'),
                    Text(
                        'Trạng thái: ${_holidayStatusLabel(holiday['status'])}'),
                  ]),
            ),
          ),
        ]),
      );
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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content:
            Text('Không thể cập nhật giáo viên chủ nhiệm. Vui lòng thử lại.'),
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
            child: Text('Không thể tải danh sách lớp.',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant)),
          );
        }
        final classes = snap.data ?? const [];
        if (classes.isEmpty) {
          return Center(
              child: Text('Chưa có lớp',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant)));
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
                borderRadius: BorderRadius.circular(12),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => AdminClassDetail(
                      classId: '${c['id']}',
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
                    child: Text(name.isEmpty ? '?' : name,
                        style: const TextStyle(
                            color: AppColors.adminAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 12)),
                  ),
                  title: Text(name,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(
                      '$gradeName${homeroom.isEmpty ? '' : ' • GVCN: $homeroom'}',
                      style: TextStyle(
                          fontSize: 12,
                          color:
                              Theme.of(context).colorScheme.onSurfaceVariant)),
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
                        child: Text('$count HS',
                            style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.adminAccent)),
                      ),
                      IconButton(
                        tooltip: 'Phân công giáo viên chủ nhiệm',
                        onPressed: () => _assignHomeroomTeacher(c),
                        icon: const Icon(Icons.manage_accounts_outlined,
                            color: AppColors.adminAccent, size: 20),
                      ),
                      Icon(Icons.chevron_right_rounded,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          size: 18),
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
            child: Text('Không thể tải dữ liệu học sinh.',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant)),
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
                  ? Padding(
                      padding: const EdgeInsets.all(16),
                      child: Center(
                          child: Text('Chưa có môn học',
                              style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant))),
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
                  ? Padding(
                      padding: const EdgeInsets.all(16),
                      child: Center(
                          child: Text('Chưa có phòng học',
                              style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant))),
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
          style: TextStyle(
              fontSize: 11,
              color: Theme.of(context).colorScheme.onSurfaceVariant)),
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
              style: TextStyle(
                  fontSize: 11,
                  color: Theme.of(context).colorScheme.onSurfaceVariant)),
      trailing: Text('$cap chỗ',
          style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500)),
    );
  }
}

class _FinanceView extends StatefulWidget {
  const _FinanceView();

  @override
  State<_FinanceView> createState() => _FinanceViewState();
}

class _FinanceViewState extends State<_FinanceView>
    with WidgetsBindingObserver {
  late Future<List<Map<String, dynamic>>> _future =
      sl<ApiService>().feePeriods();
  StreamSubscription<RealtimeEvent>? _paymentEvents;
  Timer? _reloadDebounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final realtime = sl<RealtimeService>()..connect();
    _paymentEvents = realtime.events
        .where((event) => event.type == 'PAYMENT_STATUS_UPDATED')
        .listen((_) {
      _reloadDebounce?.cancel();
      _reloadDebounce = Timer(const Duration(milliseconds: 250), () {
        if (mounted) _refresh();
      });
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) _refresh();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _reloadDebounce?.cancel();
    _paymentEvents?.cancel();
    super.dispose();
  }

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
        const SnackBar(
          content: Text('Không thể tạo hóa đơn. Vui lòng thử lại.'),
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
            child: Text('Không thể tải danh sách đợt thu.',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant)),
          );
        }
        final periods = snap.data ?? const [];
        return RefreshIndicator(
          onRefresh: () async => _refresh(),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const SectionHeader(title: 'Đợt thu đang mở', action: 'Tạo mới'),
              const SizedBox(height: 10),
              if (periods.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                      child: Text('Chưa có đợt thu',
                          style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant))),
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
                          code: code,
                          title: name,
                          status: status,
                          dueDate: p['dueDate']?.toString(),
                        ),
                      ),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: (isOpen
                                ? AppColors.success
                                : Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant)
                            .withValues(alpha: 0.12),
                        child: Icon(
                          isOpen
                              ? Icons.receipt_long_rounded
                              : Icons.archive_outlined,
                          color: isOpen
                              ? AppColors.success
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      title: Text(name,
                          style: const TextStyle(fontWeight: FontWeight.w500)),
                      subtitle: Text(code,
                          style: TextStyle(
                              fontSize: 11,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isOpen && id.isNotEmpty)
                            IconButton(
                              tooltip: 'Phát hành hóa đơn',
                              icon: const Icon(Icons.playlist_add_rounded,
                                  color: AppColors.adminAccent, size: 20),
                              onPressed: () => _generateInvoices(id),
                            ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: (isOpen
                                      ? AppColors.success
                                      : Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant)
                                  .withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(status,
                                style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: isOpen
                                        ? AppColors.success
                                        : Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant)),
                          ),
                          Icon(Icons.chevron_right_rounded,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                              size: 18),
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
            color: Theme.of(context).colorScheme.surface,
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
                          style: TextStyle(
                            fontSize: 12,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          )),
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
                icon: Icons.account_tree_rounded,
                label: 'Cơ cấu & phân lớp tự động',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const AcademicStructureWorkflowPage(),
                  ),
                ),
              ),
              _AdminSettingsTile(
                icon: Icons.rule_folder_rounded,
                label: 'Kế hoạch & tiến độ đào tạo',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const AcademicPlanProgressPage(),
                  ),
                ),
              ),
              _AdminSettingsTile(
                icon: Icons.auto_awesome_rounded,
                label: 'Tự xếp & phát hành thời khóa biểu',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const TimetableOperationsPage(),
                  ),
                ),
              ),
              _AdminSettingsTile(
                icon: Icons.event_available_rounded,
                label: 'Tự xếp & công bố lịch thi',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const ExamAutoPlanPage(),
                  ),
                ),
              ),
              _AdminSettingsTile(
                icon: Icons.account_balance_wallet_rounded,
                label: 'Tài chính, công nợ & đối soát',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const AdminFinanceOperationsHome(),
                  ),
                ),
              ),
              _AdminSettingsTile(
                icon: Icons.schedule_rounded,
                label: 'Điều chỉnh thời khóa biểu thủ công',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (_) => const TimetableSchedulingPage()),
                ),
              ),
              _AdminSettingsTile(
                icon: Icons.assignment_outlined,
                label: 'Cấu hình khảo thí',
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
                icon: Icons.notifications_active_outlined,
                label: 'Mẫu thông báo',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (_) => const NotificationTemplatesPage()),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _AdminSettingsGroup(
            title: 'Tài khoản',
            children: [
              _AdminSettingsTile(
                icon: Icons.lock_outline_rounded,
                label: 'Đổi mật khẩu',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ChangePasswordPage()),
                ),
              ),
            ],
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

// =================== TIMETABLE HUB (Cơ cấu sub-tab) ===================

class _TimetableHubView extends StatelessWidget {
  const _TimetableHubView();

  @override
  Widget build(BuildContext context) => const TimetableOperationsPage();
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
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
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

String _adminStatusLabel(Object? value) => switch ('$value'.toUpperCase()) {
      'ACTIVE' => 'Đang áp dụng',
      'PLANNED' => 'Sắp tới',
      'COMPLETED' => 'Đã kết thúc',
      'DRAFT' => 'Đang chuẩn bị',
      'PUBLISHED' => 'Đã công bố',
      _ => 'Chưa xác định',
    };

String _holidayAudienceLabel(Object? value) {
  final audience = '$value'.toUpperCase();
  if (audience == 'ALL') return 'Toàn trường';
  if (audience == 'TEACHER') return 'Giáo viên';
  if (audience == 'STUDENT') return 'Học sinh';
  if (audience == 'PARENT') return 'Phụ huynh';
  if (audience.startsWith('CLASS')) return 'Lớp đã chọn';
  return 'Đối tượng đã chọn';
}

String _holidayStatusLabel(Object? value) => switch ('$value'.toUpperCase()) {
      'SENT' || 'PUBLISHED' => 'Đã công bố',
      'DRAFT' => 'Đang chuẩn bị',
      'CANCELLED' => 'Đã hủy',
      _ => 'Chưa xác định',
    };
