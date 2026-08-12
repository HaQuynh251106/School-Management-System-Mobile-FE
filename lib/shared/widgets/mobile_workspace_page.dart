import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/di/service_locator.dart';
import '../../core/network/api_service.dart';
import '../../core/theme/app_colors.dart';
import 'real_dashboard_panel.dart';

class MobileWorkspacePage extends StatefulWidget {
  const MobileWorkspacePage({
    super.key,
    required this.role,
    required this.accent,
    this.childId,
  });

  final String role;
  final Color accent;
  final String? childId;

  @override
  State<MobileWorkspacePage> createState() => _MobileWorkspacePageState();
}

class _MobileWorkspacePageState extends State<MobileWorkspacePage> {
  late Future<_WorkspaceData> _future = _load();

  Future<_WorkspaceData> _load() async {
    final api = sl<ApiService>();
    final dashboard = Map<String, dynamic>.from(
      await api.dashboard(childId: widget.childId),
    );
    final errors = <Map<String, dynamic>>[
      ...?((dashboard['errors'] as List?)?.whereType<Map>().map(
        (item) => item.cast<String, dynamic>(),
      )),
    ];

    var leaves = <Map<String, dynamic>>[];
    if (widget.role != 'ADMIN') {
      try {
        leaves = await api.leaveRequests();
      } catch (_) {
        errors.add(
          _partialError('leaveRequests', 'Không tải được đơn xin nghỉ'),
        );
      }
    }

    var exams = <Map<String, dynamic>>[];
    try {
      exams = switch (widget.role) {
        'ADMIN' => await api.examPeriods(),
        'TEACHER' => await api.examGradingTasks(),
        _ => await api.examAgenda(childId: widget.childId),
      };
    } catch (_) {
      errors.add(_partialError('exams', 'Không tải được dữ liệu khảo thí'));
    }

    var report = <String, dynamic>{};
    if (widget.role != 'ADMIN') {
      try {
        report = await api.personalReport(childId: widget.childId);
      } catch (_) {
        errors.add(
          _partialError('personalReport', 'Không tải được báo cáo cá nhân'),
        );
      }
    }
    dashboard['errors'] = errors;
    return _WorkspaceData(dashboard, leaves, exams, report);
  }

  Map<String, dynamic> _partialError(String widget, String message) => {
    'widget': widget,
    'code': 'PARTIAL_SOURCE_ERROR',
    'message': message,
    'retryable': true,
  };

