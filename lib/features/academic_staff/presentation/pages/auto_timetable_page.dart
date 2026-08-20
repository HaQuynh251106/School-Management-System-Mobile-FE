import 'package:flutter/material.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/network/api_error_message.dart';
import '../../../../core/network/api_service.dart';

class AutoTimetablePage extends StatefulWidget {
  const AutoTimetablePage({super.key});

  @override
  State<AutoTimetablePage> createState() => _AutoTimetablePageState();
}

class _AutoTimetablePageState extends State<AutoTimetablePage> {
  final _api = sl<ApiService>();
  late final Future<List<Map<String, dynamic>>> _semesters = _api.semesters();
  String? _semesterId;
  Map<String, dynamic>? _plan;
  bool _loading = false;
  final Set<String> _allowedDays = {'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'};

  Future<void> _preview() => _run(apply: false);

  Future<void> _apply() async {
    final accepted = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Áp dụng thời khóa biểu?'),
        content: const Text(
          'Các tiết đề xuất sẽ được thêm vào lịch hiện tại. Thao tác này không phát hành lịch cho người dùng.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Áp dụng'),
          ),
        ],
      ),
    );
    if (accepted == true) await _run(apply: true);
  }

  Future<void> _run({required bool apply}) async {
    final semesterId = _semesterId;
    if (semesterId == null) return;
    setState(() => _loading = true);
    try {
      final result = await _api.autoPlanTimetable(
        semesterId,
        apply: apply,
        allowedDays: _allowedDays.toList(),
      );
      if (!mounted) return;
      setState(() => _plan = result);
      if (apply) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Đã áp dụng lịch. Hãy lưu bản nháp để kiểm tra và phát hành.',
            ),
          ),
        );
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_errorMessage(error))));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Tự tạo thời khóa biểu')),
    body: FutureBuilder<List<Map<String, dynamic>>>(
      future: _semesters,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text(_errorMessage(snapshot.error)));
        }
        final semesters = snapshot.data ?? const [];
        if (_semesterId == null && semesters.isNotEmpty) {
          _semesterId = semesters.first['id'].toString();
        }
        if (semesters.isEmpty) {
          return const Center(child: Text('Chưa có học kỳ để xếp lịch.'));
        }
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: DropdownButtonFormField<String>(
                initialValue: _semesterId,
                decoration: const InputDecoration(labelText: 'Học kỳ'),
                items: semesters
                    .map(
                      (item) => DropdownMenuItem(
                        value: item['id'].toString(),
                        child: Text((item['name'] ?? item['code']).toString()),
                      ),
                    )
                    .toList(),
                onChanged: _loading
                    ? null
                    : (value) => setState(() {
                        _semesterId = value;
                        _plan = null;
                      }),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ngày học trong tuần',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: _dayOptions.entries.map((entry) {
                        final selected = _allowedDays.contains(entry.key);
                        return FilterChip(
                          label: Text(entry.value),
                          selected: selected,
                          onSelected: _loading
                              ? null
                              : (value) {
                                  if (!value && _allowedDays.length == 1) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Phải giữ ít nhất một ngày học.',
                                        ),
                                      ),
                                    );
                                    return;
                                  }
                                  setState(() {
                                    value
                                        ? _allowedDays.add(entry.key)
                                        : _allowedDays.remove(entry.key);
                                    _plan = null;
                                  });
                                },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Bỏ chọn một thứ nếu trường không tổ chức học cố định vào ngày đó.',
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _loading ? null : _preview,
                  icon: _loading
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.auto_awesome_rounded),
                  label: const Text('Xem phương án tự động'),
                ),
              ),
            ),
            Expanded(
              child: _plan == null
                  ? const _EmptyPlan()
                  : _PlanResult(
                      plan: _plan!,
                      loading: _loading,
                      onApply: _apply,
                    ),
            ),
          ],
        );
      },
    ),
  );
}

class _EmptyPlan extends StatelessWidget {
  const _EmptyPlan();

