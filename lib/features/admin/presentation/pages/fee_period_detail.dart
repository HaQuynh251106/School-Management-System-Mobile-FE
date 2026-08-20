import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/network/api_error_message.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/utils/vi_date_format.dart';

class AdminFeePeriodDetail extends StatefulWidget {
  const AdminFeePeriodDetail({super.key, required this.periodId});

  final String periodId;

  @override
  State<AdminFeePeriodDetail> createState() => _AdminFeePeriodDetailState();
}

class _AdminFeePeriodDetailState extends State<AdminFeePeriodDetail> {
  final _api = sl<ApiService>();
  late Future<_FeePeriodData> _future = _load();
  bool _busy = false;

  Future<_FeePeriodData> _load() async {
    final values = await Future.wait([
      _api.feePeriodDetail(widget.periodId),
      _api.classes(),
      _api.users(role: 'STUDENT'),
    ]);
    return _FeePeriodData(
      values[0] as Map<String, dynamic>,
      (values[1] as List).cast<Map<String, dynamic>>(),
      (values[2] as List).cast<Map<String, dynamic>>(),
    );
  }

  Future<void> _refresh() async {
    setState(() {
      _future = _load();
    });
    await _future;
  }

  Future<void> _run(Future<void> Function() action, String success) async {
    setState(() => _busy = true);
    try {
      await action();
      await _refresh();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(success), backgroundColor: AppColors.success),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              apiErrorMessage(
                error,
                fallback: 'Không thể thực hiện thao tác. Vui lòng thử lại.',
              ),
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Chi tiết đợt thu')),
    body: FutureBuilder<_FeePeriodData>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return _LoadError(onRetry: _refresh);
        }
        return _body(snapshot.data!);
      },
    ),
  );

  Widget _body(_FeePeriodData data) {
    final period = data.period;
    final preview = data.preview;
    final items = data.items;
    final adjustments = data.adjustments;
    final recipients = data.recipients;
    final status = '${period['status'] ?? 'DRAFT'}';
    final draft = status == 'DRAFT';
    final open = status == 'OPEN';
    final valid = preview['valid'] == true;
    final errors = (preview['errors'] as List? ?? const []).cast<dynamic>();

    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        children: [
          _PeriodHeader(
            period: period,
            onEdit: draft ? () => _editScope(data) : null,
          ),
          const SizedBox(height: 18),
          _SectionTitle(
            title: 'Khoản thu',
            action: draft ? () => _addItem(data) : null,
            actionLabel: 'Thêm',
          ),
          if (items.isEmpty)
            const _EmptyLine(text: 'Chưa có khoản thu')
          else
            ...items.map(
              (item) => Card(
                child: ListTile(
                  leading: const Icon(
                    Icons.receipt_outlined,
                    color: AppColors.adminAccent,
                  ),
                  title: Text('${item['name'] ?? ''}'),
                  subtitle: Text(
                    item['gradeLevel'] == null
                        ? 'Mọi khối'
                        : 'Khối ${item['gradeLevel']}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_money(item['amount'])),
                      if (draft)
                        IconButton(
                          tooltip: 'Xóa khoản thu',
                          onPressed: _busy
                              ? null
                              : () => _run(
                                  () => _api.deleteFeePeriodItem(
                                    widget.periodId,
                                    '${item['id']}',
                                  ),
                                  'Đã xóa khoản thu',
                                ),
                          icon: const Icon(Icons.delete_outline_rounded),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          const SizedBox(height: 18),
          _SectionTitle(
            title: 'Miễn giảm và ngoại lệ',
            action: draft && recipients.isNotEmpty
                ? () => _addAdjustment(data)
                : null,
            actionLabel: 'Thêm',
          ),
          if (adjustments.isEmpty)
            const _EmptyLine(text: 'Không có ngoại lệ')
          else
            ...adjustments.map((adjustment) {
              final student = data.studentById('${adjustment['studentId']}');
              return Card(
                child: ListTile(
                  leading: Icon(
                    adjustment['type'] == 'EXCLUDE'
                        ? Icons.person_off_outlined
                        : Icons.percent_rounded,
                    color: AppColors.warning,
                  ),
                  title: Text(
                    '${student?['fullName'] ?? adjustment['studentId']}',
                  ),
                  subtitle: Text(
                    adjustment['type'] == 'EXCLUDE'
                        ? 'Loại khỏi đợt thu'
                        : 'Giảm ${_money(adjustment['amount'])}',
                  ),
                  trailing: draft
                      ? IconButton(
                          tooltip: 'Xóa ngoại lệ',
                          onPressed: _busy
                              ? null
                              : () => _run(
                                  () => _api.deleteFeePeriodAdjustment(
                                    widget.periodId,
                                    '${adjustment['id']}',
                                  ),
                                  'Đã xóa ngoại lệ',
                                ),
                          icon: const Icon(Icons.delete_outline_rounded),
                        )
                      : null,
                ),
              );
            }),
          const SizedBox(height: 18),
          const _SectionTitle(title: 'Xem trước phát hành'),
          _PreviewSummary(preview: preview),
          if (errors.isNotEmpty) ...[
            const SizedBox(height: 10),
            ...errors.map((message) => _ErrorLine(text: message.toString())),
          ],
          const SizedBox(height: 10),
          ...recipients.map((recipient) => _RecipientRow(recipient: recipient)),
          const SizedBox(height: 18),
          if (draft)
            FilledButton.icon(
              onPressed: _busy || !valid ? null : () => _openPeriod(preview),
              icon: const Icon(Icons.lock_open_rounded),
              label: const Text('Duyệt và mở đợt thu'),
            ),
          if (open) ...[
            FilledButton.icon(
              onPressed: _busy || !valid ? null : () => _generate(preview),
              icon: const Icon(Icons.playlist_add_check_rounded),
              label: const Text('Xác nhận sinh hóa đơn'),
            ),
            if (!valid) ...[
              const SizedBox(height: 6),
              Text(
                'Chưa thể sinh hóa đơn. Hãy sửa phạm vi hoặc dữ liệu học sinh.',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.error),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: _busy ? null : _closePeriod,
              icon: const Icon(Icons.lock_outline_rounded),
              label: const Text('Đóng đợt thu'),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _addItem(_FeePeriodData data) async {
    final name = TextEditingController();
    final amount = TextEditingController();
    final grade = TextEditingController();
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thêm khoản thu'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: name,
              decoration: const InputDecoration(labelText: 'Tên khoản thu'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: amount,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Số tiền (VND)'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: grade,
              decoration: const InputDecoration(
                labelText: 'Khối riêng (không bắt buộc)',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () {
              final value = int.tryParse(amount.text.trim());
              if (name.text.trim().isEmpty || value == null || value <= 0) {
                return;
              }
              Navigator.pop(context, {
                'name': name.text.trim(),
                'amount': value,
                'gradeLevel': grade.text.trim().isEmpty
                    ? null
                    : grade.text.trim(),
              });
            },
            child: const Text('Thêm'),
          ),
        ],
      ),
    );
    name.dispose();
    amount.dispose();
    grade.dispose();
    if (result != null) {
      await _run(
        () async => _api.addFeePeriodItem(widget.periodId, result),
        'Đã thêm khoản thu',
      );
    }
  }

  Future<void> _editScope(_FeePeriodData data) async {
    var type = '${data.period['scopeType'] ?? 'SCHOOL'}';
    var grade = '${data.period['scopeGradeLevel'] ?? ''}';
    String? classId = data.period['scopeClassId']?.toString();
    final selected = data.studentIds.toSet();
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            12,
            16,
            MediaQuery.viewInsetsOf(context).bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Phạm vi áp dụng',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: type,
                decoration: const InputDecoration(labelText: 'Loại phạm vi'),
                items: const [
                  DropdownMenuItem(value: 'SCHOOL', child: Text('Toàn trường')),
                  DropdownMenuItem(value: 'GRADE', child: Text('Theo khối')),
                  DropdownMenuItem(value: 'CLASS', child: Text('Theo lớp')),
                  DropdownMenuItem(
                    value: 'STUDENTS',
                    child: Text('Danh sách học sinh'),
                  ),
                ],
                onChanged: (value) =>
                    setSheetState(() => type = value ?? 'SCHOOL'),
              ),
              if (type == 'GRADE') ...[
                const SizedBox(height: 10),
                TextFormField(
                  initialValue: grade,
                  decoration: const InputDecoration(
                    labelText: 'Khối, ví dụ K10',
                  ),
                  onChanged: (value) => grade = value,
                ),
              ],
              if (type == 'CLASS') ...[
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  initialValue:
                      data.classes.any((item) => '${item['id']}' == classId)
                      ? classId
                      : null,
                  decoration: const InputDecoration(labelText: 'Lớp'),
                  items: data.classes
                      .map(
                        (item) => DropdownMenuItem(
                          value: '${item['id']}',
                          child: Text('${item['name'] ?? item['code']}'),
                        ),
                      )
                      .toList(),
                  onChanged: (value) => classId = value,
                ),
              ],
              if (type == 'STUDENTS')
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    children: data.students.map((student) {
                      final id = '${student['id']}';
                      return CheckboxListTile(
                        value: selected.contains(id),
                        title: Text('${student['fullName']}'),
                        subtitle: Text(
                          '${student['className'] ?? 'Chưa có lớp'}',
                        ),
                        onChanged: (checked) => setSheetState(() {
                          checked == true
                              ? selected.add(id)
                              : selected.remove(id);
                        }),
                      );
                    }).toList(),
                  ),
                ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.pop(context, {
                    'scopeType': type,
                    'scopeGradeLevel': type == 'GRADE' ? grade.trim() : null,
                    'scopeClassId': type == 'CLASS' ? classId : null,
                    'studentIds': type == 'STUDENTS'
                        ? selected.toList()
                        : <String>[],
                  }),
                  child: const Text('Lưu phạm vi'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (result == null) return;
    await _run(() async {
      await _api.updateFeePeriod(widget.periodId, {
        'name': data.period['name'],
        'academicYearId': data.period['academicYearId'],
        'dueDate': data.period['dueDate'],
        ...result,
      });
    }, 'Đã cập nhật phạm vi');
  }

  Future<void> _addAdjustment(_FeePeriodData data) async {
    String? studentId = data.recipients.firstOrNull?['studentId']?.toString();
    var type = 'DISCOUNT';
    final amount = TextEditingController();
    final reason = TextEditingController();
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Thêm miễn giảm'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: studentId,
                decoration: const InputDecoration(labelText: 'Học sinh'),
                items: data.recipients
                    .map(
                      (row) => DropdownMenuItem(
                        value: '${row['studentId']}',
                        child: Text('${row['studentName']}'),
                      ),
                    )
                    .toList(),
                onChanged: (value) => studentId = value,
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: type,
                decoration: const InputDecoration(labelText: 'Loại ngoại lệ'),
                items: const [
                  DropdownMenuItem(
                    value: 'DISCOUNT',
                    child: Text('Giảm số tiền'),
                  ),
                  DropdownMenuItem(
                    value: 'EXCLUDE',
                    child: Text('Loại khỏi đợt thu'),
                  ),
                ],
                onChanged: (value) =>
                    setDialogState(() => type = value ?? 'DISCOUNT'),
              ),
              if (type == 'DISCOUNT') ...[
                const SizedBox(height: 10),
                TextField(
                  controller: amount,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Số tiền giảm'),
                ),
              ],
              const SizedBox(height: 10),
              TextField(
                controller: reason,
                decoration: const InputDecoration(labelText: 'Lý do'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            FilledButton(
              onPressed: () {
                if (studentId == null) return;
                final value = type == 'DISCOUNT'
                    ? int.tryParse(amount.text.trim())
                    : 0;
                if (type == 'DISCOUNT' && (value == null || value <= 0)) return;
                Navigator.pop(context, {
                  'studentId': studentId,
                  'type': type,
                  'amount': value,
                  'reason': reason.text.trim(),
                });
              },
              child: const Text('Lưu'),
            ),
          ],
        ),
      ),
    );
    amount.dispose();
    reason.dispose();
    if (result != null) {
      await _run(
        () async => _api.saveFeePeriodAdjustment(widget.periodId, result),
        'Đã lưu miễn giảm',
      );
    }
  }

  Future<void> _openPeriod(Map<String, dynamic> preview) async {
    final confirmed = await _confirm(
      'Mở đợt thu?',
      'Sau khi mở, khoản thu và phạm vi sẽ bị khóa. ${preview['recipientCount']} học sinh, tổng ${_money(preview['totalAmount'])}.',
      'Mở đợt',
    );
    if (confirmed) {
      await _run(
        () async => _api.openFeePeriod(widget.periodId),
        'Đợt thu đã được mở',
      );
    }
  }

  Future<void> _generate(Map<String, dynamic> preview) async {
    final confirmed = await _confirm(
      'Sinh hóa đơn?',
      'Hệ thống chỉ tạo hóa đơn còn thiếu và không tạo trùng. Phạm vi hiện có ${preview['recipientCount']} học sinh.',
      'Xác nhận',
    );
    if (confirmed) {
      await _run(() async {
        final invoices = await _api.generateInvoices(widget.periodId);
        if (invoices.isEmpty) throw StateError('Không có hóa đơn phù hợp');
      }, 'Đã đồng bộ hóa đơn an toàn');
    }
  }

  Future<void> _closePeriod() async {
    final confirmed = await _confirm(
      'Đóng đợt thu?',
      'Đợt thu sẽ ngừng phát hành thêm hóa đơn.',
      'Đóng đợt',
    );
    if (confirmed) {
      await _run(
        () async => _api.closeFeePeriod(widget.periodId),
        'Đã đóng đợt thu',
      );
    }
  }

  Future<bool> _confirm(String title, String content, String action) async =>
      await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Hủy'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(action),
            ),
          ],
        ),
      ) ??
      false;

  String _money(Object? value) => NumberFormat.currency(
    locale: 'vi_VN',
    symbol: '₫',
    decimalDigits: 0,
  ).format(value is num ? value : num.tryParse('$value') ?? 0);
}

