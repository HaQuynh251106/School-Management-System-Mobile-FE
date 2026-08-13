import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/network/api_service.dart';
import '../../../../shared/widgets/attendance_badge.dart';
import '../../../../shared/widgets/chat_pages.dart';
import '../../../../shared/widgets/club_registration_page.dart';
import '../../../../shared/widgets/notification_center.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../../shared/widgets/adaptive_role_scaffold.dart';
import '../../../../shared/widgets/mobile_workspace_page.dart';
import '../../../../shared/widgets/school_day_status.dart';
import '../../../../shared/widgets/theme_mode_tile.dart';
import '../../../../shared/widgets/upcoming_exam_banner.dart';
import '../../../../shared/widgets/yearly_summary_page.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import 'invoice_detail.dart';
import 'parent_attendance_detail.dart';
import 'parent_subject_detail.dart';

// =================== MOCK DATA ===================

class _Child {
  const _Child({
    required this.id,
    required this.name,
    required this.className,
    required this.avatarColor,
    required this.avgScore,
    required this.presentCount,
    required this.absentCount,
  });

  final String id;
  final String name;
  final String className;
  final Color avatarColor;
  final double avgScore;
  final int presentCount;
  final int absentCount;
}

class _ARecord {
  const _ARecord(this.subject, this.date, this.status, this.note);
  final String subject;
  final String date;
  final String status;
  final String? note;
}

const _attWeek = [
  _ARecord('Tiếng Anh', '19/05', 'ABSENT_UNEXCUSED', 'Không liên lạc được PH'),
  _ARecord('Sinh học', '19/05', 'LATE', 'Muộn 10 phút'),
  _ARecord('Toán', '20/05', 'ABSENT_EXCUSED', 'Có đơn xin nghỉ ốm'),
  _ARecord('Vật lý', '21/05', 'PRESENT', null),
  _ARecord('Toán', '21/05', 'PRESENT', null),
];

const _attMonth = [
  _ARecord('Tiếng Anh', '02/05', 'PRESENT', null),
  _ARecord('Toán', '03/05', 'PRESENT', null),
  _ARecord('Vật lý', '06/05', 'LATE', 'Muộn 5 phút'),
  _ARecord('Ngữ văn', '08/05', 'ABSENT_EXCUSED', 'Đám tang ông'),
  _ARecord('Sinh học', '12/05', 'PRESENT', null),
  _ARecord('Tiếng Anh', '19/05', 'ABSENT_UNEXCUSED', 'Không liên lạc được PH'),
  _ARecord('Sinh học', '19/05', 'LATE', 'Muộn 10 phút'),
  _ARecord('Toán', '20/05', 'ABSENT_EXCUSED', 'Có đơn xin nghỉ ốm'),
];

const _attSemester = [
  _ARecord('Toán', '15/09', 'PRESENT', null),
  _ARecord('Vật lý', '22/09', 'LATE', 'Muộn 3 phút'),
  _ARecord('Tiếng Anh', '10/10', 'ABSENT_EXCUSED', 'Tham gia HSG'),
  _ARecord('Sinh học', '25/10', 'ABSENT_UNEXCUSED', 'Trốn tiết'),
  _ARecord('Ngữ văn', '08/11', 'PRESENT', null),
  _ARecord('Toán', '12/11', 'PRESENT', null),
  _ARecord('Vật lý', '20/11', 'PRESENT', null),
  _ARecord('Tiếng Anh', '02/05', 'PRESENT', null),
  _ARecord('Toán', '03/05', 'PRESENT', null),
  _ARecord('Vật lý', '06/05', 'LATE', 'Muộn 5 phút'),
  _ARecord('Ngữ văn', '08/05', 'ABSENT_EXCUSED', 'Đám tang ông'),
  _ARecord('Sinh học', '12/05', 'PRESENT', null),
  _ARecord('Tiếng Anh', '19/05', 'ABSENT_UNEXCUSED', 'Không liên lạc được PH'),
];

class _SubjectGrade {
  const _SubjectGrade(this.subject, this.scores);
  final String subject;
  final List<double?> scores; // [M, 15p, GK, CK]
}

const _gradesHk1 = [
  _SubjectGrade('Toán', [9.0, 8.5, 7.5, 8.8]),
  _SubjectGrade('Vật lý', [8.0, 7.8, 8.8, 8.0]),
  _SubjectGrade('Tiếng Anh', [7.0, 7.5, 8.0, 7.5]),
  _SubjectGrade('Ngữ văn', [7.5, 6.0, 6.5, 7.0]),
  _SubjectGrade('Sinh học', [8.5, 7.0, 8.0, 8.5]),
];

