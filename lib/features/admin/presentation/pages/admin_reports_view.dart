import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/theme/app_colors.dart';

class AdminReportsView extends StatefulWidget {
  const AdminReportsView({super.key});

  @override
  State<AdminReportsView> createState() => _AdminReportsViewState();
}

class _AdminReportsViewState extends State<AdminReportsView> {
  final _api = sl<ApiService>();
  String _type = 'grades';
  String? _classId;
  String? _semesterId;
  String? _subjectId;
  String? _periodId;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _exporting = false;
  late Future<_ReportData> _future = _load();
  late Future<_Options> _options = _loadOptions();

  Future<_Options> _loadOptions() async {
    final values = await Future.wait([
      _api.classes(),
      _api.semesters(),
      _api.subjects(),
      _api.feePeriods(),
    ]);
    return _Options(values[0], values[1], values[2], values[3]);
  }

  Future<_ReportData> _load() async {
    final asOf = DateTime.now();
    switch (_type) {
      case 'attendance':
        final summary = await _api.reportAttendance(
          classId: _classId,
          startDate: _startDate,
          endDate: _endDate,
        );
        return _ReportData(asOf, [
          _Row('Có mặt', summary['present'] ?? 0),
          _Row('Đi muộn', summary['late'] ?? 0),
          _Row('Vắng có phép', summary['absentExcused'] ?? 0),
          _Row('Vắng không phép', summary['absentUnexcused'] ?? 0),
        ]);
      case 'revenue':
        final summary = await _api.reportRevenue(
          periodId: _periodId,
          classId: _classId,
        );
        return _ReportData(
          asOf,
          summary.entries.map((entry) => _Row(entry.key, entry.value)).toList(),
        );
      case 'overview':
        final summary = await _api.reportOverview();
        return _ReportData(
          asOf,
          summary.entries.map((entry) => _Row(entry.key, entry.value)).toList(),
        );
      default:
        final rows = await _api.reportGradeDistribution(
          semesterId: _semesterId,
          classId: _classId,
          subjectId: _subjectId,
        );
        return _ReportData(
          asOf,
          rows
              .map((item) => _Row('${item['band'] ?? ''}', item['count'] ?? 0))
              .toList(),
        );
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _future = _load();
    });
    await _future;
  }

  void _apply() {
    setState(() {
      _future = _load();
    });
  }

  Future<void> _export(String format) async {
    setState(() => _exporting = true);
    try {
      final bytes = await _api.exportReport(
        type: _type,
        format: format,
        semesterId: _semesterId,
        classId: _classId,
        subjectId: _subjectId,
        startDate: _startDate,
        endDate: _endDate,
        periodId: _periodId,
      );
      final stamp = DateFormat('yyyyMMdd-HHmmss').format(DateTime.now());
      await FilePicker.platform.saveFile(
        dialogTitle: 'Lưu báo cáo',
        fileName: 'bao-cao-$_type-$stamp.$format',
        bytes: Uint8List.fromList(bytes),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã tạo báo cáo ${format.toUpperCase()}')),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không thể export báo cáo: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Báo cáo dữ liệu thật',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 4),
          Text('Chọn loại báo cáo và bộ lọc trước khi xem hoặc export.',
              style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            initialValue: _type,
            decoration: const InputDecoration(labelText: 'Loại báo cáo'),
            items: const [
              DropdownMenuItem(value: 'grades', child: Text('Phổ điểm')),
              DropdownMenuItem(value: 'attendance', child: Text('Chuyên cần')),
              DropdownMenuItem(
                  value: 'revenue', child: Text('Doanh thu và công nợ')),
              DropdownMenuItem(
                  value: 'overview', child: Text('Tổng quan hệ thống')),
            ],
            onChanged: (value) {
              if (value == null) return;
              setState(() {
                _type = value;
                _future = _load();
              });
            },
          ),
          const SizedBox(height: 10),
          FutureBuilder<_Options>(
            future: _options,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return _InlineError(
                    onRetry: () => setState(() {
                          _options = _loadOptions();
                        }));
              }
              if (!snapshot.hasData) return const LinearProgressIndicator();
              return _Filters(
                type: _type,
                options: snapshot.data!,
                classId: _classId,
                semesterId: _semesterId,
                subjectId: _subjectId,
                periodId: _periodId,
                startDate: _startDate,
                endDate: _endDate,
                onClass: (value) => setState(() => _classId = value),
                onSemester: (value) => setState(() => _semesterId = value),
                onSubject: (value) => setState(() => _subjectId = value),
                onPeriod: (value) => setState(() => _periodId = value),
                onStart: (value) => setState(() => _startDate = value),
                onEnd: (value) => setState(() => _endDate = value),
                onApply: _apply,
              );
            },
          ),
          const SizedBox(height: 16),
          FutureBuilder<_ReportData>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(
                    child: Padding(
                  padding: EdgeInsets.all(28),
                  child: CircularProgressIndicator(),
                ));
              }
              if (snapshot.hasError) return _ReportError(onRetry: _refresh);
              return _Result(
                  data: snapshot.data!, accent: AppColors.adminAccent);
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _exporting ? null : () => _export('xlsx'),
                  icon: const Icon(Icons.table_chart_outlined),
                  label: const Text('Excel'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _exporting ? null : () => _export('pdf'),
                  icon: const Icon(Icons.picture_as_pdf_outlined),
                  label: const Text('PDF'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

class _Filters extends StatelessWidget {
  const _Filters({
    required this.type,
    required this.options,
    required this.classId,
    required this.semesterId,
    required this.subjectId,
    required this.periodId,
    required this.startDate,
    required this.endDate,
    required this.onClass,
    required this.onSemester,
    required this.onSubject,
    required this.onPeriod,
    required this.onStart,
    required this.onEnd,
    required this.onApply,
  });

  final String type;
  final _Options options;
  final String? classId;
  final String? semesterId;
  final String? subjectId;
  final String? periodId;
  final DateTime? startDate;
  final DateTime? endDate;
  final ValueChanged<String?> onClass;
  final ValueChanged<String?> onSemester;
  final ValueChanged<String?> onSubject;
  final ValueChanged<String?> onPeriod;
  final ValueChanged<DateTime?> onStart;
  final ValueChanged<DateTime?> onEnd;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          if (type != 'overview')
            _OptionField(
              label: 'Lớp',
              value: classId,
              rows: options.classes,
              onChanged: onClass,
            ),
          if (type == 'grades') ...[
            const SizedBox(height: 8),
            _OptionField(
                label: 'Học kỳ',
                value: semesterId,
                rows: options.semesters,
                onChanged: onSemester),
            const SizedBox(height: 8),
            _OptionField(
                label: 'Môn học',
                value: subjectId,
                rows: options.subjects,
                onChanged: onSubject),
          ],
          if (type == 'revenue') ...[
            const SizedBox(height: 8),
            _OptionField(
                label: 'Đợt thu',
                value: periodId,
                rows: options.periods,
                onChanged: onPeriod),
          ],
          if (type == 'attendance') ...[
            const SizedBox(height: 8),
            Row(children: [
              Expanded(
                  child: _DateField(
                      label: 'Từ ngày', value: startDate, onChanged: onStart)),
              const SizedBox(width: 8),
              Expanded(
                  child: _DateField(
                      label: 'Đến ngày', value: endDate, onChanged: onEnd)),
            ]),
          ],
          if (type != 'overview') ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onApply,
                icon: const Icon(Icons.filter_alt_outlined),
                label: const Text('Áp dụng bộ lọc'),
              ),
            ),
          ],
        ],
      );
}