class _FeePeriodData {
  const _FeePeriodData(this.detail, this.classes, this.students);
  final Map<String, dynamic> detail;
  final List<Map<String, dynamic>> classes;
  final List<Map<String, dynamic>> students;

  Map<String, dynamic> get period =>
      (detail['period'] as Map).cast<String, dynamic>();
  Map<String, dynamic> get preview =>
      (detail['preview'] as Map).cast<String, dynamic>();
  List<Map<String, dynamic>> get items =>
      (detail['items'] as List? ?? const []).cast<Map<String, dynamic>>();
  List<Map<String, dynamic>> get adjustments =>
      (detail['adjustments'] as List? ?? const []).cast<Map<String, dynamic>>();
  List<Map<String, dynamic>> get recipients =>
      (preview['recipients'] as List? ?? const []).cast<Map<String, dynamic>>();
  List<String> get studentIds => (detail['studentIds'] as List? ?? const [])
      .map((item) => '$item')
      .toList();
  Map<String, dynamic>? studentById(String id) =>
      students.where((student) => '${student['id']}' == id).firstOrNull;
}

class _PeriodHeader extends StatelessWidget {
  const _PeriodHeader({required this.period, this.onEdit});
  final Map<String, dynamic> period;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final status = '${period['status'] ?? ''}';
    final scope = switch ('${period['scopeType'] ?? 'SCHOOL'}') {
      'GRADE' => 'Khối ${period['scopeGradeLevel'] ?? period['applyToGrades']}',
      'CLASS' => 'Một lớp đã chọn',
      'STUDENTS' => 'Danh sách học sinh',
      _ => 'Toàn trường',
    };
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.adminAccent.withValues(alpha: .08),
        border: Border.all(color: AppColors.adminAccent.withValues(alpha: .25)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _StatusChip(status: status),
              const Spacer(),
              Text('${period['code'] ?? ''}'),
              if (onEdit != null)
                IconButton(
                  tooltip: 'Sửa phạm vi',
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${period['name'] ?? ''}',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 4),
          Text(
            '$scope · Hạn '
            '${formatViDate(period['dueDate'], fallback: 'chưa đặt')}',
          ),
        ],
      ),
    );
  }
}