const _gradesHk2 = [
  _SubjectGrade('Toán', [8.5, 8.0, null, null]),
  _SubjectGrade('Vật lý', [9.0, null, null, null]),
  _SubjectGrade('Tiếng Anh', [7.5, null, null, null]),
  _SubjectGrade('Ngữ văn', [null, null, null, null]),
  _SubjectGrade('Sinh học', [null, null, null, null]),
];

class _Invoice {
  const _Invoice({
    required this.code,
    required this.title,
    required this.dueDate,
    required this.total,
    required this.status,
    this.paidAt,
  });
  final String code;
  final String title;
  final String dueDate;
  final int total;
  final String status;
  final String? paidAt;
}

const _invoices = [
  _Invoice(
    code: 'HD-2025-HK2-0042',
    title: 'Học phí HK2 — 2025/2026',
    dueDate: '15/06/2026',
    total: 4500000,
    status: 'PENDING',
  ),
  _Invoice(
    code: 'HD-2025-XHK-0017',
    title: 'Bảo hiểm y tế học sinh',
    dueDate: '30/05/2026',
    total: 1250000,
    status: 'OVERDUE',
  ),
  _Invoice(
    code: 'HD-2025-HK1-0042',
    title: 'Học phí HK1 — 2025/2026',
    dueDate: '15/12/2025',
    total: 4500000,
    status: 'PAID',
    paidAt: '12/12/2025',
  ),
  _Invoice(
    code: 'HD-2025-DN-0042',
    title: 'Đồng phục đầu năm',
    dueDate: '15/09/2025',
    total: 850000,
    status: 'PAID',
    paidAt: '08/09/2025',
  ),
];

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
            avgScore: (item['averageScore'] as num?)?.toDouble() ?? 0,
            presentCount: (item['presentCount'] as num?)?.toInt() ?? 0,
            absentCount: (item['absentCount'] as num?)?.toInt() ?? 0,
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
            body: Center(child: CircularProgressIndicator()),
          );
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
                      onPressed: () => setState(() {
                        _childrenFuture = _loadChildren();
                      }),
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
              onGoInvoices: () => setState(() => _tab = 3),
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
            const Text(
              'Chọn học sinh',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 16),
            ...children.asMap().entries.map((e) {
              final idx = e.key;
              final c = e.value;
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: c.avatarColor.withValues(alpha: 0.14),
                  child: Text(
                    c.name[0],
                    style: TextStyle(
                      color: c.avatarColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(c.name),
                subtitle: Text('Lớp ${c.className}'),
                trailing: _activeChild == idx
                    ? const Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.parentAccent,
                      )
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
    required this.onGoInvoices,
  });
  final _Child child;
  final VoidCallback onSwitchChild;
  final VoidCallback onGoInvoices;
  @override
  State<_MonitorTab> createState() => _MonitorTabState();
}

class _MonitorTabState extends State<_MonitorTab> {
  late Future<List<List<Map<String, dynamic>>>> _future;
  late Future<int> _pendingInvoice;
  late Future<SchoolDayStatus> _todayStatus;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  @override
  void didUpdateWidget(covariant _MonitorTab old) {
    super.didUpdateWidget(old);
    if (old.child.id != widget.child.id) setState(_reload);
  }

