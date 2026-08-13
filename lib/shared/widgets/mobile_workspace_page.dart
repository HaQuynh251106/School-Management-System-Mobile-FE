import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/di/service_locator.dart';
import '../../core/network/api_service.dart';
import '../../core/network/realtime_service.dart';
import '../../core/theme/app_colors.dart';

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

class _MobileWorkspacePageState extends State<MobileWorkspacePage>
    with WidgetsBindingObserver {
  late Future<_WorkspaceData> _future = _load();
  StreamSubscription<RealtimeEvent>? _workspaceEvents;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final realtime = sl<RealtimeService>()..connect();
    _workspaceEvents = realtime.events
        .where((event) =>
            event.type == 'EXAM_UPDATED' || event.type == 'LEAVE_UPDATED')
        .listen((_) => _reload());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _reload();
  }

  @override
  void didUpdateWidget(covariant MobileWorkspacePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.childId != widget.childId || oldWidget.role != widget.role) {
      _reload();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _workspaceEvents?.cancel();
    super.dispose();
  }

  void _reload() {
    if (mounted) setState(() => _future = _load());
  }

  Future<_WorkspaceData> _load() async {
    final api = sl<ApiService>();
    final dashboard = await api.dashboard(childId: widget.childId);
    final leaves = widget.role == 'ADMIN'
        ? const <Map<String, dynamic>>[]
        : await api.leaveRequests();
    final exams = switch (widget.role) {
      'ADMIN' => await api.examPeriods(),
      'TEACHER' => await api.examAgenda(),
      _ => await api.examAgenda(childId: widget.childId),
    };
    final gradingTasks = widget.role == 'TEACHER'
        ? await api.examGradingTasks()
        : const <Map<String, dynamic>>[];
    final results = switch (widget.role) {
      'STUDENT' => await api.examResults(),
      'PARENT' when widget.childId != null =>
        await api.childExamResults(widget.childId!),
      _ => const <Map<String, dynamic>>[],
    };
    final reviews = widget.role == 'TEACHER'
        ? await api.examReviews(status: 'PENDING')
        : const <Map<String, dynamic>>[];
    final report = widget.role == 'ADMIN'
        ? <String, dynamic>{}
        : await api.personalReport(childId: widget.childId);
    return _WorkspaceData(
      dashboard,
      leaves,
      exams,
      gradingTasks,
      results,
      reviews,
      report,
    );
  }

  Future<void> _refresh() async {
    setState(() => _future = _load());
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
              return _ErrorView(onRetry: _refresh);
            }
            final data = snapshot.data!;
            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              children: [
                _Hero(accent: widget.accent, role: widget.role),
                const SizedBox(height: 18),
                _DashboardMetrics(
                    dashboard: data.dashboard, accent: widget.accent),
                const SizedBox(height: 24),
                _SectionTitle(
                  icon: Icons.event_available_rounded,
                  title: widget.role == 'ADMIN'
                      ? 'Kỳ thi đang quản lý'
                      : widget.role == 'TEACHER'
                          ? 'Lịch coi thi'
                          : 'Lịch kiểm tra sắp tới',
                  count: data.exams.length,
                ),
                const SizedBox(height: 10),
                _DataCards(
                  items: data.exams,
                  emptyText: widget.role == 'TEACHER'
                      ? 'Chưa có lịch coi thi được phân công'
                      : 'Chưa có lịch hoặc nhiệm vụ khảo thí',
                  accent: widget.accent,
                  type: _CardType.exam,
                ),
                if (widget.role == 'TEACHER') ...[
                  const SizedBox(height: 24),
                  _SectionTitle(
                    icon: Icons.edit_note_rounded,
                    title: 'Nhiệm vụ nhập điểm thi',
                    count: data.gradingTasks.length,
                  ),
                  const SizedBox(height: 10),
                  _TeacherExamTasks(
                    items: data.gradingTasks,
                    accent: widget.accent,
                    onOpen: _editExamScores,
                  ),
                  const SizedBox(height: 24),
                  _SectionTitle(
                    icon: Icons.fact_check_outlined,
                    title: 'Phúc khảo chờ xử lý',
                    count: data.reviews.length,
                  ),
                  const SizedBox(height: 10),
                  _ExamReviewCards(
                    items: data.reviews,
                    accent: widget.accent,
                    onOpen: _resolveReview,
                  ),
                ],
                if (widget.role == 'STUDENT' || widget.role == 'PARENT') ...[
                  const SizedBox(height: 24),
                  _SectionTitle(
                    icon: Icons.school_outlined,
                    title: 'Kết quả thi đã công bố',
                    count: data.results.length,
                  ),
                  const SizedBox(height: 10),
                  _ExamResultCards(
                    items: data.results,
                    accent: widget.accent,
                    canRequestReview: widget.role == 'STUDENT',
                    onReview: _requestReview,
                  ),
                ],
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
              Text('Tạo đơn xin nghỉ',
                  style: Theme.of(context).textTheme.titleLarge),
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
                          lastDate:
                              DateTime.now().add(const Duration(days: 365)),
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
                          lastDate:
                              DateTime.now().add(const Duration(days: 365)),
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
      if (mounted) _showError('Không thể gửi đơn. Vui lòng thử lại.');
    } finally {
      reason.dispose();
    }
  }

  Future<void> _decide(String id, String action) async {
    try {
      await sl<ApiService>().decideLeaveRequest(id, action);
      await _refresh();
    } catch (error) {
      if (mounted) _showError('Không thể cập nhật đơn. Vui lòng thử lại.');
    }
  }

  Future<void> _editExamScores(Map<String, dynamic> task) async {
    final candidates = (task['candidates'] as List? ?? const [])
        .map((value) => Map<String, dynamic>.from(value as Map))
        .toList();
    if (candidates.isEmpty) {
      return _showError('Lớp này chưa có thí sinh để nhập điểm.');
    }
    if (task['scoreEntryAvailable'] != true ||
        task['scoreEntryLocked'] == true) {
      return _showError(task['scoreEntryLocked'] == true
          ? 'Kỳ thi đã khóa nhập điểm.'
          : 'Chưa đến thời gian được nhập điểm.');
    }
    final scoreControllers = [
      for (final candidate in candidates)
        TextEditingController(text: '${candidate['score'] ?? ''}'),
    ];
    final noteControllers = [
      for (final candidate in candidates)
        TextEditingController(text: '${candidate['note'] ?? ''}'),
    ];
    final formKey = GlobalKey<FormState>();
    final accepted = await showModalBottomSheet<bool>(
          context: context,
          isScrollControlled: true,
          useSafeArea: true,
          builder: (sheetContext) => Padding(
            padding: EdgeInsets.fromLTRB(
              16,
              12,
              16,
              16 + MediaQuery.viewInsetsOf(sheetContext).bottom,
            ),
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  Row(children: [
                    Expanded(
                      child: Text(
                        '${task['subjectName']} · ${task['classCode']}',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(sheetContext),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ]),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.separated(
                      itemCount: candidates.length,
                      separatorBuilder: (_, __) => const Divider(height: 24),
                      itemBuilder: (context, index) {
                        final candidate = candidates[index];
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${candidate['studentName']}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700)),
                            Text('${candidate['studentCode'] ?? ''}'),
                            const SizedBox(height: 8),
                            Row(children: [
                              SizedBox(
                                width: 92,
                                child: TextFormField(
                                  controller: scoreControllers[index],
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                          decimal: true),
                                  decoration:
                                      const InputDecoration(labelText: 'Điểm'),
                                  validator: (value) {
                                    final score = double.tryParse(value ?? '');
                                    if (score == null ||
                                        score < 0 ||
                                        score > 10) {
                                      return '0–10';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: TextFormField(
                                  controller: noteControllers[index],
                                  decoration: const InputDecoration(
                                      labelText: 'Ghi chú'),
                                ),
                              ),
                            ]),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          Navigator.pop(sheetContext, true);
                        }
                      },
                      icon: const Icon(Icons.save_outlined),
                      label: const Text('Lưu điểm'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ) ??
        false;
    if (accepted) {
      try {
        await sl<ApiService>().saveExamResults(
          '${task['examPeriodId']}',
          scheduleId: '${task['scheduleId']}',
          entries: [
            for (var index = 0; index < candidates.length; index++)
              {
                'studentId': '${candidates[index]['studentId']}',
                'score': double.parse(scoreControllers[index].text),
                'note': noteControllers[index].text.trim(),
                if (candidates[index]['resultId'] != null)
                  'expectedVersion': candidates[index]['version'],
              },
          ],
        );
        await _refresh();
      } catch (_) {
        _showError(
            'Không thể lưu điểm. Dữ liệu có thể đã thay đổi; hãy tải lại và kiểm tra.');
      }
    }
    for (final controller in [...scoreControllers, ...noteControllers]) {
      controller.dispose();
    }
  }

  Future<void> _requestReview(Map<String, dynamic> result) async {
    final reason = TextEditingController();
    final accepted = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: Text('Phúc khảo · ${result['subjectName']}'),
            content: TextField(
              controller: reason,
              minLines: 3,
              maxLines: 6,
              decoration: const InputDecoration(
                labelText: 'Lý do phúc khảo',
                hintText: 'Nhập ít nhất 10 ký tự',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Hủy'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(
                    dialogContext, reason.text.trim().length >= 10),
                child: const Text('Gửi yêu cầu'),
              ),
            ],
          ),
        ) ??
        false;
    if (accepted) {
      try {
        await sl<ApiService>().requestExamReview(
          '${result['examPeriodId']}',
          resultId: '${result['resultId']}',
          reason: reason.text.trim(),
        );
        await _refresh();
      } catch (_) {
        _showError('Không thể gửi phúc khảo. Vui lòng kiểm tra trạng thái.');
      }
    }
    reason.dispose();
  }

  Future<void> _resolveReview(Map<String, dynamic> review) async {
    final resolution = TextEditingController();
    final score =
        TextEditingController(text: '${review['originalScore'] ?? ''}');
    var approved = false;
    final accepted = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => StatefulBuilder(
            builder: (context, update) => AlertDialog(
              title: Text('Phúc khảo · ${review['subjectName']}'),
              content: SingleChildScrollView(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child:
                        Text('${review['studentName']}\n${review['reason']}'),
                  ),
                  const SizedBox(height: 12),
                  SegmentedButton<bool>(
                    segments: const [
                      ButtonSegment(value: false, label: Text('Giữ nguyên')),
                      ButtonSegment(value: true, label: Text('Điều chỉnh')),
                    ],
                    selected: {approved},
                    onSelectionChanged: (value) =>
                        update(() => approved = value.first),
                  ),
                  if (approved) ...[
                    const SizedBox(height: 12),
                    TextField(
                      controller: score,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: 'Điểm mới'),
                    ),
                  ],
                  const SizedBox(height: 12),
                  TextField(
                    controller: resolution,
                    minLines: 3,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      labelText: 'Kết luận',
                      hintText: 'Nhập ít nhất 5 ký tự',
                    ),
                  ),
                ]),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: const Text('Hủy'),
                ),
                FilledButton(
                  onPressed: () {
                    final parsed = double.tryParse(score.text);
                    final validScore = !approved ||
                        (parsed != null && parsed >= 0 && parsed <= 10);
                    Navigator.pop(dialogContext,
                        resolution.text.trim().length >= 5 && validScore);
                  },
                  child: const Text('Xác nhận'),
                ),
              ],
            ),
          ),
        ) ??
        false;
    if (accepted) {
      try {
        await sl<ApiService>().resolveExamReview(
          '${review['id']}',
          status: approved ? 'APPROVED' : 'REJECTED',
          resolution: resolution.text.trim(),
          resolvedScore: approved ? double.parse(score.text) : null,
        );
        await _refresh();
      } catch (_) {
        _showError('Không thể xử lý phúc khảo. Vui lòng tải lại.');
      }
    }
    resolution.dispose();
    score.dispose();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}