  Future<void> _refresh() async {
    setState(() {
      _future = _load();
    });
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Trung tâm công việc')),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<_WorkspaceData>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return _ErrorView(error: snapshot.error, onRetry: _refresh);
            }
            final data = snapshot.data!;
            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              children: [
                _Hero(accent: widget.accent, role: widget.role),
                const SizedBox(height: 18),
                RealDashboardPanel(
                  dashboard: data.dashboard,
                  accent: widget.accent,
                  onRetry: _refresh,
                  onShortcut: (shortcut) => Navigator.of(context).pop(shortcut),
                ),
                const SizedBox(height: 24),
                _SectionTitle(
                  icon: Icons.event_available_rounded,
                  title: widget.role == 'ADMIN'
                      ? 'Kỳ thi đang quản lý'
                      : widget.role == 'TEACHER'
                      ? 'Nhiệm vụ khảo thí'
                      : 'Lịch kiểm tra sắp tới',
                  count: data.exams.length,
                ),
                const SizedBox(height: 10),
                _DataCards(
                  items: data.exams,
                  emptyText: 'Chưa có lịch hoặc nhiệm vụ khảo thí',
                  accent: widget.accent,
                  type: _CardType.exam,
                ),
                if (widget.role != 'ADMIN') ...[
                  const SizedBox(height: 24),
                  _SectionTitle(
                    icon: Icons.medical_information_outlined,
                    title: 'Đơn xin nghỉ học',
                    count: data.leaves.length,
                    actionLabel: widget.role == 'STUDENT' ? 'Tạo đơn' : null,
                    onAction: widget.role == 'STUDENT' ? _createLeave : null,
                  ),
                  const SizedBox(height: 10),
                  _LeaveCards(
                    items: data.leaves,
                    role: widget.role,
                    accent: widget.accent,
                    onDecision: _decide,
                  ),
                  const SizedBox(height: 24),
                  _SectionTitle(
                    icon: Icons.insights_rounded,
                    title: 'Báo cáo cá nhân',
                    count: data.report.length,
                    actionLabel: 'Xuất CSV',
                    onAction: _exportPersonalReport,
                  ),
                  const SizedBox(height: 10),
                  _ReportCard(data.report),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _createLeave() async {
    final reason = TextEditingController();
    var start = DateTime.now().add(const Duration(days: 1));
    var end = start;
    final accepted = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, update) => Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            8,
            20,
            20 + MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Tạo đơn xin nghỉ',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _DateButton(
                      label: 'Từ ngày',
                      date: start,
                      onPick: () async {
                        final picked = await showDatePicker(
                          context: context,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(
                            const Duration(days: 365),
                          ),
                          initialDate: start,
                        );
                        if (picked != null) update(() => start = picked);
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _DateButton(
                      label: 'Đến ngày',
                      date: end,
                      onPick: () async {
                        final picked = await showDatePicker(
                          context: context,
                          firstDate: start,
                          lastDate: DateTime.now().add(
                            const Duration(days: 365),
                          ),
                          initialDate: end.isBefore(start) ? start : end,
                        );
                        if (picked != null) update(() => end = picked);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: reason,
                minLines: 3,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Lý do nghỉ học',
                  hintText: 'Mô tả rõ lý do để phụ huynh và GVCN xác nhận',
                ),
              ),
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: () {
                  if (reason.text.trim().isNotEmpty) {
                    Navigator.pop(sheetContext, true);
                  }
                },
                icon: const Icon(Icons.send_rounded),
                label: const Text('Gửi đơn'),
              ),
            ],
          ),
        ),
      ),
    );
    if (accepted != true) {
      reason.dispose();
      return;
    }
    try {
      await sl<ApiService>().createLeaveRequest(
        startDate: DateFormat('yyyy-MM-dd').format(start),
        endDate: DateFormat('yyyy-MM-dd').format(end),
        reason: reason.text.trim(),
      );
      await _refresh();
    } catch (error) {
      if (mounted) _showError('Không thể tạo đơn: $error');
    } finally {
      reason.dispose();
    }
  }

  Future<void> _decide(String id, String action) async {
    try {
      await sl<ApiService>().decideLeaveRequest(id, action);
      await _refresh();
    } catch (error) {
      if (mounted) _showError('Không thể cập nhật đơn: $error');
    }
  }

  Future<void> _exportPersonalReport() async {
    try {
      final bytes = await sl<ApiService>().exportPersonalReport(
        childId: widget.childId,
      );
      final stamp = DateFormat('yyyyMMdd-HHmmss').format(DateTime.now());
      await FilePicker.platform.saveFile(
        dialogTitle: 'Lưu báo cáo cá nhân',
        fileName: 'bao-cao-ca-nhan-$stamp.csv',
        bytes: Uint8List.fromList(bytes),
      );
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Đã tạo báo cáo cá nhân')));
      }
    } catch (error) {
      if (mounted) _showError('Không thể export báo cáo: $error');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _WorkspaceData {
  const _WorkspaceData(this.dashboard, this.leaves, this.exams, this.report);
  final Map<String, dynamic> dashboard;
  final List<Map<String, dynamic>> leaves;
  final List<Map<String, dynamic>> exams;
  final Map<String, dynamic> report;
}

class _Hero extends StatelessWidget {
  const _Hero({required this.accent, required this.role});
  final Color accent;
  final String role;

  @override
  Widget build(BuildContext context) {
    final subtitle = switch (role) {
      'ADMIN' => 'Theo dõi vận hành và công việc quan trọng toàn trường',
      'TEACHER' => 'Lịch dạy, khảo thí và yêu cầu cần xử lý',
      'PARENT' => 'Đồng hành cùng quá trình học tập của con',
      _ => 'Nắm nhanh lịch học và nhiệm vụ của bạn',
    };
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [accent, Color.lerp(accent, Colors.black, .24)!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .16),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: Colors.white,
              size: 27,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Hôm nay của bạn',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardMetrics extends StatelessWidget {
  const _DashboardMetrics({required this.dashboard, required this.accent});
  final Map<String, dynamic> dashboard;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final raw = dashboard['metrics'];
    final metrics = raw is List
        ? raw.cast<Map>().map((item) => item.cast<String, dynamic>()).take(4)
        : const <Map<String, dynamic>>[];
    if (metrics.isEmpty) return const SizedBox.shrink();
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: metrics.map((metric) {
        final width = (MediaQuery.sizeOf(context).width - 42) / 2;
        return SizedBox(
          width: width.clamp(150, 260),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.trending_up_rounded, color: accent, size: 21),
                  const SizedBox(height: 10),
                  Text(
                    '${metric['value'] ?? '—'}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${metric['label'] ?? ''}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.icon,
    required this.title,
    required this.count,
    this.actionLabel,
    this.onAction,
  });
  final IconData icon;
  final String title;
  final int count;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, size: 21, color: Theme.of(context).colorScheme.primary),
      const SizedBox(width: 9),
      Expanded(
        child: Text(
          '$title ($count)',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
      if (actionLabel != null)
        TextButton.icon(
          onPressed: onAction,
          icon: const Icon(Icons.add_rounded, size: 18),
          label: Text(actionLabel!),
        ),
    ],
  );
}

enum _CardType { exam }

class _DataCards extends StatelessWidget {
  const _DataCards({
    required this.items,
    required this.emptyText,
    required this.accent,
    required this.type,
  });
  final List<Map<String, dynamic>> items;
  final String emptyText;
  final Color accent;
  final _CardType type;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return _EmptyCard(text: emptyText);
    return Column(
      children: items.take(6).map((item) {
        final title =
            item['examName'] ??
            item['examPeriodName'] ??
            item['periodName'] ??
            item['name'] ??
            item['subjectName'] ??
            item['title'] ??
            'Nội dung khảo thí';
        final status =
            item['status'] ?? item['taskStatus'] ?? item['scheduleStatus'];
        final detail =
            item['examDate'] ??
            item['startDate'] ??
            item['date'] ??
            item['startsAt'] ??
            item['roomCode'] ??
            '';
        return Padding(
          padding: const EdgeInsets.only(bottom: 9),
          child: Card(
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 7,
              ),
              leading: CircleAvatar(
                backgroundColor: accent.withValues(alpha: .12),
                child: Icon(Icons.event_note_rounded, color: accent),
              ),
              title: Text(
                '$title',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: Text(
                '$detail',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: status == null
                  ? const Icon(Icons.chevron_right_rounded)
                  : _StatusChip('$status', accent),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _LeaveCards extends StatelessWidget {
  const _LeaveCards({
    required this.items,
    required this.role,
    required this.accent,
    required this.onDecision,
  });
  final List<Map<String, dynamic>> items;
  final String role;
  final Color accent;
  final void Function(String id, String action) onDecision;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const _EmptyCard(text: 'Chưa có đơn xin nghỉ');
    return Column(
      children: items.map((item) {
        final id = '${item['id'] ?? ''}';
        final status = '${item['status'] ?? ''}';
        final actions = <Widget>[];
        if (role == 'PARENT' && status == 'PENDING_PARENT') {
          actions.addAll([
            TextButton(
              onPressed: () => onDecision(id, 'parent-reject'),
              child: const Text('Từ chối'),
            ),
            FilledButton(
              onPressed: () => onDecision(id, 'parent-confirm'),
              child: const Text('Xác nhận'),
            ),
          ]);
        }
        if (role == 'TEACHER' &&
            (status == 'PARENT_CONFIRMED' || status == 'PENDING_TEACHER')) {
          actions.addAll([
            TextButton(
              onPressed: () => onDecision(id, 'reject'),
              child: const Text('Từ chối'),
            ),
            FilledButton(
              onPressed: () => onDecision(id, 'approve'),
              child: const Text('Duyệt'),
            ),
          ]);
        }
        if (role == 'STUDENT' &&
            (status.startsWith('PENDING') || status == 'PARENT_CONFIRMED')) {
          actions.add(
            OutlinedButton(
              onPressed: () => onDecision(id, 'cancel'),
              child: const Text('Hủy đơn'),
            ),
          );
        }
        return Padding(
          padding: const EdgeInsets.only(bottom: 9),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${item['studentName'] ?? 'Học sinh'}',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                      _StatusChip(status, accent),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('${item['startDate'] ?? ''} → ${item['endDate'] ?? ''}'),
                  const SizedBox(height: 5),
                  Text(
                    '${item['reason'] ?? ''}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (actions.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children:
                          actions
                              .expand(
                                (button) => [button, const SizedBox(width: 8)],
                              )
                              .toList()
                            ..removeLast(),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _ReportCard extends StatelessWidget {
  const _ReportCard(this.report);
  final Map<String, dynamic> report;

  @override
  Widget build(BuildContext context) {
    if (report.isEmpty) {
      return const _EmptyCard(text: 'Chưa có dữ liệu báo cáo');
    }
    final entries = report.entries
        .where(
          (entry) =>
              entry.value is String ||
              entry.value is num ||
              entry.value is bool,
        )
        .take(6);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: entries
              .map(
                (entry) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 7),
                  child: Row(
                    children: [
                      Expanded(child: Text(_humanize(entry.key))),
                      Text(
                        '${entry.value}',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class _DateButton extends StatelessWidget {
  const _DateButton({
    required this.label,
    required this.date,
    required this.onPick,
  });
  final String label;
  final DateTime date;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) => OutlinedButton(
    onPressed: onPick,
    child: Column(
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 3),
        Text(DateFormat('dd/MM/yyyy').format(date)),
      ],
    ),
  );
}

class _StatusChip extends StatelessWidget {
  const _StatusChip(this.status, this.accent);
  final String status;
  final Color accent;

  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(maxWidth: 110),
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
    decoration: BoxDecoration(
      color: accent.withValues(alpha: .1),
      borderRadius: BorderRadius.circular(99),
    ),
    child: Text(
      _humanize(status),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: accent,
        fontSize: 10,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    ),
  );
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.error, required this.onRetry});
  final Object? error;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(32),
    children: [
      const Icon(Icons.cloud_off_rounded, size: 52, color: AppColors.error),
      const SizedBox(height: 16),
      Text(
        'Không thể tải trung tâm công việc',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.titleLarge,
      ),
      const SizedBox(height: 8),
      Text(
        '$error',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodySmall,
      ),
      const SizedBox(height: 20),
      FilledButton.icon(
        onPressed: onRetry,
        icon: const Icon(Icons.refresh_rounded),
        label: const Text('Thử lại'),
      ),
    ],
  );
}

String _humanize(String value) => value
    .replaceAll('_', ' ')
    .split(' ')
    .where((part) => part.isNotEmpty)
    .map((part) => '${part[0].toUpperCase()}${part.substring(1).toLowerCase()}')
    .join(' ');
