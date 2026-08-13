import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/network/realtime_service.dart';
import '../../../../shared/widgets/attendance_badge.dart';
import '../../../../shared/widgets/chat_pages.dart';
import '../../../../shared/widgets/notification_center.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../../shared/widgets/adaptive_role_scaffold.dart';
import '../../../../shared/widgets/mobile_workspace_page.dart';
import '../../../../shared/widgets/theme_mode_tile.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../grades/data/grade_record.dart';
import '../../../attendance/data/attendance_metrics.dart';
import 'invoice_detail.dart';
import 'parent_attendance_detail.dart';
import 'parent_subject_detail.dart';
import 'parent_timetable_page.dart';

class _Child {
  const _Child({
    required this.id,
    required this.name,
    required this.className,
    required this.avatarColor,
  });

  final String id;
  final String name;
  final String className;
  final Color avatarColor;
}

class _ARecord {
  const _ARecord(
      this.subject, this.date, this.status, this.note, this.periodNo);
  final String subject;
  final String date;
  final String status;
  final String? note;
  final int? periodNo;
}

class _SubjectGrade {
  const _SubjectGrade({
    required this.subjectId,
    required this.subject,
    required this.semesterId,
    required this.records,
    required this.average,
  });
  final String subjectId;
  final String subject;
  final String semesterId;
  final Map<String, GradeRecord> records;
  final double? average;
}

// =================== ROOT ===================

class ParentHome extends StatefulWidget {
  const ParentHome({super.key});

  @override
  State<ParentHome> createState() => _ParentHomeState();
}

class _ParentHomeState extends State<ParentHome> {
  int _tab = 0;
  int _activeChild = 0;
  late Future<List<_Child>> _childrenFuture = _loadChildren();

  Future<List<_Child>> _loadChildren() async {
    final rows = await sl<ApiService>().children();
    const colors = [
      AppColors.studentAccent,
      AppColors.teacherAccent,
      AppColors.parentAccent,
    ];
    return rows
        .asMap()
        .entries
        .map((entry) {
          final item = entry.value;
          return _Child(
            id: '${item['id'] ?? item['studentId'] ?? ''}',
            name: '${item['fullName'] ?? item['studentName'] ?? 'Học sinh'}',
            className: '${item['className'] ?? item['classCode'] ?? '—'}',
            avatarColor: colors[entry.key % colors.length],
          );
        })
        .where((child) => child.id.isNotEmpty)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<_Child>>(
      future: _childrenFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }
        final children = snapshot.data ?? [];
        if (children.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: const Text('Không gian phụ huynh')),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.family_restroom_rounded, size: 54),
                    const SizedBox(height: 14),
                    const Text('Chưa có học sinh được liên kết'),
                    const SizedBox(height: 14),
                    OutlinedButton.icon(
                      onPressed: () =>
                          setState(() => _childrenFuture = _loadChildren()),
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Tải lại'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        if (_activeChild >= children.length) _activeChild = 0;
        final child = children[_activeChild];
        return AdaptiveRoleScaffold(
          index: _tab,
          onSelected: (i) => setState(() => _tab = i),
          accent: AppColors.parentAccent,
          pages: [
            _MonitorTab(
              child: child,
              onSwitchChild: () => _showChildSwitcher(children),
              onGoGrades: () => setState(() => _tab = 1),
              onGoAttendance: () => setState(() => _tab = 2),
              onGoInvoices: () => setState(() => _tab = 3),
              onGoTimetable: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ParentTimetablePage(
                    studentId: child.id,
                    studentName: child.name,
                    className: child.className,
                  ),
                ),
              ),
            ),
            _GradesTab(child: child),
            _AttendanceTab(child: child),
            _InvoicesTab(child: child),
            _ProfileTab(
              activeChild: child,
              childrenCount: children.length,
              onSwitchChild: () => _showChildSwitcher(children),
            ),
          ],
          destinations: const [
            RoleDestination(
              icon: Icons.monitor_heart_outlined,
              selectedIcon: Icons.monitor_heart_rounded,
              label: 'Tổng quan',
            ),
            RoleDestination(
              icon: Icons.stars_outlined,
              selectedIcon: Icons.stars_rounded,
              label: 'Học tập',
            ),
            RoleDestination(
              icon: Icons.event_note_outlined,
              selectedIcon: Icons.event_note_rounded,
              label: 'Chuyên cần',
            ),
            RoleDestination(
              icon: Icons.receipt_long_outlined,
              selectedIcon: Icons.receipt_long_rounded,
              label: 'Tài chính',
            ),
            RoleDestination(
              icon: Icons.person_outline_rounded,
              selectedIcon: Icons.person_rounded,
              label: 'Tôi',
            ),
          ],
        );
      },
    );
  }

  void _showChildSwitcher(List<_Child> children) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Chọn học sinh',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 16),
            ...children.asMap().entries.map((e) {
              final idx = e.key;
              final c = e.value;
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: c.avatarColor.withValues(alpha: 0.14),
                  child: Text(c.name[0],
                      style: TextStyle(
                          color: c.avatarColor, fontWeight: FontWeight.bold)),
                ),
                title: Text(c.name),
                subtitle: Text('Lớp ${c.className}'),
                trailing: _activeChild == idx
                    ? const Icon(Icons.check_circle_rounded,
                        color: AppColors.parentAccent)
                    : null,
                onTap: () {
                  setState(() => _activeChild = idx);
                  Navigator.pop(context);
                },
              );
            }),
          ],
        ),
      ),
    );
  }
}