class _WorkspaceData {
  const _WorkspaceData(
    this.dashboard,
    this.leaves,
    this.exams,
    this.gradingTasks,
    this.results,
    this.reviews,
    this.report,
  );
  final Map<String, dynamic> dashboard;
  final List<Map<String, dynamic>> leaves;
  final List<Map<String, dynamic>> exams;
  final List<Map<String, dynamic>> gradingTasks;
  final List<Map<String, dynamic>> results;
  final List<Map<String, dynamic>> reviews;
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
            child: const Icon(Icons.auto_awesome_rounded,
                color: Colors.white, size: 27),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Hôm nay của bạn',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 18)),
                const SizedBox(height: 4),
                Text(subtitle,
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 13, height: 1.4)),
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
                  Text('${metric['value'] ?? '—'}',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 2),
                  Text('${metric['label'] ?? ''}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          )),
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
            child: Text('$title ($count)',
                style: Theme.of(context).textTheme.titleMedium),
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
        final title = item['examName'] ??
            item['periodName'] ??
            item['name'] ??
            item['subjectName'] ??
            item['title'] ??
            'Nội dung khảo thí';
        final status =
            item['status'] ?? item['taskStatus'] ?? item['scheduleStatus'];
        final detail = item['examDate'] ??
            item['startDate'] ??
            item['date'] ??
            item['startsAt'] ??
            item['roomCode'] ??
            '';
        return Padding(
          padding: const EdgeInsets.only(bottom: 9),
          child: Card(
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
              leading: CircleAvatar(
                backgroundColor: accent.withValues(alpha: .12),
                child: Icon(Icons.event_note_rounded, color: accent),
              ),
              title: Text('$title',
                  style: const TextStyle(fontWeight: FontWeight.w700)),
              subtitle:
                  Text('$detail', maxLines: 2, overflow: TextOverflow.ellipsis),
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

class _TeacherExamTasks extends StatelessWidget {
  const _TeacherExamTasks({
    required this.items,
    required this.accent,
    required this.onOpen,
  });
  final List<Map<String, dynamic>> items;
  final Color accent;
  final void Function(Map<String, dynamic> item) onOpen;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const _EmptyCard(text: 'Chưa có nhiệm vụ chấm thi');
    }
    return Column(
      children: items.map((item) {
        final candidates = item['candidates'] as List? ?? const [];
        final entered = candidates
            .where(
                (candidate) => candidate is Map && candidate['score'] != null)
            .length;
        final available = item['scoreEntryAvailable'] == true;
        final locked = item['scoreEntryLocked'] == true;
        return Padding(
          padding: const EdgeInsets.only(bottom: 9),
          child: Card(
            child: ListTile(
              onTap: () => onOpen(item),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: CircleAvatar(
                backgroundColor: accent.withValues(alpha: .12),
                child: Icon(Icons.edit_note_rounded, color: accent),
              ),
              title: Text('${item['subjectName']} · ${item['classCode']}',
                  style: const TextStyle(fontWeight: FontWeight.w700)),
              subtitle: Text(
                '${item['examDate']} ${item['startTime']}\nĐã nhập $entered/${candidates.length}',
              ),
              isThreeLine: true,
              trailing: Icon(
                locked
                    ? Icons.lock_outline_rounded
                    : available
                        ? Icons.chevron_right_rounded
                        : Icons.schedule_rounded,
                color: locked || !available
                    ? Theme.of(context).colorScheme.onSurfaceVariant
                    : accent,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _ExamResultCards extends StatelessWidget {
  const _ExamResultCards({
    required this.items,
    required this.accent,
    required this.canRequestReview,
    required this.onReview,
  });
  final List<Map<String, dynamic>> items;
  final Color accent;
  final bool canRequestReview;
  final void Function(Map<String, dynamic> item) onReview;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const _EmptyCard(text: 'Chưa có kết quả thi được công bố');
    }
    return Column(
      children: items.map((item) {
        final reviewStatus = '${item['reviewStatus'] ?? ''}';
        final canReview = canRequestReview && reviewStatus.isEmpty;
        return Padding(
          padding: const EdgeInsets.only(bottom: 9),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Expanded(
                      child: Text('${item['subjectName']}',
                          style: const TextStyle(fontWeight: FontWeight.w700)),
                    ),
                    Text('${item['score'] ?? '—'}',
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(color: accent)),
                  ]),
                  Text('${item['examPeriodName']}'),
                  if ('${item['note'] ?? ''}'.isNotEmpty)
                    Text('Nhận xét: ${item['note']}'),
                  if (reviewStatus.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    _StatusChip(reviewStatus, accent),
                    if ('${item['reviewResolution'] ?? ''}'.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text('Kết luận: ${item['reviewResolution']}'),
                      ),
                  ],
                  if (canReview) ...[
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () => onReview(item),
                        icon: const Icon(Icons.rate_review_outlined),
                        label: const Text('Yêu cầu phúc khảo'),
                      ),
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

class _ExamReviewCards extends StatelessWidget {
  const _ExamReviewCards({
    required this.items,
    required this.accent,
    required this.onOpen,
  });
  final List<Map<String, dynamic>> items;
  final Color accent;
  final void Function(Map<String, dynamic> item) onOpen;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const _EmptyCard(text: 'Không có phúc khảo chờ xử lý');
    }
    return Column(
      children: items
          .map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 9),
                child: Card(
                  child: ListTile(
                    onTap: () => onOpen(item),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: CircleAvatar(
                      backgroundColor: accent.withValues(alpha: .12),
                      child: Icon(Icons.fact_check_outlined, color: accent),
                    ),
                    title: Text(
                        '${item['studentName']} · ${item['subjectName']}',
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                    subtitle: Text(
                      'Điểm cũ: ${item['originalScore'] ?? '—'}\n${item['reason'] ?? ''}',
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    isThreeLine: true,
                    trailing: const Icon(Icons.chevron_right_rounded),
                  ),
                ),
              ))
          .toList(),
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
                child: const Text('Từ chối')),
            FilledButton(
                onPressed: () => onDecision(id, 'parent-confirm'),
                child: const Text('Xác nhận')),
          ]);
        }
        if (role == 'TEACHER' && status == 'PENDING_HOMEROOM') {
          actions.addAll([
            TextButton(
                onPressed: () => onDecision(id, 'reject'),
                child: const Text('Từ chối')),
            FilledButton(
                onPressed: () => onDecision(id, 'approve'),
                child: const Text('Duyệt')),
          ]);
        }
        if (role == 'STUDENT' && status.startsWith('PENDING')) {
          actions.add(OutlinedButton(
              onPressed: () => onDecision(id, 'cancel'),
              child: const Text('Hủy đơn')));
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
                        child: Text('${item['studentName'] ?? 'Học sinh'}',
                            style:
                                const TextStyle(fontWeight: FontWeight.w700)),
                      ),
                      _StatusChip(status, accent),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('${item['startDate'] ?? ''} → ${item['endDate'] ?? ''}'),
                  const SizedBox(height: 5),
                  Text('${item['reason'] ?? ''}',
                      style: TextStyle(
                          color:
                              Theme.of(context).colorScheme.onSurfaceVariant)),
                  if (actions.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: actions
                            .expand(
                                (button) => [button, const SizedBox(width: 8)])
                            .toList()
                          ..removeLast()),
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
        .where((entry) =>
            entry.value is String || entry.value is num || entry.value is bool)
        .take(6);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: entries
              .map((entry) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 7),
                    child: Row(
                      children: [
                        Expanded(child: Text(_humanize(entry.key))),
                        Text('${entry.value}',
                            style:
                                const TextStyle(fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ))
              .toList(),
        ),
      ),
    );
  }
}

class _DateButton extends StatelessWidget {
  const _DateButton(
      {required this.label, required this.date, required this.onPick});
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
              color: accent, fontSize: 10, fontWeight: FontWeight.w700),
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
            child: Text(text,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ),
        ),
      );
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.onRetry});
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.all(32),
        children: [
          const Icon(Icons.cloud_off_rounded, size: 52, color: AppColors.error),
          const SizedBox(height: 16),
          Text('Không thể tải trung tâm công việc',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Thử lại'),
          ),
        ],
      );
}

String _humanize(String value) => switch (value.toUpperCase()) {
      'PENDING' => 'Chờ xử lý',
      'PENDING_PARENT' => 'Chờ phụ huynh xác nhận',
      'PENDING_HOMEROOM' => 'Chờ giáo viên chủ nhiệm',
      'APPROVED' => 'Đã duyệt',
      'REJECTED' => 'Đã từ chối',
      'CANCELLED' => 'Đã hủy',
      'DRAFT' => 'Đang chuẩn bị',
      'PUBLISHED' => 'Đã công bố',
      'COMPLETED' => 'Đã hoàn tất',
      'TOTAL' || 'TOTAL_COUNT' => 'Tổng số',
      'AVERAGE' || 'AVERAGE_SCORE' => 'Điểm trung bình',
      'ATTENDANCE_RATE' => 'Tỷ lệ chuyên cần',
      'ABSENT_COUNT' => 'Số buổi vắng',
      'LATE_COUNT' => 'Số lần đi muộn',
      'ASSIGNMENT_COUNT' => 'Số bài tập',
      _ => 'Thông tin',
    };