class _OptionField extends StatelessWidget {
  const _OptionField(
      {required this.label,
      required this.value,
      required this.rows,
      required this.onChanged});
  final String label;
  final String? value;
  final List<Map<String, dynamic>> rows;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) => DropdownButtonFormField<String?>(
        initialValue: value,
        decoration: InputDecoration(labelText: label),
        items: [
          const DropdownMenuItem<String?>(value: null, child: Text('Tất cả')),
          ...rows.map((row) => DropdownMenuItem<String?>(
                value: '${row['id']}',
                child: Text(
                    '${row['name'] ?? row['code'] ?? row['title'] ?? row['id']}',
                    overflow: TextOverflow.ellipsis),
              )),
        ],
        onChanged: onChanged,
      );
}

class _DateField extends StatelessWidget {
  const _DateField(
      {required this.label, required this.value, required this.onChanged});
  final String label;
  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;

  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
        onPressed: () async {
          final date = await showDatePicker(
            context: context,
            firstDate: DateTime(2020),
            lastDate: DateTime(2035),
            initialDate: value ?? DateTime.now(),
          );
          if (date != null) onChanged(date);
        },
        icon: const Icon(Icons.calendar_today_outlined, size: 18),
        label: Text(
            value == null ? label : DateFormat('dd/MM/yyyy').format(value!)),
      );
}