  @override
  Widget build(BuildContext context) => const Center(
    child: Padding(
      padding: EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.calendar_month_outlined, size: 56),
          SizedBox(height: 12),
          Text(
            'Chọn học kỳ và xem trước phương án. Dữ liệu chỉ được lưu sau khi bạn xác nhận.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}

class _PlanResult extends StatelessWidget {
  const _PlanResult({
    required this.plan,
    required this.loading,
    required this.onApply,
  });

  final Map<String, dynamic> plan;
  final bool loading;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    final items = (plan['items'] as List? ?? const [])
        .whereType<Map>()
        .map((item) => item.cast<String, dynamic>())
        .toList();
    final warnings = (plan['warnings'] as List? ?? const [])
        .map((item) => item.toString())
        .toList();
    final proposed = (plan['proposedSlots'] as num?)?.toInt() ?? 0;
    final unscheduled = (plan['unscheduledSlots'] as num?)?.toInt() ?? 0;
    final applied = plan['applied'] == true;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      children: [
        Row(
          children: [
            Expanded(
              child: _Metric(label: 'Đã có', value: plan['existingSlots']),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _Metric(label: 'Đề xuất', value: proposed),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _Metric(label: 'Chưa xếp', value: unscheduled),
            ),
          ],
        ),
        if (warnings.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text('Cần xử lý', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 6),
          ...warnings.map(
            (warning) => Card(
              color: Theme.of(context).colorScheme.errorContainer,
              child: ListTile(
                leading: const Icon(Icons.warning_amber_rounded),
                title: Text(warning),
              ),
            ),
          ),
        ],
        const SizedBox(height: 16),
        Text(
          'Chi tiết phương án',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 6),
        if (items.isEmpty)
          const Card(
            child: ListTile(title: Text('Không có tiết mới cần xếp.')),
          ),
        ...items.map((item) {
          final scheduled = item['status'] == 'PROPOSED';
          final slot = scheduled
              ? '${_day(item['dayOfWeek'])} • Tiết ${item['periodNo']} • ${item['roomCode'] ?? 'Chưa có phòng'}'
              : (item['message'] ?? 'Chưa xếp được').toString();
          return Card(
            child: ListTile(
              leading: CircleAvatar(
                child: Icon(
                  scheduled ? Icons.event_available : Icons.event_busy,
                ),
              ),
              title: Text(
                '${item['classCode'] ?? ''} • ${item['subjectName'] ?? ''}',
              ),
              subtitle: Text('${item['teacherName'] ?? ''}\n$slot'),
              isThreeLine: true,
            ),
          );
        }),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: loading || unscheduled > 0 || proposed == 0 || applied
                ? null
                : onApply,
            icon: const Icon(Icons.check_circle_outline_rounded),
            label: Text(applied ? 'Đã áp dụng' : 'Áp dụng phương án'),
          ),
        ),
        if (unscheduled > 0)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text(
              'Hãy xử lý hết cảnh báo trước khi áp dụng.',
              textAlign: TextAlign.center,
            ),
          ),
      ],
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});
  final String label;
  final Object? value;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      child: Column(
        children: [
          Text(
            '${value ?? 0}',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          Text(label, textAlign: TextAlign.center),
        ],
      ),
    ),
  );
}

String _day(Object? value) => switch (value) {
  'MON' => 'Thứ 2',
  'TUE' => 'Thứ 3',
  'WED' => 'Thứ 4',
  'THU' => 'Thứ 5',
  'FRI' => 'Thứ 6',
  'SAT' => 'Thứ 7',
  _ => value?.toString() ?? '',
};

const _dayOptions = {
  'MON': 'Thứ 2',
  'TUE': 'Thứ 3',
  'WED': 'Thứ 4',
  'THU': 'Thứ 5',
  'FRI': 'Thứ 6',
  'SAT': 'Thứ 7',
};

String _errorMessage(Object? error) {
  return apiErrorMessage(
    error,
    fallback: 'Không thể tạo phương án. Vui lòng thử lại.',
  );
}