// =================== TAB 1: MONITOR ===================

class _MonitorTab extends StatefulWidget {
  const _MonitorTab({
    required this.child,
    required this.onSwitchChild,
    required this.onGoGrades,
    required this.onGoAttendance,
    required this.onGoInvoices,
    required this.onGoTimetable,
  });
  final _Child child;
  final VoidCallback onSwitchChild;
  final VoidCallback onGoGrades;
  final VoidCallback onGoAttendance;
  final VoidCallback onGoInvoices;
  final VoidCallback onGoTimetable;
  @override
  State<_MonitorTab> createState() => _MonitorTabState();
}

class _MonitorTabState extends State<_MonitorTab> with WidgetsBindingObserver {
  late Future<List<List<Map<String, dynamic>>>> _future;
  late Future<int> _pendingInvoice;
  StreamSubscription<RealtimeEvent>? _domainEvents;
  Timer? _reloadDebounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _reload();
    final realtime = sl<RealtimeService>()..connect();
    _domainEvents = realtime.events
        .where((event) =>
            const {
              'GRADE_UPDATED',
              'ATTENDANCE_UPDATED',
              'PAYMENT_STATUS_UPDATED',
            }.contains(event.type) &&
            event.data['studentId'] == widget.child.id)
        .listen((_) => _scheduleReload());
  }

  @override
  void didUpdateWidget(covariant _MonitorTab old) {
    super.didUpdateWidget(old);
    if (old.child.id != widget.child.id) setState(_reload);
  }

  void _reload() {
    final api = sl<ApiService>();
    _future = Future.wait([
      api.attendance(studentId: widget.child.id),
      api.grades(studentId: widget.child.id),
      api.gradeSummaries(studentId: widget.child.id),
    ]);
    _pendingInvoice = api.invoices(studentId: widget.child.id).then((items) =>
        items.where((item) => item['status'] != 'PAID').fold<int>(
            0,
            (total, item) =>
                total +
                ((item['totalAmount'] as num?)?.toInt() ?? 0) -
                ((item['paidAmount'] as num?)?.toInt() ?? 0)));
  }

  void _scheduleReload() {
    _reloadDebounce?.cancel();
    _reloadDebounce = Timer(const Duration(milliseconds: 250), () {
      if (mounted) setState(_reload);
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) setState(_reload);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _reloadDebounce?.cancel();
    _domainEvents?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final child = widget.child;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Giám sát con'),
        backgroundColor: AppColors.parentAccent,
        actions: const [_PChatAction(), _PNotiAction()],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _ChildCard(child: child, onSwitch: widget.onSwitchChild),
          FutureBuilder<int>(
            future: _pendingInvoice,
            builder: (context, snapshot) {
              final total = snapshot.data ?? 0;
              if (total <= 0) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(top: 12),
                child: _InvoiceBanner(
                  totalPending: total,
                  onTap: widget.onGoInvoices,
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          _TimetableShortcut(
            child: child,
            onTap: widget.onGoTimetable,
          ),
          const SizedBox(height: 16),
          FutureBuilder<List<List<Map<String, dynamic>>>>(
            future: _future,
            builder: (context, snap) {
              if (snap.connectionState != ConnectionState.done) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (snap.hasError) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                      child: Text('Không thể tải thông tin học tập.',
                          style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant))),
                );
              }
              final data = snap.data ?? const <List<Map<String, dynamic>>>[];
              final List<Map<String, dynamic>> attRaw =
                  data.isNotEmpty ? data[0] : const [];
              final List<Map<String, dynamic>> gradeRaw =
                  data.length > 1 ? data[1] : const [];
              final List<Map<String, dynamic>> gradeSummaryRaw =
                  data.length > 2 ? data[2] : const [];
              final nonPresent = attRaw
                  .where((record) => isAbsentAttendanceStatus(record['status']))
                  .toList()
                ..sort((a, b) => '${b['date']}'.compareTo('${a['date']}'));
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (nonPresent.isNotEmpty) ...[
                    _LiveAttendanceAlert(
                      record: nonPresent.first,
                      onTap: widget.onGoAttendance,
                    ),
                    const SizedBox(height: 16),
                  ],
                  const SectionHeader(title: 'Tổng quan học kỳ'),
                  const SizedBox(height: 10),
                  _LiveSummary(
                    attendance: attRaw,
                    gradeSummaries: gradeSummaryRaw,
                    onOpenGrades: widget.onGoGrades,
                    onOpenAttendance: widget.onGoAttendance,
                  ),
                  const SizedBox(height: 16),
                  _RecentAttendanceSection(child: child, records: attRaw),
                  const SizedBox(height: 16),
                  _RecentGradesSection(
                    grades: gradeRaw,
                    onViewAll: widget.onGoGrades,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

/// "Điểm danh gần đây" — most recent 4 attendance records (live).
class _RecentAttendanceSection extends StatelessWidget {
  const _RecentAttendanceSection({required this.child, required this.records});
  final _Child child;
  final List<Map<String, dynamic>> records;

  @override
  Widget build(BuildContext context) {
    // Sort by date descending so the newest records show first.
    final sorted = [...records]..sort((a, b) =>
        (b['date'] ?? '').toString().compareTo((a['date'] ?? '').toString()));
    final recent = sorted.take(4).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionHeader(title: 'Điểm danh gần đây'),
        const SizedBox(height: 10),
        if (recent.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text('Chưa có dữ liệu',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant)),
          )
        else
          ...recent.map((r) {
            final subject = (r['subjectName'] ?? '').toString();
            final date = (r['date'] ?? '').toString();
            final status = (r['status'] ?? '').toString();
            final note = r['note']?.toString();
            return Card(
              margin: const EdgeInsets.only(bottom: 6),
              child: ListTile(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ParentAttendanceDetail(
                      childName: child.name,
                      subject: subject,
                      date: date,
                      status: status,
                      note: note,
                      periodNo: (r['periodNo'] as num?)?.toInt(),
                    ),
                  ),
                ),
                title: Text(subject,
                    style: const TextStyle(
                        fontWeight: FontWeight.w500, fontSize: 14)),
                subtitle: Text(note ?? date,
                    style: const TextStyle(fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AttendanceBadge(status),
                    Icon(Icons.chevron_right_rounded,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        size: 18),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }
}

/// "Top điểm gần đây" — a few most recent graded entries (live).
class _RecentGradesSection extends StatelessWidget {
  const _RecentGradesSection({required this.grades, required this.onViewAll});
  final List<Map<String, dynamic>> grades;
  final VoidCallback onViewAll;

  static const _categoryLabels = {
    'ORAL': 'Bài miệng',
    '15M': 'Bài 15 phút',
    'MID': 'Bài kiểm tra GK',
    'FINAL': 'Bài kiểm tra CK',
  };

  @override
  Widget build(BuildContext context) {
    // Only entries with a real score, newest (by recordedAt) first.
    final scored = grades.where((g) => g['score'] is num).toList()
      ..sort((a, b) => (b['recordedAt'] ?? '')
          .toString()
          .compareTo((a['recordedAt'] ?? '').toString()));
    final recent = scored.take(3).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(
            title: 'Điểm gần đây', action: 'Xem tất cả', onAction: onViewAll),
        const SizedBox(height: 10),
        if (recent.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text('Chưa có dữ liệu',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant)),
          )
        else
          Card(
            child: Column(
              children: [
                for (var i = 0; i < recent.length; i++) ...[
                  if (i > 0) const Divider(height: 0),
                  _RecentGradeRow(
                    subject: (recent[i]['subjectName'] ?? '').toString(),
                    score: (recent[i]['score'] as num).toDouble(),
                    note: (recent[i]['categoryName'] ??
                            _categoryLabels[
                                (recent[i]['category'] ?? '').toString()] ??
                            '')
                        .toString(),
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

class _RecentGradeRow extends StatelessWidget {
  const _RecentGradeRow({
    required this.subject,
    required this.score,
    required this.note,
  });
  final String subject;
  final double score;
  final String note;

  Color get _color {
    if (score >= 8) return AppColors.success;
    if (score >= 6.5) return AppColors.warning;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: _color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(score.toStringAsFixed(1),
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: _color, fontSize: 14)),
        ),
      ),
      title: Text(subject,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
      subtitle: Text(note,
          style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant)),
    );
  }
}

class _LiveAttendanceAlert extends StatelessWidget {
  const _LiveAttendanceAlert({required this.record, required this.onTap});
  final Map<String, dynamic> record;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.absentUnexcused.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: AppColors.absentUnexcused.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning_amber_rounded,
                    color: AppColors.absentUnexcused, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '${record['subjectName'] ?? 'Môn học'} · ${record['date'] ?? ''} · '
                    '${record['note'] ?? _parentAttendanceLabel(record['status'])}',
                    style: const TextStyle(
                        fontSize: 13, color: AppColors.absentUnexcused),
                  ),
                ),
                const Icon(Icons.chevron_right_rounded,
                    color: AppColors.absentUnexcused),
              ],
            ),
          ),
        ));
  }
}

class _InvoiceBanner extends StatelessWidget {
  const _InvoiceBanner({
    required this.totalPending,
    required this.onTap,
  });
  final int totalPending;
  final VoidCallback onTap;

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
    return Material(
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.warning.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.payment_rounded,
                  color: AppColors.warning, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Có hóa đơn cần thanh toán',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 13)),
                    const SizedBox(height: 2),
                    Text(
                      'Tổng: ${_formatVnd(totalPending)}',
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.warning),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppColors.warning),
            ],
          ),
        ),
      ),
    );
  }
}