  void _reload() {
    final api = sl<ApiService>();
    _todayStatus = loadSchoolDayStatus(api, DateTime.now());
    _future = Future.wait([
      api.attendance(studentId: widget.child.id),
      api.grades(studentId: widget.child.id),
      api.examAgenda(childId: widget.child.id),
    ]);
    _pendingInvoice = api
        .invoices(studentId: widget.child.id)
        .then(
          (items) => items
              .where(
                (item) => const {
                  'UNPAID',
                  'PARTIAL',
                  'OVERDUE',
                }.contains(item['status']),
              )
              .fold<int>(
                0,
                (total, item) =>
                    total +
                    ((item['totalAmount'] as num?)?.toInt() ?? 0) -
                    ((item['paidAmount'] as num?)?.toInt() ?? 0),
              ),
        );
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
          FutureBuilder<SchoolDayStatus>(
            future: _todayStatus,
            builder: (context, snapshot) {
              final status = snapshot.data;
              if (status == null || !status.isHoliday) {
                return const SizedBox.shrink();
              }
              return Padding(
                padding: const EdgeInsets.only(top: 12),
                child: SchoolHolidayBanner(
                  status: status,
                  accent: AppColors.parentAccent,
                ),
              );
            },
          ),
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
          const SectionHeader(title: 'Tổng quan học kỳ'),
          const SizedBox(height: 10),
          _SummaryRow(child: child),
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
                    child: Text(
                      'Lỗi: ${snap.error}',
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                );
              }
              final data = snap.data ?? const <List<Map<String, dynamic>>>[];
              final List<Map<String, dynamic>> attRaw = data.isNotEmpty
                  ? data[0]
                  : const [];
              final List<Map<String, dynamic>> gradeRaw = data.length > 1
                  ? data[1]
                  : const [];
              final List<Map<String, dynamic>> exams = data.length > 2
                  ? data[2]
                  : const [];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  UpcomingExamBanner(
                    exams: exams,
                    accent: AppColors.parentAccent,
                    studentName: child.name,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => MobileWorkspacePage(
                          role: 'PARENT',
                          accent: AppColors.parentAccent,
                          childId: child.id,
                        ),
                      ),
                    ),
                  ),
                  if (exams.isNotEmpty) const SizedBox(height: 16),
                  _RecentAttendanceSection(child: child, records: attRaw),
                  const SizedBox(height: 16),
                  _RecentGradesSection(grades: gradeRaw),
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
    final sorted = [...records]
      ..sort(
        (a, b) => (b['date'] ?? '').toString().compareTo(
          (a['date'] ?? '').toString(),
        ),
      );
    final recent = sorted.take(4).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionHeader(title: 'Điểm danh gần đây'),
        const SizedBox(height: 10),
        if (recent.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'Chưa có dữ liệu',
              style: TextStyle(color: AppColors.textSecondary),
            ),
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
                    ),
                  ),
                ),
                title: Text(
                  subject,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                subtitle: Text(
                  note ?? date,
                  style: const TextStyle(fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AttendanceBadge(status),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.textSecondary,
                      size: 18,
                    ),
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
  const _RecentGradesSection({required this.grades});
  final List<Map<String, dynamic>> grades;

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
      ..sort(
        (a, b) => (b['recordedAt'] ?? '').toString().compareTo(
          (a['recordedAt'] ?? '').toString(),
        ),
      );
    final recent = scored.take(3).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionHeader(title: 'Top điểm gần đây'),
        const SizedBox(height: 10),
        if (recent.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'Chưa có dữ liệu',
              style: TextStyle(color: AppColors.textSecondary),
            ),
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
                    note:
                        (recent[i]['categoryName'] ??
                                _categoryLabels[(recent[i]['category'] ?? '')
                                    .toString()] ??
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
          child: Text(
            score.toStringAsFixed(1),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: _color,
              fontSize: 14,
            ),
          ),
        ),
      ),
      title: Text(
        subject,
        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
      ),
      subtitle: Text(
        note,
        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
      ),
    );
  }
}

