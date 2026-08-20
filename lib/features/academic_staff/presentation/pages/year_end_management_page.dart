import 'package:flutter/material.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/network/api_error_message.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/utils/vi_date_format.dart';

class YearEndManagementPage extends StatefulWidget {
  const YearEndManagementPage({super.key});

  @override
  State<YearEndManagementPage> createState() => _YearEndManagementPageState();
}

class _YearEndManagementPageState extends State<YearEndManagementPage> {
  final _api = sl<ApiService>();
  late Future<_YearEndData> _future = _load();

  Future<_YearEndData> _load() async {
    final years = await _api.academicYears();
    if (years.isEmpty) throw StateError('Chưa có năm học để tổng kết.');
    final active = years.where((item) => item['status'] == 'ACTIVE');
    final year = active.isNotEmpty ? active.first : years.first;
    final yearId = year['id'].toString();
    final values = await Future.wait([
      _api.yearRolloverPreview(yearId),
      _api.promotionPreview(yearId),
    ]);
    return _YearEndData(
      year,
      values[0] as Map<String, dynamic>,
      values[1] as List<Map<String, dynamic>>,
    );
  }

  void _reload() => setState(() => _future = _load());

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Tổng kết và chuyển năm'),
      backgroundColor: AppColors.academicStaffAccent,
      actions: [
        IconButton(
          tooltip: 'Tải lại',
          onPressed: _reload,
          icon: const Icon(Icons.refresh_rounded),
        ),
      ],
    ),
    body: FutureBuilder<_YearEndData>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return _ErrorView(error: snapshot.error, retry: _reload);
        }
        return _YearEndBody(
          data: snapshot.data!,
          api: _api,
          onCompleted: _reload,
        );
      },
    ),
  );
}

class _YearEndData {
  const _YearEndData(this.year, this.preview, this.students);
  final Map<String, dynamic> year;
  final Map<String, dynamic> preview;
  final List<Map<String, dynamic>> students;
}

class _YearEndBody extends StatelessWidget {
  const _YearEndBody({
    required this.data,
    required this.api,
    required this.onCompleted,
  });

  final _YearEndData data;
  final ApiService api;
  final VoidCallback onCompleted;