class _LiveSummary extends StatelessWidget {
  const _LiveSummary({
    required this.attendance,
    required this.gradeSummaries,
    required this.onOpenGrades,
    required this.onOpenAttendance,
  });
  final List<Map<String, dynamic>> attendance;
  final List<Map<String, dynamic>> gradeSummaries;
  final VoidCallback onOpenGrades;
  final VoidCallback onOpenAttendance;

  @override
  Widget build(BuildContext context) {
    final scored = gradeSummaries
        .where((summary) => summary['average'] is num)
        .map((summary) => (summary['average'] as num).toDouble())
        .toList();
    final average =
        scored.isEmpty ? null : scored.reduce((a, b) => a + b) / scored.length;
    final attendanceMetrics = AttendanceMetrics.fromRecords(attendance);
    final present = attendanceMetrics.presentOrLate;
    final absent = attendanceMetrics.absent;
    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            value: average?.toStringAsFixed(1) ?? '—',
            label: 'Điểm TB',
            color: AppColors.success,
            onTap: onOpenGrades,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _SummaryCard(
            value: '$present/${attendance.length}',
            label: 'Có mặt',
            color: AppColors.primary,
            onTap: onOpenAttendance,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _SummaryCard(
            value: '$absent',
            label: 'Vắng',
            color: absent > 0
                ? AppColors.error
                : Theme.of(context).colorScheme.onSurfaceVariant,
            onTap: onOpenAttendance,
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.value,
    required this.label,
    required this.color,
    required this.onTap,
  });
  final String value;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(value,
                  style: TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold, color: color)),
              const SizedBox(height: 4),
              Text(label,
                  style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant)),
              const SizedBox(height: 4),
              Icon(Icons.arrow_forward_rounded, size: 15, color: color),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChildCard extends StatelessWidget {
  const _ChildCard({required this.child, required this.onSwitch});
  final _Child child;
  final VoidCallback onSwitch;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onSwitch,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: child.avatarColor.withValues(alpha: 0.14),
                child: Text(child.name[0],
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: child.avatarColor)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(child.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 15)),
                    const SizedBox(height: 2),
                    Text('Lớp ${child.className}',
                        style: TextStyle(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                            fontSize: 12)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.parentAccent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Đổi con',
                        style: TextStyle(
                            fontSize: 12, color: AppColors.parentAccent)),
                    SizedBox(width: 4),
                    Icon(Icons.swap_horiz_rounded,
                        size: 14, color: AppColors.parentAccent),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimetableShortcut extends StatelessWidget {
  const _TimetableShortcut({required this.child, required this.onTap});

  final _Child child;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
        child: ListTile(
          onTap: onTap,
          leading: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.parentAccent.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.calendar_month_rounded,
                color: AppColors.parentAccent),
          ),
          title: const Text('Lịch học của con',
              style: TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text('Xem thời khóa biểu đã công bố của ${child.name}',
              maxLines: 2, overflow: TextOverflow.ellipsis),
          trailing: const Icon(Icons.chevron_right_rounded),
        ),
      );
}