class _InvoiceBanner extends StatelessWidget {
  const _InvoiceBanner({required this.totalPending, required this.onTap});
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
              const Icon(
                Icons.payment_rounded,
                color: AppColors.warning,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Có hóa đơn cần thanh toán',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Tổng: ${_formatVnd(totalPending)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.warning,
                      ),
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

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.child});
  final _Child child;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            value: child.avgScore.toStringAsFixed(1),
            label: 'Điểm TB',
            color: AppColors.success,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _SummaryCard(
            value:
                '${child.presentCount}/${child.presentCount + child.absentCount}',
            label: 'Có mặt',
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _SummaryCard(
            value: '${child.absentCount}',
            label: 'Vắng',
            color: child.absentCount > 0
                ? AppColors.error
                : AppColors.textSecondary,
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
  });
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
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
                child: Text(
                  child.name[0],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: child.avatarColor,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      child.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Lớp ${child.className}',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
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
                    Text(
                      'Đổi con',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.parentAccent,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(
                      Icons.swap_horiz_rounded,
                      size: 14,
                      color: AppColors.parentAccent,
                    ),
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

// =================== TAB 2: ATTENDANCE ===================

class _AttendanceTab extends StatefulWidget {
  const _AttendanceTab({required this.child});
  final _Child child;
  @override
  State<_AttendanceTab> createState() => _AttendanceTabState();
}

class _AttendanceTabState extends State<_AttendanceTab> {
  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  @override
  void didUpdateWidget(covariant _AttendanceTab old) {
    super.didUpdateWidget(old);
    if (old.child.id != widget.child.id) setState(_reload);
  }

  void _reload() {
    _future = sl<ApiService>().attendance(studentId: widget.child.id);
  }

  _ARecord _map(Map<String, dynamic> r) => _ARecord(
    (r['subjectName'] ?? '').toString(),
    (r['date'] ?? '').toString(),
    (r['status'] ?? '').toString(),
    r['note']?.toString(),
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
              child: Text(
                'Lỗi: ${snap.error}',
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            );
          }
          final records = (snap.data ?? []).map(_map).toList();
          if (records.isEmpty) {
            return const Center(
              child: Text(
                'Chưa có dữ liệu',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            );
          }
          return _AttendanceRange(
            child: widget.child,
            records: records,
            rangeLabel: 'học kỳ',
          );
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
        ...records.map(
          (r) => Card(
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
                  ),
                ),
              ),
              leading: const Icon(
                Icons.schedule_rounded,
                color: AppColors.textSecondary,
                size: 20,
              ),
              title: Text(
                r.subject,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              subtitle: Text(
                r.note ?? r.date,
                style: const TextStyle(fontSize: 12),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AttendanceBadge(r.status),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.textSecondary,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        ),
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
                  Text(
                    '${entry.value}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: colors[i],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    entry.key,
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
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
                Text(
                  '$percent%',
                  style: TextStyle(
                    color: _color,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tỉ lệ chuyên cần $rangeLabel',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
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

class _GradesTabState extends State<_GradesTab> {
  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  @override
  void didUpdateWidget(covariant _GradesTab old) {
    super.didUpdateWidget(old);
    if (old.child.id != widget.child.id) setState(_reload);
  }

  void _reload() {
    _future = sl<ApiService>().grades(studentId: widget.child.id);
  }

  /// Group raw grades by subjectName, building [_SubjectGrade] with scores
  /// in order [ORAL, 15M, MID, FINAL] (null if absent).
  List<_SubjectGrade> _group(List<Map<String, dynamic>> raw) {
    const order = ['ORAL', '15M', 'MID', 'FINAL'];
    final bySubject = <String, List<double?>>{};
    for (final g in raw) {
      final subject = (g['subjectName'] ?? '').toString();
      final scores = bySubject.putIfAbsent(
        subject,
        () => List<double?>.filled(order.length, null),
      );
      final idx = order.indexOf((g['category'] ?? '').toString());
      if (idx >= 0) {
        final score = g['score'];
        if (score is num) scores[idx] = score.toDouble();
      }
    }
    final result = bySubject.entries
        .map((e) => _SubjectGrade(e.key, e.value))
        .toList();
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
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(
              child: Text(
                'Lỗi: ${snap.error}',
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            );
          }
          final subjects = _group(snap.data ?? []);
          if (subjects.isEmpty) {
            return const Center(
              child: Text(
                'Chưa có dữ liệu',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            );
          }
          return _SemesterGrades(
            child: widget.child,
            semester: 'Năm học 2025/2026',
            subjects: subjects,
          );
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
  });
  final _Child child;
  final String semester;
  final List<_SubjectGrade> subjects;

  double? _avg(_SubjectGrade sg) {
    const weights = [1, 1, 2, 3];
    var sum = 0.0;
    var sumW = 0;
    for (var i = 0; i < sg.scores.length; i++) {
      if (sg.scores[i] != null) {
        sum += sg.scores[i]! * weights[i];
        sumW += weights[i];
      }
    }
    return sumW == 0 ? null : sum / sumW;
  }

  Color _avgColor(double avg) {
    if (avg >= 8) return AppColors.success;
    if (avg >= 6.5) return AppColors.warning;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    final allAvgs = subjects.map(_avg).whereType<double>().toList();
    final overall = allAvgs.isEmpty
        ? null
        : allAvgs.reduce((a, b) => a + b) / allAvgs.length;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: ListTile(
            leading: const Icon(
              Icons.school_outlined,
              color: AppColors.parentAccent,
            ),
            title: const Text(
              'Tổng kết năm học',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            subtitle: const Text(
              'Xem điểm cả năm, hạnh kiểm và kết quả lên lớp.',
            ),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => YearlySummaryPage(
                  studentId: child.id,
                  studentName: child.name,
                  accent: AppColors.parentAccent,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
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
              const Icon(
                Icons.auto_graph_rounded,
                color: Colors.white70,
                size: 36,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      semester,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      overall == null
                          ? 'Chưa có điểm'
                          : 'TB: ${overall.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
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
          final avg = _avg(sg);
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ParentSubjectDetail(
                    childName: child.name,
                    subject: sg.subject,
                    semester: semester,
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
                        color:
                            (avg != null ? _avgColor(avg) : AppColors.divider)
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
                                : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            sg.subject,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'M: ${sg.scores[0]?.toStringAsFixed(1) ?? "—"} • '
                            '15p: ${sg.scores[1]?.toStringAsFixed(1) ?? "—"} • '
                            'GK: ${sg.scores[2]?.toStringAsFixed(1) ?? "—"} • '
                            'CK: ${sg.scores[3]?.toStringAsFixed(1) ?? "—"}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.textSecondary,
                    ),
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

class _InvoicesTabState extends State<_InvoicesTab> {
  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  @override
  void didUpdateWidget(covariant _InvoicesTab old) {
    super.didUpdateWidget(old);
    if (old.child.id != widget.child.id) setState(_reload);
  }

  void _reload() {
    _future = sl<ApiService>().invoices(studentId: widget.child.id);
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
      final detail = await sl<ApiService>().invoiceDetail(
        summary['id'].toString(),
      );
      if (!mounted) return;
      final invoice = (detail['invoice'] as Map).cast<String, dynamic>();
      final items = (detail['items'] as List? ?? const [])
          .map((raw) => (raw as Map).cast<String, dynamic>())
          .map(
            (item) => InvoiceLineItem(
              (item['name'] ?? '').toString(),
              (item['amount'] as num?)?.toInt() ?? 0,
            ),
          )
          .toList();
      final payments = (detail['payments'] as List? ?? const [])
          .map((raw) => (raw as Map).cast<String, dynamic>())
          .toList();
      final paymentHistory = payments
          .where((item) => item['status'] == 'SUCCESS')
          .map(
            (item) => InvoicePaymentItem(
              amount: (item['amount'] as num?)?.toInt() ?? 0,
              method: (item['method'] ?? '').toString(),
              paidAt: (item['paidAt'] ?? item['createdAt'] ?? '').toString(),
              receiptCode: (item['receiptCode'] ?? item['txnRef'] ?? '')
                  .toString(),
              payerName: item['payerName']?.toString(),
              note: item['note']?.toString(),
            ),
          )
          .toList();
      final refunds = (detail['refunds'] as List? ?? const [])
          .map((raw) => (raw as Map).cast<String, dynamic>())
          .map(
            (item) => InvoiceRefundItem(
              (item['amount'] as num?)?.toInt() ?? 0,
              (item['reason'] ?? '').toString(),
              (item['createdAt'] ?? '').toString(),
            ),
          )
          .toList();
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => InvoiceDetailPage(
            invoiceId: (invoice['id'] ?? summary['id']).toString(),
            invoiceCode: (invoice['code'] ?? '').toString(),
            childName: (invoice['studentName'] ?? widget.child.name).toString(),
            semester: (invoice['feePeriodId'] ?? 'Hóa đơn học phí').toString(),
            dueDate: (invoice['dueDate'] ?? '').toString(),
            status: (invoice['status'] ?? '').toString(),
            paidAmount: (invoice['paidAmount'] as num?)?.toInt() ?? 0,
            refundedAmount: (invoice['refundedAmount'] as num?)?.toInt() ?? 0,
            refunds: refunds,
            payments: paymentHistory,
            paidAt: payments.isEmpty
                ? null
                : payments.last['paidAt']?.toString(),
            paidMethod: payments.isEmpty
                ? null
                : payments.last['method']?.toString(),
            transactionRef: payments.isEmpty
                ? null
                : payments.last['txnRef']?.toString(),
            items: items,
          ),
        ),
      );
      if (mounted) setState(_reload);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Không thể tải chi tiết: $e')));
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
              child: Text(
                'Lỗi: ${snap.error}',
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            );
          }
          final invoices = snap.data ?? [];
          if (invoices.isEmpty) {
            return const Center(
              child: Text(
                'Chưa có hóa đơn. Vui lòng liên hệ nhà trường.',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: invoices.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) {
              final inv = invoices[i];
              final status = (inv['status'] ?? '').toString();
              final payable = const {
                'UNPAID',
                'PARTIAL',
                'OVERDUE',
              }.contains(status);
              final color = switch (status) {
                'PAID' => AppColors.success,
                'OVERDUE' => AppColors.error,
                'REFUNDED' => AppColors.textSecondary,
                'CANCELLED' => AppColors.textSecondary,
                _ => AppColors.warning,
              };
              final label = switch (status) {
                'PAID' => 'Đã thanh toán',
                'PARTIAL' => 'Một phần',
                'OVERDUE' => 'Quá hạn',
                'PARTIALLY_REFUNDED' => 'Hoàn một phần',
                'REFUNDED' => 'Đã hoàn tiền',
                'CANCELLED' => 'Đã hủy',
                _ => 'Chưa thanh toán',
              };
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
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              label,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            (inv['code'] ?? '').toString(),
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'HS: ${inv['studentName'] ?? ''}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Text(
                            _vnd((inv['totalAmount'] ?? 0) as num),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: color,
                              fontSize: 16,
                            ),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: () => _openDetail(inv),
                            child: const Text('Chi tiết'),
                          ),
                          if (payable)
                            FilledButton.icon(
                              onPressed: () => _openDetail(inv),
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.parentAccent,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              icon: const Icon(Icons.payment_rounded, size: 16),
                              label: const Text(
                                'Tạo VietQR',
                                style: TextStyle(fontSize: 12),
                              ),
                            )
                          else
                            Text(
                              label,
                              style: TextStyle(fontSize: 12, color: color),
                            ),
                        ],
                      ),
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

class _InvoiceList extends StatelessWidget {
  const _InvoiceList({
    required this.invoices,
    required this.childName,
    required this.empty,
  });
  final List<_Invoice> invoices;
  final String childName;
  final String empty;

  String _formatVnd(int amount) {
    final s = amount.toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return '${buf.toString()} ₫';
  }

  Color _statusColor(String status) => switch (status) {
    'PAID' => AppColors.success,
    'OVERDUE' => AppColors.error,
    _ => AppColors.warning,
  };

  String _statusLabel(String status) => switch (status) {
    'PAID' => 'Đã thanh toán',
    'OVERDUE' => 'Quá hạn',
    _ => 'Chưa TT',
  };

  @override
  Widget build(BuildContext context) {
    if (invoices.isEmpty) {
      return Center(
        child: Text(
          empty,
          style: const TextStyle(color: AppColors.textSecondary),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: invoices.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) {
        final inv = invoices[i];
        final color = _statusColor(inv.status);
        return Card(
          margin: EdgeInsets.zero,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => InvoiceDetailPage(
                  invoiceCode: inv.code,
                  childName: childName,
                  semester: inv.title,
                  dueDate: inv.dueDate,
                  status: inv.status,
                  paidAt: inv.paidAt,
                  items: _mockItems(inv.title, inv.total),
                ),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _statusLabel(inv.status),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        inv.code,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    inv.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.event_rounded,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        inv.status == 'PAID'
                            ? 'Đã TT: ${inv.paidAt}'
                            : 'Hạn: ${inv.dueDate}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        _formatVnd(inv.total),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: color,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  List<InvoiceLineItem> _mockItems(String title, int total) {
    if (title.contains('Bảo hiểm')) {
      return const [
        InvoiceLineItem('Bảo hiểm y tế', 650000),
        InvoiceLineItem('Phí dịch vụ học tập', 600000),
      ];
    }
    if (title.contains('Đồng phục')) {
      return const [
        InvoiceLineItem('2 áo trắng', 350000),
        InvoiceLineItem('2 quần xanh', 350000),
        InvoiceLineItem('Cà vạt', 150000),
      ];
    }
    return [
      const InvoiceLineItem('Học phí', 3500000),
      const InvoiceLineItem('Tiền ăn trưa', 800000),
      InvoiceLineItem('Khác', total - 3500000 - 800000),
    ];
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
                    child: Icon(
                      Icons.family_restroom_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user.fullName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.email ?? user.username,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.parentAccent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Đang xem: ${activeChild.name} (${activeChild.className})',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.parentAccent,
                        fontWeight: FontWeight.w600,
                      ),
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
                  leading: const Icon(
                    Icons.swap_horiz_rounded,
                    color: AppColors.parentAccent,
                  ),
                  title: const Text('Chuyển học sinh'),
                  subtitle: Text(
                    '$childrenCount con liên kết',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: onSwitchChild,
                ),
                const Divider(height: 0),
                ListTile(
                  leading: const Icon(
                    Icons.auto_awesome_rounded,
                    color: AppColors.parentAccent,
                  ),
                  title: const Text('Trung tâm công việc'),
                  subtitle: const Text(
                    'Lịch thi, đơn xin nghỉ và báo cáo',
                    style: TextStyle(fontSize: 11),
                  ),
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
                  leading: const Icon(
                    Icons.groups_outlined,
                    color: AppColors.parentAccent,
                  ),
                  title: const Text('Câu lạc bộ'),
                  subtitle: Text(
                    'Đăng ký cho ${activeChild.name}',
                    style: const TextStyle(fontSize: 11),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ClubRegistrationPage(
                        accent: AppColors.parentAccent,
                        childId: activeChild.id,
                        childName: activeChild.name,
                      ),
                    ),
                  ),
                ),
                const Divider(height: 0),
                ListTile(
                  leading: const Icon(
                    Icons.chat_bubble_outline_rounded,
                    color: AppColors.parentAccent,
                  ),
                  title: const Text('Liên lạc với GVCN / GV bộ môn'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const ChatListPage(
                        accent: AppColors.parentAccent,
                        threads: _parentThreads,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const SectionHeader(title: 'Cài đặt'),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(
                    Icons.notifications_outlined,
                    color: AppColors.parentAccent,
                  ),
                  title: const Text('Cài đặt thông báo'),
                  trailing: Switch(value: true, onChanged: (_) {}),
                ),
                const Divider(height: 0),
                ListTile(
                  leading: const Icon(
                    Icons.security_outlined,
                    color: AppColors.parentAccent,
                  ),
                  title: const Text('Đổi mật khẩu'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {},
                ),
                const Divider(height: 0),
                const ListTile(
                  leading: Icon(
                    Icons.info_outline_rounded,
                    color: AppColors.parentAccent,
                  ),
                  title: Text('Phiên bản'),
                  trailing: Text(
                    '0.1.0',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ListTile(
            leading: const Icon(Icons.logout_rounded, color: AppColors.error),
            title: const Text(
              'Đăng xuất',
              style: TextStyle(color: AppColors.error),
            ),
            onTap: () =>
                context.read<AuthBloc>().add(const AuthLogoutRequested()),
          ),
        ],
      ),
    );
  }
}

// =================== SHARED ACTIONS ===================

const _parentThreads = <ChatThread>[
  ChatThread(
    name: 'Trần Thị Hoa',
    role: 'GVCN lớp 10A1',
    lastMessage: 'Vâng anh chị, em nắm rồi. Bài tập về nhà cô sẽ gửi qua app.',
    lastTime: '08:32',
    unread: 0,
  ),
  ChatThread(
    name: 'Lê Văn Minh',
    role: 'GV Vật lý 10A1',
    lastMessage: 'Em An làm bài kiểm tra rất tốt, anh chị động viên cháu nhé.',
    lastTime: 'Hôm qua',
    unread: 1,
  ),
  ChatThread(
    name: 'Phạm Quốc Bảo',
    role: 'GV Tiếng Anh 10A1',
    lastMessage: 'Lịch thi GK sẽ được dời sang tuần sau.',
    lastTime: '3 ngày trước',
    unread: 0,
  ),
  ChatThread(
    name: 'Lớp 10A1',
    role: 'Thông báo từ GVCN',
    lastMessage: 'Cô gửi bài tập về nhà chương 3 nhé!',
    lastTime: 'Hôm qua',
    unread: 0,
    isBroadcast: true,
  ),
];

class _PNotiAction extends StatelessWidget {
  const _PNotiAction();

  @override
  Widget build(BuildContext context) {
    return const LiveNotificationAction(accent: AppColors.parentAccent);
  }
}

class _PChatAction extends StatelessWidget {
  const _PChatAction();

  @override
  Widget build(BuildContext context) {
    final unread = _parentThreads.fold<int>(0, (s, t) => s + t.unread);
    return Padding(
      padding: const EdgeInsets.only(right: 0),
      child: Stack(
        children: [
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline_rounded),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const ChatListPage(
                  accent: AppColors.parentAccent,
                  threads: _parentThreads,
                ),
              ),
            ),
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
                child: Text(
                  '$unread',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