class _PreviewSummary extends StatelessWidget {
  const _PreviewSummary({required this.preview});
  final Map<String, dynamic> preview;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: _Metric(
          label: 'Người nhận',
          value: '${preview['recipientCount'] ?? 0}',
        ),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: _Metric(
          label: 'Đã có HĐ',
          value: '${preview['invoiceCount'] ?? 0}',
        ),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: _Metric(
          label: 'Tổng tiền',
          value: NumberFormat.currency(
            locale: 'vi_VN',
            symbol: '₫',
            decimalDigits: 0,
          ).format(preview['totalAmount'] ?? 0),
        ),
      ),
    ],
  );
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
    decoration: BoxDecoration(
      border: Border.all(color: Theme.of(context).dividerColor),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Column(
      children: [
        Text(value, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 3),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}

class _RecipientRow extends StatelessWidget {
  const _RecipientRow({required this.recipient});
  final Map<String, dynamic> recipient;
  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: Icon(
      recipient['excluded'] == true
          ? Icons.person_off_outlined
          : Icons.person_outline_rounded,
      color: recipient['parentLinked'] == true
          ? AppColors.success
          : AppColors.error,
    ),
    title: Text('${recipient['studentName'] ?? ''}'),
    subtitle: Text(
      '${recipient['classCode'] ?? 'Chưa có lớp'} · '
      '${recipient['parentLinked'] == true ? 'Đã liên kết PH' : 'Thiếu phụ huynh'}',
    ),
    trailing: recipient['excluded'] == true
        ? const Text('Loại trừ')
        : Text(
            NumberFormat.currency(
              locale: 'vi_VN',
              symbol: '₫',
              decimalDigits: 0,
            ).format(recipient['totalAmount'] ?? 0),
          ),
  );
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});
  final String status;
  @override
  Widget build(BuildContext context) {
    final color = status == 'OPEN'
        ? AppColors.success
        : status == 'DRAFT'
        ? AppColors.warning
        : AppColors.textSecondary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status,
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, this.action, this.actionLabel});
  final String title;
  final VoidCallback? action;
  final String? actionLabel;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(title, style: Theme.of(context).textTheme.titleMedium),
      ),
      if (action != null)
        TextButton.icon(
          onPressed: action,
          icon: const Icon(Icons.add_rounded),
          label: Text(actionLabel ?? 'Thêm'),
        ),
    ],
  );
}

class _EmptyLine extends StatelessWidget {
  const _EmptyLine({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: Text(text, style: Theme.of(context).textTheme.bodySmall),
  );
}

class _ErrorLine extends StatelessWidget {
  const _ErrorLine({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: const Icon(Icons.error_outline_rounded, color: AppColors.error),
    title: Text(text, style: const TextStyle(color: AppColors.error)),
  );
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.onRetry});
  final Future<void> Function() onRetry;
  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.error_outline_rounded, size: 42),
        const SizedBox(height: 8),
        const Text('Không thể tải chi tiết đợt thu'),
        TextButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('Thử lại'),
        ),
      ],
    ),
  );
}