// =================== TAB 2: ATTENDANCE ===================

class _AttendanceTab extends StatefulWidget {
  const _AttendanceTab({required this.child});
  final _Child child;
  @override
  State<_AttendanceTab> createState() => _AttendanceTabState();
}

class _AttendanceTabState extends State<_AttendanceTab>
    with WidgetsBindingObserver {
  late Future<List<Map<String, dynamic>>> _future;
  StreamSubscription<RealtimeEvent>? _attendanceEvents;
  Timer? _reloadDebounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _reload();
    final realtime = sl<RealtimeService>()..connect();
    _attendanceEvents = realtime.events
        .where((event) =>
            event.type == 'ATTENDANCE_UPDATED' &&
            event.data['studentId'] == widget.child.id)
        .listen((_) => _scheduleReload());
  }

  @override
  void didUpdateWidget(covariant _AttendanceTab old) {
    super.didUpdateWidget(old);
    if (old.child.id != widget.child.id) setState(_reload);
  }

  void _reload() {
    _future = sl<ApiService>().attendance(studentId: widget.child.id);
  }

  void _scheduleReload() {
    _reloadDebounce?.cancel();
    _reloadDebounce = Timer(const Duration(milliseconds: 250), () {
      if (mounted) setState(_reload);
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) setState(_reload);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _reloadDebounce?.cancel();
    _attendanceEvents?.cancel();
    super.dispose();
  }

  _ARecord _map(Map<String, dynamic> r) => _ARecord(
        (r['subjectName'] ?? '').toString(),
        (r['date'] ?? '').toString(),
        (r['status'] ?? '').toString(),
        r['note']?.toString(),
        (r['periodNo'] as num?)?.toInt(),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chuyên cần — ${widget.child.name}'),
        backgroundColor: AppColors.parentAccent,
        actions: const [_PChatAction(), _PNotiAction()],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(
                child: Text('Không thể tải dữ liệu chuyên cần.',
                    style: TextStyle(
                        color:
                            Theme.of(context).colorScheme.onSurfaceVariant)));
          }
          final records = (snap.data ?? []).map(_map).toList();
          if (records.isEmpty) {
            return Center(
                child: Text('Chưa có dữ liệu',
                    style: TextStyle(
                        color:
                            Theme.of(context).colorScheme.onSurfaceVariant)));
          }
          return _AttendanceRange(
              child: widget.child, records: records, rangeLabel: 'học kỳ');
        },
      ),
    );
  }
}

class _AttendanceRange extends StatelessWidget {
  const _AttendanceRange({
    required this.child,
    required this.records,
    required this.rangeLabel,
  });
  final _Child child;
  final List<_ARecord> records;
  final String rangeLabel;