  @override
  Widget build(BuildContext context) {
    final preview = data.preview;
    final blockers = ((preview['blockers'] as List?) ?? const [])
        .map((item) => item.toString())
        .toList();
    final plan = ((preview['classPlan'] as List?) ?? const [])
        .map((item) => (item as Map).cast<String, dynamic>())
        .toList();
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          color: AppColors.academicStaffAccent.withValues(alpha: .08),
          child: ListTile(
            leading: const Icon(
              Icons.school_rounded,
              color: AppColors.academicStaffAccent,
            ),
            title: Text(
              (data.year['name'] ?? data.year['code'] ?? 'Năm học').toString(),
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            subtitle: Text(
              '${formatViDateRange(data.year['startDate'], data.year['endDate'])}\n'
              'Trạng thái: ${_yearEndStatus(preview['status'])}',
            ),
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: MediaQuery.sizeOf(context).width >= 620 ? 4 : 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.55,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          children: [
            _Metric('Học sinh', preview['studentCount'], Icons.groups_rounded),
            _Metric(
              'Đủ điều kiện',
              preview['readyCount'],
              Icons.verified_outlined,
            ),
            _Metric(
              'Còn thiếu',
              preview['incompleteCount'],
              Icons.warning_amber_rounded,
            ),
            _Metric(
              'Lên lớp',
              preview['expectedPromoted'],
              Icons.trending_up_rounded,
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          'Điều kiện chuyển năm',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        if (blockers.isEmpty)
          const Card(
            color: Color(0xffedf8ef),
            child: ListTile(
              leading: Icon(Icons.check_circle_outline, color: Colors.green),
              title: Text('Đã đủ điều kiện chuyển năm'),
              subtitle: Text(
                'Hệ thống sẽ tổng kết và chuyển lớp trong một giao dịch.',
              ),
            ),
          )
        else
          ...blockers.map(
            (message) => Card(
              color: const Color(0xfffff3f2),
              child: ListTile(
                leading: const Icon(Icons.error_outline, color: Colors.red),
                title: Text(message),
              ),
            ),
          ),
        const SizedBox(height: 16),
        Text(
          'Dự kiến lớp năm sau',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        if (plan.isEmpty)
          const Text(
            'Chưa có kế hoạch lớp.',
            style: TextStyle(color: AppColors.textSecondary),
          )
        else
          ...plan.map(
            (item) => Card(
              child: ListTile(
                leading: const Icon(Icons.meeting_room_outlined),
                title: Text(
                  '${item['sourceClassCode']} → ${item['targetClassCode']}',
                ),
                subtitle: Text(
                  '${item['type']} • Khối ${item['targetGradeLevel']} • Sĩ số ${item['capacity']}',
                ),
              ),
            ),
          ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: blockers.isEmpty
              ? () => _openRollover(context, data.year, api, onCompleted)
              : null,
          icon: const Icon(Icons.move_up_rounded),
          label: const Text('Chuyển sang năm học mới'),
        ),
        if (blockers.isNotEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text(
              'Nút được khóa để tránh chuyển năm khi dữ liệu chưa hoàn chỉnh.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
      ],
    );
  }

  Future<void> _openRollover(
    BuildContext context,
    Map<String, dynamic> year,
    ApiService api,
    VoidCallback completed,
  ) async {
    final code = (year['code'] ?? '').toString();
    final match = RegExp(r'^(\d{4})-(\d{4})$').firstMatch(code);
    final nextCode = match == null
        ? ''
        : '${int.parse(match.group(1)!) + 1}-${int.parse(match.group(2)!) + 1}';
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => _RolloverDialog(
        api: api,
        yearId: year['id'].toString(),
        initialCode: nextCode,
      ),
    );
    if (result == true) completed();
  }
}

String _yearEndStatus(Object? value) => switch ('$value') {
  'READY' => 'Sẵn sàng tổng kết',
  'BLOCKED' => 'Còn điều kiện chưa hoàn tất',
  'COMPLETED' => 'Đã hoàn tất',
  'IN_PROGRESS' => 'Đang xử lý',
  _ => value == null || '$value'.isEmpty ? 'Chưa xác định' : '$value',
};

class _RolloverDialog extends StatefulWidget {
  const _RolloverDialog({
    required this.api,
    required this.yearId,
    required this.initialCode,
  });
  final ApiService api;
  final String yearId;
  final String initialCode;

  @override
  State<_RolloverDialog> createState() => _RolloverDialogState();
}

class _RolloverDialogState extends State<_RolloverDialog> {
  late final _code = TextEditingController(text: widget.initialCode);
  late final _name = TextEditingController(
    text: 'Năm học ${widget.initialCode}',
  );
  DateTime? _start;
  DateTime? _end;
  bool _saving = false;

  Future<void> _pick(bool start) async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDate: start
          ? (_start ?? DateTime.now().add(const Duration(days: 30)))
          : (_end ?? DateTime.now().add(const Duration(days: 300))),
    );
    if (date != null) setState(() => start ? _start = date : _end = date);
  }

  Future<void> _submit() async {
    if (_code.text.trim().isEmpty || _start == null || _end == null) return;
    if (!_end!.isAfter(_start!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ngày kết thúc phải sau ngày bắt đầu.')),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      await widget.api.rolloverAcademicYear(
        yearId: widget.yearId,
        nextYearCode: _code.text.trim(),
        nextYearName: _name.text.trim(),
        startDate: _start!,
        endDate: _end!,
      );
      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            apiErrorMessage(
              error,
              fallback: 'Không thể chuyển sang năm học mới. Vui lòng thử lại.',
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Xác nhận chuyển năm'),
    content: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Thao tác sẽ khóa năm hiện tại, tạo học kỳ và lớp năm mới.',
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _code,
            decoration: const InputDecoration(labelText: 'Mã năm học'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _name,
            decoration: const InputDecoration(labelText: 'Tên năm học'),
          ),
          const SizedBox(height: 12),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Ngày bắt đầu'),
            subtitle: Text(_date(_start)),
            trailing: const Icon(Icons.calendar_today_outlined),
            onTap: () => _pick(true),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Ngày kết thúc'),
            subtitle: Text(_date(_end)),
            trailing: const Icon(Icons.event_available_outlined),
            onTap: () => _pick(false),
          ),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: _saving ? null : () => Navigator.pop(context),
        child: const Text('Hủy'),
      ),
      FilledButton(
        onPressed: _saving ? null : _submit,
        child: Text(_saving ? 'Đang xử lý...' : 'Xác nhận'),
      ),
    ],
  );

  String _date(DateTime? value) => value == null
      ? 'Chưa chọn'
      : '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}';
}

class _Metric extends StatelessWidget {
  const _Metric(this.label, this.value, this.icon);
  final String label;
  final Object? value;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Icon(icon, color: AppColors.academicStaffAccent),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${value ?? 0}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.error, required this.retry});
  final Object? error;
  final VoidCallback retry;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 40, color: Colors.red),
          const SizedBox(height: 12),
          Text(
            apiErrorMessage(
              error,
              fallback: 'Không thể tải dữ liệu tổng kết năm học.',
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: retry,
            icon: const Icon(Icons.refresh),
            label: const Text('Thử lại'),
          ),
        ],
      ),
    ),
  );
}