class _Result extends StatelessWidget {
  const _Result({required this.data, required this.accent});
  final _ReportData data;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final max = data.rows.fold<double>(0, (value, row) {
      final number = row.value is num ? (row.value as num).toDouble() : 0.0;
      return number > value ? number : value;
    });
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Cập nhật ${DateFormat('dd/MM/yyyy HH:mm').format(data.asOf)}',
              style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 12),
          if (data.rows.isEmpty)
            const Text('Không có dữ liệu với bộ lọc đang áp dụng')
          else
            ...data.rows.map((row) {
              final number =
                  row.value is num ? (row.value as num).toDouble() : 0;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(children: [
                  SizedBox(
                      width: 112,
                      child: Text(_label(row.label),
                          maxLines: 2, overflow: TextOverflow.ellipsis)),
                  const SizedBox(width: 8),
                  Expanded(
                      child: LinearProgressIndicator(
                    value: max == 0 ? 0 : (number / max).clamp(0.0, 1.0),
                    minHeight: 8,
                    color: accent,
                    borderRadius: BorderRadius.circular(4),
                  )),
                  const SizedBox(width: 8),
                  Text(_value(row.value),
                      style: Theme.of(context).textTheme.labelMedium),
                ]),
              );
            }),
        ],
      ),
    );
  }

  String _value(Object? value) => value is num
      ? NumberFormat.decimalPattern('vi_VN').format(value)
      : '$value';
  String _label(String value) =>
      const {
        'students': 'Học sinh',
        'teachers': 'Giáo viên',
        'parents': 'Phụ huynh',
        'admins': 'Quản trị',
        'classes': 'Lớp học',
        'subjects': 'Môn học',
        'totalAmount': 'Tổng phải thu',
        'paidAmount': 'Đã thu',
        'outstandingAmount': 'Còn phải thu',
      }[value] ??
      value;
}

class _ReportError extends StatelessWidget {
  const _ReportError({required this.onRetry});
  final Future<void> Function() onRetry;
  @override
  Widget build(BuildContext context) => Column(children: [
        const Icon(Icons.error_outline_rounded, size: 38),
        const SizedBox(height: 8),
        const Text('Không thể tải báo cáo dữ liệu thật'),
        TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Thử lại')),
      ]);
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.onRetry});
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => ListTile(
        leading: const Icon(Icons.error_outline_rounded),
        title: const Text('Không tải được danh sách bộ lọc'),
        trailing: IconButton(
            tooltip: 'Thử lại',
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded)),
      );
}

class _Options {
  const _Options(this.classes, this.semesters, this.subjects, this.periods);
  final List<Map<String, dynamic>> classes;
  final List<Map<String, dynamic>> semesters;
  final List<Map<String, dynamic>> subjects;
  final List<Map<String, dynamic>> periods;
}

class _ReportData {
  const _ReportData(this.asOf, this.rows);
  final DateTime asOf;
  final List<_Row> rows;
}

class _Row {
  const _Row(this.label, this.value);
  final String label;
  final Object? value;
}