  @override
  Widget build(BuildContext context) {
    final stats = {
      'Có mặt': records.where((r) => r.status == 'PRESENT').length,
      'Vắng phép': records.where((r) => r.status == 'ABSENT_EXCUSED').length,
      'Vắng KP': records.where((r) => r.status == 'ABSENT_UNEXCUSED').length,
      'Muộn': records.where((r) => r.status == 'LATE').length,
    };
    final rate = records.isEmpty
        ? 0.0
        : (stats['Có mặt']! + stats['Muộn']! * 0.5) / records.length;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _RateBanner(rate: rate, rangeLabel: rangeLabel),
        const SizedBox(height: 14),
        _StatsRow(stats: stats),
        const SizedBox(height: 16),
        const SectionHeader(title: 'Lịch sử'),
        const SizedBox(height: 10),
        ...records.map((r) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ParentAttendanceDetail(
                      childName: child.name,
                      subject: r.subject,
                      date: r.date,
                      status: r.status,
                      note: r.note,
                      periodNo: r.periodNo,
                    ),
                  ),
                ),
                leading: Icon(Icons.schedule_rounded,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    size: 20),
                title: Text(r.subject,
                    style: const TextStyle(fontWeight: FontWeight.w500)),
                subtitle: Text(r.note ?? r.date,
                    style: const TextStyle(fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AttendanceBadge(r.status),
                    Icon(Icons.chevron_right_rounded,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        size: 18),
                  ],
                ),
              ),
            )),
      ],
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.stats});
  final Map<String, int> stats;

  @override
  Widget build(BuildContext context) {
    final colors = [
      AppColors.present,
      AppColors.absentExcused,
      AppColors.absentUnexcused,
      AppColors.late,
    ];
    return Row(
      children: List.generate(stats.length, (i) {
        final entry = stats.entries.elementAt(i);
        return Expanded(
          child: Card(
            margin: EdgeInsets.only(right: i < 3 ? 6 : 0),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                children: [
                  Text('${entry.value}',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: colors[i])),
                  const SizedBox(height: 2),
                  Text(entry.key,
                      style: TextStyle(
                          fontSize: 10,
                          color:
                              Theme.of(context).colorScheme.onSurfaceVariant),
                      textAlign: TextAlign.center),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _RateBanner extends StatelessWidget {
  const _RateBanner({required this.rate, required this.rangeLabel});
  final double rate;
  final String rangeLabel;

  Color get _color {
    if (rate >= 0.9) return AppColors.success;
    if (rate >= 0.75) return AppColors.warning;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    final percent = (rate * 100).toStringAsFixed(0);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 50,
            height: 50,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: rate,
                  color: _color,
                  backgroundColor: _color.withValues(alpha: 0.18),
                  strokeWidth: 5,
                ),
                Text('$percent%',
                    style: TextStyle(
                        color: _color,
                        fontWeight: FontWeight.bold,
                        fontSize: 11)),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tỉ lệ chuyên cần $rangeLabel',
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(height: 2),
                Text(
                  rate >= 0.9
                      ? 'Rất tốt — duy trì nhé!'
                      : rate >= 0.75
                          ? 'Cần lưu ý'
                          : 'Cảnh báo — đã thông báo',
                  style: TextStyle(color: _color, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =================== TAB 3: GRADES ===================

class _GradesTab extends StatefulWidget {
  const _GradesTab({required this.child});
  final _Child child;
  @override
  State<_GradesTab> createState() => _GradesTabState();
}

class _GradesTabState extends State<_GradesTab> with WidgetsBindingObserver {
  late Future<List<List<Map<String, dynamic>>>> _future;
  StreamSubscription<RealtimeEvent>? _gradeEvents;
  Timer? _reloadDebounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _reload();
    final realtime = sl<RealtimeService>()..connect();
    _gradeEvents = realtime.events
        .where((event) =>
            (event.type == 'GRADE_CREATED' || event.type == 'GRADE_UPDATED') &&
            event.data['studentId'] == widget.child.id)
        .listen((_) => _scheduleReload());
  }

  @override
  void didUpdateWidget(covariant _GradesTab old) {
    super.didUpdateWidget(old);
    if (old.child.id != widget.child.id) setState(_reload);
  }

  void _reload() {
    _future = Future.wait([
      sl<ApiService>().grades(studentId: widget.child.id),
      sl<ApiService>().examCategories(),
      sl<ApiService>().gradeSummaries(studentId: widget.child.id),
    ]);
  }

  void _scheduleReload() {
    _reloadDebounce?.cancel();
    _reloadDebounce = Timer(const Duration(milliseconds: 250), () {
      if (mounted) setState(_reload);
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) setState(_reload);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _reloadDebounce?.cancel();
    _gradeEvents?.cancel();
    super.dispose();
  }

  List<_SubjectGrade> _group(
    List<Map<String, dynamic>> raw,
    List<GradeSubjectSummary> summaries,
  ) {
    final bySubject = <String, List<GradeRecord>>{};
    for (final json in raw) {
      final grade = GradeRecord.fromJson(json);
      bySubject
          .putIfAbsent('${grade.subjectId}|${grade.semesterId}', () => [])
          .add(grade);
    }
    final summaryByKey = {
      for (final summary in summaries) summary.key: summary
    };
    final result = bySubject.entries.map((entry) {
      final first = entry.value.first;
      return _SubjectGrade(
        subjectId: first.subjectId,
        subject: first.subjectName,
        semesterId: first.semesterId,
        records: {for (final record in entry.value) record.key: record},
        average: summaryByKey[entry.key]?.average,
      );
    }).toList();
    result.sort((a, b) => a.subject.compareTo(b.subject));
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kết quả — ${widget.child.name}'),
        backgroundColor: AppColors.parentAccent,
        actions: const [_PChatAction(), _PNotiAction()],
      ),
      body: FutureBuilder<List<List<Map<String, dynamic>>>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(
                child: Text('Không thể tải kết quả học tập.',
                    style: TextStyle(
                        color:
                            Theme.of(context).colorScheme.onSurfaceVariant)));
          }
          final data = snap.data ?? const [];
          final subjects = _group(
            data.isNotEmpty ? data[0] : const [],
            (data.length > 2 ? data[2] : const <Map<String, dynamic>>[])
                .map(GradeSubjectSummary.fromJson)
                .toList(),
          );
          final columns = buildGradeColumns(
              (data.length > 1 ? data[1] : const <Map<String, dynamic>>[])
                  .map(GradeCategoryDefinition.fromJson)
                  .toList());
          if (subjects.isEmpty) {
            return Center(
                child: Text('Chưa có dữ liệu',
                    style: TextStyle(
                        color:
                            Theme.of(context).colorScheme.onSurfaceVariant)));
          }
          return _SemesterGrades(
              child: widget.child,
              semester: 'Kết quả học tập',
              subjects: subjects,
              columns: columns);
        },
      ),
    );
  }
}

class _SemesterGrades extends StatelessWidget {
  const _SemesterGrades({
    required this.child,
    required this.semester,
    required this.subjects,
    required this.columns,
  });
  final _Child child;
  final String semester;
  final List<_SubjectGrade> subjects;
  final List<GradeColumn> columns;

  Color _avgColor(double avg) {
    if (avg >= 8) return AppColors.success;
    if (avg >= 6.5) return AppColors.warning;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    final allAvgs =
        subjects.map((subject) => subject.average).whereType<double>().toList();
    final overall = allAvgs.isEmpty
        ? null
        : allAvgs.reduce((a, b) => a + b) / allAvgs.length;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.parentAccent,
                AppColors.parentAccent.withValues(alpha: 0.7),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              const Icon(Icons.auto_graph_rounded,
                  color: Colors.white70, size: 36),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(semester,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14)),
                    const SizedBox(height: 4),
                    Text(
                      overall == null
                          ? 'Chưa có điểm'
                          : 'TB: ${overall.toStringAsFixed(2)}',
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const SectionHeader(title: 'Theo môn'),
        const SizedBox(height: 10),
        ...subjects.map((sg) {
          final avg = sg.average;
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ParentSubjectDetail(
                    childName: child.name,
                    subject: sg.subject,
                    subjectId: sg.subjectId,
                    semesterId: sg.semesterId,
                    semester: semester,
                    records: sg.records,
                    columns: columns,
                    average: sg.average,
                  ),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: (avg != null
                                ? _avgColor(avg)
                                : Theme.of(context).colorScheme.outlineVariant)
                            .withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          avg?.toStringAsFixed(1) ?? '—',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: avg != null
                                  ? _avgColor(avg)
                                  : Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(sg.subject,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 14)),
                          const SizedBox(height: 4),
                          Text(
                            columns
                                .map((column) =>
                                    '${column.label}: ${sg.records[column.key]?.score.toStringAsFixed(1) ?? "—"}')
                                .join(' • '),
                            style: TextStyle(
                                fontSize: 11,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded,
                        color: Theme.of(context).colorScheme.onSurfaceVariant),
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

// =================== TAB 4: INVOICES ===================

class _InvoicesTab extends StatefulWidget {
  const _InvoicesTab({required this.child});
  final _Child child;
  @override
  State<_InvoicesTab> createState() => _InvoicesTabState();
}

class _InvoicesTabState extends State<_InvoicesTab>
    with WidgetsBindingObserver {
  late Future<List<Map<String, dynamic>>> _future;
  StreamSubscription<RealtimeEvent>? _paymentEvents;
  Timer? _reloadDebounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _reload();
    final realtime = sl<RealtimeService>()..connect();
    _paymentEvents = realtime.events
        .where((event) =>
            event.type == 'PAYMENT_STATUS_UPDATED' &&
            event.data['studentId'] == widget.child.id)
        .listen((_) => _scheduleReload());
  }

  @override
  void didUpdateWidget(covariant _InvoicesTab old) {
    super.didUpdateWidget(old);
    if (old.child.id != widget.child.id) setState(_reload);
  }

  void _reload() {
    _future = sl<ApiService>().invoices(studentId: widget.child.id);
  }

  void _scheduleReload() {
    _reloadDebounce?.cancel();
    _reloadDebounce = Timer(const Duration(milliseconds: 250), () {
      if (mounted) setState(_reload);
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) setState(_reload);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _reloadDebounce?.cancel();
    _paymentEvents?.cancel();
    super.dispose();
  }

  String _vnd(num a) {
    final s = a.toInt().toString();
    final b = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) b.write('.');
      b.write(s[i]);
    }
    return '$b ₫';
  }

  Future<void> _openDetail(Map<String, dynamic> summary) async {
    try {
      final detail =
          await sl<ApiService>().invoiceDetail(summary['id'].toString());
      if (!mounted) return;
      final invoice = (detail['invoice'] as Map).cast<String, dynamic>();
      final items = (detail['items'] as List? ?? const [])
          .map((raw) => (raw as Map).cast<String, dynamic>())
          .map((item) => InvoiceLineItem(
                (item['name'] ?? '').toString(),
                (item['amount'] as num?)?.toInt() ?? 0,
              ))
          .toList();
      final payments = (detail['payments'] as List? ?? const [])
          .map((raw) => (raw as Map).cast<String, dynamic>())
          .toList();
      await Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => InvoiceDetailPage(
          invoiceId: (invoice['id'] ?? summary['id']).toString(),
          invoiceCode: (invoice['code'] ?? '').toString(),
          childName: (invoice['studentName'] ?? widget.child.name).toString(),
          semester: (invoice['feePeriodId'] ?? 'Hóa đơn học phí').toString(),
          dueDate: (invoice['dueDate'] ?? '').toString(),
          status: (invoice['status'] ?? '').toString(),
          paidAt: payments.isEmpty ? null : payments.last['paidAt']?.toString(),
          items: items,
        ),
      ));
      if (mounted) setState(_reload);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Không thể tải chi tiết hóa đơn. Vui lòng thử lại.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hóa đơn — ${widget.child.name}'),
        backgroundColor: AppColors.parentAccent,
        actions: const [_PChatAction(), _PNotiAction()],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(
                child: Text('Không thể tải danh sách hóa đơn.',
                    style: TextStyle(
                        color:
                            Theme.of(context).colorScheme.onSurfaceVariant)));
          }
          final invoices = snap.data ?? [];
          if (invoices.isEmpty) {
            return Center(
                child: Text('Chưa có hóa đơn. Vui lòng liên hệ nhà trường.',
                    style: TextStyle(
                        color:
                            Theme.of(context).colorScheme.onSurfaceVariant)));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: invoices.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) {
              final inv = invoices[i];
              final status = (inv['status'] ?? '').toString();
              final paid = status == 'PAID';
              final color = paid
                  ? AppColors.success
                  : (status == 'PARTIAL' ? AppColors.warning : AppColors.error);
              return Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(6)),
                          child: Text(
                              paid
                                  ? 'Đã thanh toán'
                                  : (status == 'PARTIAL'
                                      ? 'Một phần'
                                      : 'Chưa TT'),
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold)),
                        ),
                        const Spacer(),
                        Text((inv['code'] ?? '').toString(),
                            style: TextStyle(
                                fontSize: 11,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant)),
                      ]),
                      const SizedBox(height: 8),
                      Text('HS: ${inv['studentName'] ?? ''}',
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 14)),
                      const SizedBox(height: 6),
                      Row(children: [
                        Text(_vnd((inv['totalAmount'] ?? 0) as num),
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: color,
                                fontSize: 16)),
                        const Spacer(),
                        TextButton(
                          onPressed: () => _openDetail(inv),
                          child: const Text('Chi tiết'),
                        ),
                        if (!paid)
                          FilledButton.icon(
                            onPressed: () => _openDetail(inv),
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.parentAccent,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            icon: const Icon(Icons.payment_rounded, size: 16),
                            label: const Text('Tạo VietQR',
                                style: TextStyle(fontSize: 12)),
                          )
                        else
                          const Text('Đã thanh toán',
                              style: TextStyle(
                                  fontSize: 12, color: AppColors.success)),
                      ]),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// =================== TAB 5: PROFILE ===================

