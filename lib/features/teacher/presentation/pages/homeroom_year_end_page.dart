import 'package:flutter/material.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/theme/app_colors.dart';

class HomeroomYearEndPage extends StatefulWidget {
  const HomeroomYearEndPage({super.key});

  @override
  State<HomeroomYearEndPage> createState() => _HomeroomYearEndPageState();
}

class _HomeroomYearEndPageState extends State<HomeroomYearEndPage> {
  final _api = sl<ApiService>();
  late Future<_HomeroomData> _future = _load();
  String? _savingStudent;

  Future<_HomeroomData> _load() async {
    final years = await _api.academicYears();
    if (years.isEmpty) throw StateError('Chưa có năm học.');
    final active = years.where((item) => item['status'] == 'ACTIVE');
    final year = active.isNotEmpty ? active.first : years.first;
    final rows = await _api.homeroomYearlySummaries(year['id'].toString());
    return _HomeroomData(year, rows);
  }

  void _reload() => setState(() => _future = _load());

  Future<void> _save(_HomeroomData data, String studentId, String grade) async {
    setState(() => _savingStudent = studentId);
    try {
      await _api.setStudentConduct(
        yearId: data.year['id'].toString(),
        studentId: studentId,
        conductGrade: grade,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Đã cập nhật hạnh kiểm.')));
      _reload();
    } catch (error) {
      if (!mounted) return;
      setState(() => _savingStudent = null);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Không thể cập nhật: $error')));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Tổng kết lớp chủ nhiệm'),
      backgroundColor: AppColors.teacherAccent,
      actions: [
        IconButton(onPressed: _reload, icon: const Icon(Icons.refresh)),
      ],
    ),
    body: FutureBuilder<_HomeroomData>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Text('Không tải được dữ liệu: ${snapshot.error}'),
          );
        }
        final data = snapshot.data!;
        if (data.rows.isEmpty) {
          return const Center(
            child: Text('Không có học sinh thuộc lớp chủ nhiệm.'),
          );
        }
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              color: AppColors.teacherAccent.withValues(alpha: .08),
              child: ListTile(
                leading: const Icon(
                  Icons.fact_check_outlined,
                  color: AppColors.teacherAccent,
                ),
                title: Text(
                  (data.year['name'] ?? data.year['code']).toString(),
                ),
                subtitle: const Text(
                  'Nhập hạnh kiểm để hoàn thiện tổng kết năm.',
                ),
              ),
            ),
            const SizedBox(height: 8),
            ...data.rows.map((item) {
              final id = item['studentId'].toString();
              final saving = _savingStudent == id;
              return Card(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 12, 10),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: AppColors.teacherAccent.withValues(
                          alpha: .12,
                        ),
                        child: Text(
                          (item['studentName'] ?? '?').toString().substring(
                            0,
                            1,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              (item['studentName'] ?? '').toString(),
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              'TB: ${item['averageScore'] ?? '--'} • ${_status(item['promotionStatus'])}',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (saving)
                        const SizedBox.square(
                          dimension: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      else
                        DropdownButton<String>(
                          value: item['conductGrade']?.toString(),
                          hint: const Text('Hạnh kiểm'),
                          items: const [
                            DropdownMenuItem(value: 'GOOD', child: Text('Tốt')),
                            DropdownMenuItem(value: 'FAIR', child: Text('Khá')),
                            DropdownMenuItem(
                              value: 'AVERAGE',
                              child: Text('Trung bình'),
                            ),
                            DropdownMenuItem(value: 'WEAK', child: Text('Yếu')),
                          ],
                          onChanged: (value) {
                            if (value != null) _save(data, id, value);
                          },
                        ),
                    ],
                  ),
                ),
              );
            }),
          ],
        );
      },
    ),
  );

  String _status(Object? value) => switch (value?.toString()) {
    'PROMOTED' => 'Lên lớp',
    'RETAINED' => 'Ở lại lớp',
    'GRADUATED' => 'Tốt nghiệp',
    _ => 'Chưa đủ dữ liệu',
  };
}

class _HomeroomData {
  const _HomeroomData(this.year, this.rows);
  final Map<String, dynamic> year;
  final List<Map<String, dynamic>> rows;
}
