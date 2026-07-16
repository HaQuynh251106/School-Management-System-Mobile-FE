import 'package:flutter/material.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/theme/app_colors.dart';

class YearEndPage extends StatefulWidget {
  const YearEndPage({super.key});

  @override
  State<YearEndPage> createState() => _YearEndPageState();
}

class _YearEndPageState extends State<YearEndPage> {
  final _api = sl<ApiService>();
  late Future<List<Map<String, dynamic>>> _years;
  Future<List<Map<String, dynamic>>>? _rows;
  String? _yearId;
  bool _finalizing = false;

  @override
  void initState() {
    super.initState();
    _years = _api.academicYears();
  }

  void _load(String? yearId) {
    setState(() {
      _yearId = yearId;
      _rows = yearId == null ? null : _api.promotionPreview(yearId);
    });
  }

  Future<void> _setConduct(String studentId, String value) async {
    try {
      await _api.setConduct(_yearId!, studentId, value);
      _load(_yearId);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Không thể lưu hạnh kiểm: $e'),
        backgroundColor: AppColors.error,
      ));
    }
  }

  Future<void> _finalize() async {
    if (_yearId == null) return;
    final accepted = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chốt năm học?'),
        content: const Text(
            'Hệ thống sẽ khóa kết quả và tự động xét lên lớp cho học sinh đủ điều kiện.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Hủy')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Chốt năm học')),
        ],
      ),
    );
    if (accepted != true) return;
    setState(() => _finalizing = true);
    try {
      await _api.finalizeYear(_yearId!);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Đã hoàn tất tổng kết năm học'),
        backgroundColor: AppColors.success,
      ));
      _load(_yearId);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Chưa thể chốt năm học: $e'),
        backgroundColor: AppColors.error,
      ));
    } finally {
      if (mounted) setState(() => _finalizing = false);
    }
  }

  String _status(String value) => switch (value) {
        'READY' => 'Sẵn sàng',
        'INCOMPLETE' => 'Thiếu dữ liệu',
        'PROMOTED' => 'Lên lớp',
        'PROMOTED_PENDING_CLASS' => 'Chờ xếp lớp',
        'GRADUATED' => 'Tốt nghiệp',
        'RETAINED' => 'Lưu ban',
        _ => value,
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tổng kết năm học'),
        backgroundColor: AppColors.adminAccent,
        actions: [
          IconButton(
            tooltip: 'Chốt năm học',
            onPressed: _yearId == null || _finalizing ? null : _finalize,
            icon: _finalizing
                ? const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.task_alt_rounded),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _years,
              builder: (context, snap) => DropdownButtonFormField<String>(
                initialValue: _yearId,
                decoration: const InputDecoration(
                    labelText: 'Năm học',
                    prefixIcon: Icon(Icons.calendar_month_rounded)),
                items: (snap.data ?? const [])
                    .map((year) => DropdownMenuItem<String>(
                          value: year['id']?.toString(),
                          child: Text('${year['code']} · ${year['status']}'),
                        ))
                    .toList(),
                onChanged: _load,
              ),
            ),
          ),
          Expanded(
            child: _rows == null
                ? const Center(
                    child: Text('Chọn năm học để kiểm tra dữ liệu tổng kết'))
                : FutureBuilder<List<Map<String, dynamic>>>(
                    future: _rows,
                    builder: (context, snap) {
                      if (snap.connectionState != ConnectionState.done) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snap.hasError) {
                        return Center(
                            child:
                                Text('Không tải được dữ liệu: ${snap.error}'));
                      }
                      final rows = snap.data ?? const [];
                      if (rows.isEmpty) {
                        return const Center(
                            child: Text('Năm học chưa có học sinh'));
                      }
                      return RefreshIndicator(
                        onRefresh: () async => _load(_yearId),
                        child: ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                          itemCount: rows.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final row = rows[index];
                            final missing =
                                row['missingRequirements']?.toString();
                            return Card(
                              child: Padding(
                                padding: const EdgeInsets.all(14),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(children: [
                                      Expanded(
                                          child: Text(
                                              row['studentName']?.toString() ??
                                                  '',
                                              style: const TextStyle(
                                                  fontWeight:
                                                      FontWeight.w700))),
                                      Chip(
                                          label: Text(_status(
                                              row['promotionStatus']
                                                      ?.toString() ??
                                                  ''))),
                                    ]),
                                    Text(
                                        'Điểm trung bình: ${row['averageScore'] ?? '—'}'),
                                    if (missing != null &&
                                        missing.isNotEmpty) ...[
                                      const SizedBox(height: 6),
                                      Text(missing,
                                          style: const TextStyle(
                                              color: AppColors.warning,
                                              fontSize: 12)),
                                    ],
                                    const SizedBox(height: 10),
                                    DropdownButtonFormField<String>(
                                      initialValue:
                                          row['conductGrade']?.toString(),
                                      decoration: const InputDecoration(
                                          labelText: 'Hạnh kiểm',
                                          isDense: true),
                                      items: const [
                                        DropdownMenuItem(
                                            value: 'GOOD', child: Text('Tốt')),
                                        DropdownMenuItem(
                                            value: 'FAIR', child: Text('Khá')),
                                        DropdownMenuItem(
                                            value: 'AVERAGE',
                                            child: Text('Trung bình')),
                                        DropdownMenuItem(
                                            value: 'WEAK', child: Text('Yếu')),
                                      ],
                                      onChanged: row['finalizedAt'] == null
                                          ? (value) {
                                              if (value != null) {
                                                _setConduct(
                                                    row['studentId'].toString(),
                                                    value);
                                              }
                                            }
                                          : null,
                                    ),
                                  ],
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
      ),
    );
  }
}