class _ProfileTab extends StatelessWidget {
  const _ProfileTab({
    required this.activeChild,
    required this.childrenCount,
    required this.onSwitchChild,
  });
  final _Child activeChild;
  final int childrenCount;
  final VoidCallback onSwitchChild;

  @override
  Widget build(BuildContext context) {
    final user = (context.read<AuthBloc>().state as AuthAuthenticated).user;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tài khoản'),
        backgroundColor: AppColors.parentAccent,
        actions: const [_PChatAction(), _PNotiAction()],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 36,
                    backgroundColor: AppColors.parentAccent,
                    child: Icon(Icons.family_restroom_rounded,
                        color: Colors.white, size: 32),
                  ),
                  const SizedBox(height: 12),
                  Text(user.fullName,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(user.email ?? user.username,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 13)),
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.parentAccent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Đang xem: ${activeChild.name} (${activeChild.className})',
                      style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.parentAccent,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const SectionHeader(title: 'Tài khoản'),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                const ThemeModeTile(accent: AppColors.parentAccent),
                const Divider(height: 0),
                ListTile(
                  leading: const Icon(Icons.swap_horiz_rounded,
                      color: AppColors.parentAccent),
                  title: const Text('Chuyển học sinh'),
                  subtitle: Text('$childrenCount con liên kết',
                      style: TextStyle(
                          fontSize: 11,
                          color:
                              Theme.of(context).colorScheme.onSurfaceVariant)),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: onSwitchChild,
                ),
                const Divider(height: 0),
                ListTile(
                  leading: const Icon(Icons.calendar_month_rounded,
                      color: AppColors.parentAccent),
                  title: const Text('Lịch học của con'),
                  subtitle: Text(
                      '${activeChild.name} · ${activeChild.className}',
                      style: const TextStyle(fontSize: 11)),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ParentTimetablePage(
                        studentId: activeChild.id,
                        studentName: activeChild.name,
                        className: activeChild.className,
                      ),
                    ),
                  ),
                ),
                const Divider(height: 0),
                ListTile(
                  leading: const Icon(Icons.auto_awesome_rounded,
                      color: AppColors.parentAccent),
                  title: const Text('Trung tâm công việc'),
                  subtitle: const Text('Lịch thi, đơn xin nghỉ và báo cáo',
                      style: TextStyle(fontSize: 11)),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => MobileWorkspacePage(
                        role: 'PARENT',
                        accent: AppColors.parentAccent,
                        childId: activeChild.id,
                      ),
                    ),
                  ),
                ),
                const Divider(height: 0),
                ListTile(
                  leading: const Icon(Icons.assignment_turned_in_outlined,
                      color: AppColors.parentAccent),
                  title: const Text('Bài tập của con'),
                  subtitle: const Text('Theo dõi đã nộp, điểm và phản hồi',
                      style: TextStyle(fontSize: 11)),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => _ParentAssignmentsPage(
                      child: activeChild,
                    ),
                  )),
                ),
                const Divider(height: 0),
                ListTile(
                  leading: const Icon(Icons.chat_bubble_outline_rounded,
                      color: AppColors.parentAccent),
                  title: const Text('Liên lạc với GVCN / GV bộ môn'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const ChatListPage(
                        accent: AppColors.parentAccent,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ListTile(
            leading: const Icon(Icons.logout_rounded, color: AppColors.error),
            title: const Text('Đăng xuất',
                style: TextStyle(color: AppColors.error)),
            onTap: () =>
                context.read<AuthBloc>().add(const AuthLogoutRequested()),
          ),
        ],
      ),
    );
  }
}

