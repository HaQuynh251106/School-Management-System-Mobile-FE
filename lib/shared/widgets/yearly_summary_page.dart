import 'package:flutter/material.dart';

import '../../core/di/service_locator.dart';
import '../../core/network/api_error_message.dart';
import '../../core/network/api_service.dart';
import '../../core/theme/app_colors.dart';

class YearlySummaryPage extends StatefulWidget {
  const YearlySummaryPage({
    super.key,
    this.studentId,
    this.studentName,
    required this.accent,
  });

  final String? studentId;
  final String? studentName;
  final Color accent;

  @override
  State<YearlySummaryPage> createState() => _YearlySummaryPageState();
}

class _YearlySummaryPageState extends State<YearlySummaryPage> {
  final _api = sl<ApiService>();
  late Future<_SummaryData> _future = _load();

  Future<_SummaryData> _load() async {
    final years = await _api.academicYears();
    if (years.isEmpty) throw StateError('Chưa có năm học.');
    final active = years.where((item) => item['status'] == 'ACTIVE');
    final year = active.isNotEmpty ? active.first : years.first;
    final id = year['id'].toString();
    final summary = widget.studentId == null
        ? await _api.myYearlySummary(id)
        : await _api.childYearlySummary(id, widget.studentId!);
    return _SummaryData(year, summary);
  }

  void _reload() => setState(() => _future = _load());

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(
        widget.studentName == null
            ? 'Tổng kết năm học'
            : 'Tổng kết - ${widget.studentName}',
      ),
      backgroundColor: widget.accent,
      actions: [
        IconButton(
          tooltip: 'Tải lại',
          onPressed: _reload,
          icon: const Icon(Icons.refresh_rounded),
        ),
      ],
    ),
    body: FutureBuilder<_SummaryData>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.info_outline, size: 40),
                  const SizedBox(height: 12),
                  const Text(
                    'Chưa có kết quả tổng kết cho năm học này.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    apiErrorMessage(
                      snapshot.error,
                      fallback: 'Không thể tải kết quả tổng kết lúc này.',
                    ),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _reload,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Thử lại'),
                  ),
                ],
              ),
            ),
          );
        }
        return _SummaryBody(data: snapshot.data!, accent: widget.accent);
      },
    ),
  );
}

class _SummaryData {
  const _SummaryData(this.year, this.summary);
  final Map<String, dynamic> year;
  final Map<String, dynamic> summary;
}

class _SummaryBody extends StatelessWidget {
  const _SummaryBody({required this.data, required this.accent});
  final _SummaryData data;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final item = data.summary;
    final status = (item['promotionStatus'] ?? 'INCOMPLETE').toString();
    final missing = item['missingRequirements']?.toString();
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: accent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                (data.year['name'] ?? data.year['code'] ?? '').toString(),
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 6),
              Text(
                _statusLabel(status),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                (item['studentName'] ?? '').toString(),
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _Score('Học kỳ 1', item['semesterOneAverage'], accent),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _Score('Học kỳ 2', item['semesterTwoAverage'], accent),
            ),
            const SizedBox(width: 8),
            Expanded(child: _Score('Cả năm', item['averageScore'], accent)),
          ],
        ),
        const SizedBox(height: 16),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: Icon(Icons.workspace_premium_outlined, color: accent),
                title: const Text('Hạnh kiểm'),
                trailing: Text(_conductLabel(item['conductGrade']?.toString())),
              ),
              const Divider(height: 1),
              ListTile(
                leading: Icon(Icons.trending_up_rounded, color: accent),
                title: const Text('Kết quả'),
                trailing: Text(_statusLabel(status)),
              ),
            ],
          ),
        ),
        if (missing != null && missing.isNotEmpty) ...[
          const SizedBox(height: 12),
          Card(
            color: const Color(0xfffff7e8),
            child: ListTile(
              leading: const Icon(
                Icons.warning_amber_rounded,
                color: Colors.orange,
              ),
              title: const Text('Dữ liệu còn thiếu'),
              subtitle: Text(missing),
            ),
          ),
        ],
        const SizedBox(height: 12),
        const Text(
          'Kết quả chỉ được chốt khi nhà trường hoàn tất điểm và hạnh kiểm.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textSecondary),
        ),
      ],
    );
  }

  String _statusLabel(String value) => switch (value) {
    'PROMOTED' => 'Được lên lớp',
    'RETAINED' => 'Ở lại lớp',
    'GRADUATED' => 'Đã tốt nghiệp',
    _ => 'Chưa hoàn tất',
  };

  String _conductLabel(String? value) => switch (value) {
    'GOOD' => 'Tốt',
    'FAIR' => 'Khá',
    'AVERAGE' => 'Trung bình',
    'WEAK' => 'Yếu',
    _ => 'Chưa đánh giá',
  };
}

class _Score extends StatelessWidget {
  const _Score(this.label, this.value, this.accent);
  final String label;
  final Object? value;
  final Color accent;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
      child: Column(
        children: [
          Text(
            value is num ? (value as num).toStringAsFixed(2) : '--',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: accent,
            ),
          ),
          const SizedBox(height: 4),
          Text(label, maxLines: 1, style: const TextStyle(fontSize: 12)),
        ],
      ),
    ),
  );
}