class _ParentAssignmentsPage extends StatefulWidget {
  const _ParentAssignmentsPage({required this.child});

  final _Child child;

  @override
  State<_ParentAssignmentsPage> createState() => _ParentAssignmentsPageState();
}

class _ParentAssignmentsPageState extends State<_ParentAssignmentsPage>
    with WidgetsBindingObserver {
  late Future<List<List<Map<String, dynamic>>>> _future = _load();
  StreamSubscription<RealtimeEvent>? _events;

  Future<List<List<Map<String, dynamic>>>> _load() => Future.wait([
        sl<ApiService>().childAssignments(widget.child.id),
        sl<ApiService>().childSubmissions(widget.child.id),
      ]);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _events = (sl<RealtimeService>()..connect())
        .events
        .where((event) =>
            event.type == 'ASSIGNMENT_UPDATED' &&
            ('${event.data['studentId'] ?? ''}'.isEmpty ||
                '${event.data['studentId']}' == widget.child.id))
        .listen((_) => _reload());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _reload();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _events?.cancel();
    super.dispose();
  }

  void _reload() {
    if (mounted) setState(() => _future = _load());
  }

  String _statusLabel(Map<String, dynamic>? submission) {
    if (submission == null) return 'Chưa nộp';
    return switch ('${submission['status']}') {
      'SUBMITTED' => 'Đã nộp',
      'LATE' => 'Nộp trễ',
      'GRADED' => 'Đã chấm',
      'RESUBMISSION_ALLOWED' => 'Được nộp lại',
      _ => '${submission['status']}',
    };
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text('Bài tập — ${widget.child.name}'),
          backgroundColor: AppColors.parentAccent,
          actions: [
            IconButton(
              onPressed: _reload,
              icon: const Icon(Icons.refresh_rounded),
            ),
          ],
        ),
        body: FutureBuilder<List<List<Map<String, dynamic>>>>(
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
                  label: const Text('Tải lại bài tập'),
                ),
              );
            }
            final assignments = snapshot.data?.first ?? const [];
            final submissions = snapshot.data?.last ?? const [];
            final byAssignment = {
              for (final item in submissions) '${item['assignmentId']}': item,
            };
            if (assignments.isEmpty) {
              return const Center(child: Text('Chưa có bài tập đã phát hành.'));
            }
            return RefreshIndicator(
              onRefresh: () async {
                _reload();
                await _future;
              },
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: assignments.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final assignment = assignments[index];
                  final submission = byAssignment['${assignment['id']}'];
                  final score = submission?['score'] as num?;
                  final feedback = '${submission?['feedback'] ?? ''}'.trim();
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Expanded(
                              child: Text('${assignment['title']}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700)),
                            ),
                            Text(_statusLabel(submission),
                                style: const TextStyle(
                                    color: AppColors.parentAccent,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600)),
                          ]),
                          const SizedBox(height: 5),
                          Text(
                              '${assignment['subjectName']} · ${assignment['teacherName'] ?? ''}'),
                          if (assignment['deadline'] != null)
                            Text('Hạn: ${assignment['deadline']}',
                                style: Theme.of(context).textTheme.bodySmall),
                          if (score != null) ...[
                            const SizedBox(height: 8),
                            Text('Điểm: ${score.toStringAsFixed(1)}/10',
                                style: const TextStyle(
                                    color: AppColors.success,
                                    fontWeight: FontWeight.w700)),
                          ],
                          if (feedback.isNotEmpty)
                            Text('Nhận xét: $feedback',
                                style: const TextStyle(height: 1.35)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      );
}

// =================== SHARED ACTIONS ===================

class _PNotiAction extends StatelessWidget {
  const _PNotiAction();

  @override
  Widget build(BuildContext context) {
    return const LiveNotificationAction(accent: AppColors.parentAccent);
  }
}

class _PChatAction extends StatefulWidget {
  const _PChatAction();

  @override
  State<_PChatAction> createState() => _PChatActionState();
}

class _PChatActionState extends State<_PChatAction> {
  late Future<int> _unread = sl<ApiService>().chatUnreadCount();
  StreamSubscription<RealtimeEvent>? _messages;

  @override
  void initState() {
    super.initState();
    final realtime = sl<RealtimeService>()..connect();
    _messages = realtime.events
        .where((event) => event.type == 'CHAT' || event.type == 'CHAT_READ')
        .listen((_) => _reload());
  }

  void _reload() {
    if (mounted) setState(() => _unread = sl<ApiService>().chatUnreadCount());
  }

  @override
  void dispose() {
    _messages?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<int>(
      future: _unread,
      builder: (context, snapshot) {
        final unread = snapshot.data ?? 0;
        return Stack(children: [
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline_rounded),
            onPressed: () async {
              await Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => const ChatListPage(
                  accent: AppColors.parentAccent,
                ),
              ));
              _reload();
            },
          ),
          if (unread > 0)
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
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
        ]);
      },
    );
  }
}

String _parentAttendanceLabel(Object? value) =>
    switch ('$value'.toUpperCase()) {
      'PRESENT' => 'Có mặt',
      'LATE' => 'Đi muộn',
      'ABSENT_EXCUSED' => 'Vắng có phép',
      'ABSENT_UNEXCUSED' => 'Vắng không phép',
      _ => 'Chưa xác định',
    };
