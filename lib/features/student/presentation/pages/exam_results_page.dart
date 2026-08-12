import 'package:flutter/material.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/theme/app_colors.dart';

class StudentExamResultsPage extends StatefulWidget {
  const StudentExamResultsPage({super.key});

  @override
  State<StudentExamResultsPage> createState() => _StudentExamResultsPageState();
}

class _StudentExamResultsPageState extends State<StudentExamResultsPage> {
  final _api = sl<ApiService>();
  late Future<List<Map<String, dynamic>>> _future = _api.examResults();

  Future<void> _reload() async {
    final future = _api.examResults();
    setState(() => _future = future);
    await future;
  }

  Future<void> _request(Map<String, dynamic> result) async {
    final reason = TextEditingController();
    final submitted = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          16,
          16,
          MediaQuery.viewInsetsOf(sheetContext).bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Yêu cầu phúc khảo',
              style: Theme.of(
                sheetContext,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text('${result['subjectName']} · Điểm ${result['score'] ?? '—'}'),
            const SizedBox(height: 12),
            TextField(
              controller: reason,
              minLines: 3,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Lý do',
                helperText: 'Tối thiểu 10 ký tự',
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () {
                if (reason.text.trim().length < 10) {
                  ScaffoldMessenger.of(sheetContext).showSnackBar(
                    const SnackBar(
                      content: Text('Lý do cần có ít nhất 10 ký tự.'),
                    ),
                  );
                  return;
                }
                Navigator.of(sheetContext).pop(true);
              },
              icon: const Icon(Icons.send_rounded),
              label: const Text('Gửi yêu cầu'),
            ),
          ],
        ),
      ),
    );
    if (submitted != true) {
      reason.dispose();
      return;
    }
    try {
      await _api.requestExamReview(
        result['examPeriodId'].toString(),
        resultId: result['resultId'].toString(),
        reason: reason.text.trim(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã gửi yêu cầu phúc khảo.')),
        );
      }
      await _reload();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không thể gửi phúc khảo: $error')),
        );
      }
    } finally {
      reason.dispose();
    }
  }

  String _reviewLabel(String? status) => switch (status) {
    'PENDING' => 'Đang chờ xử lý',
    'APPROVED' => 'Đã điều chỉnh',
    'REJECTED' => 'Giữ nguyên kết quả',
    _ => '',
  };

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Kết quả kỳ thi'),
      backgroundColor: AppColors.studentAccent,
    ),
    body: FutureBuilder<List<Map<String, dynamic>>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Không thể tải kết quả.\n${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }
        final results = snapshot.data ?? const [];
        if (results.isEmpty) {
          return RefreshIndicator(
            onRefresh: _reload,
            child: ListView(
              children: const [
                SizedBox(height: 140),
                Icon(Icons.hourglass_empty_rounded, size: 52),
                SizedBox(height: 12),
                Text(
                  'Chưa có kết quả kỳ thi được công bố',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: _reload,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: results.length,
            itemBuilder: (context, index) {
              final result = results[index];
              final reviewStatus = result['reviewStatus']?.toString();
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  result['subjectName'].toString(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  result['examPeriodName'].toString(),
                                  style: const TextStyle(color: Colors.black54),
                                ),
                              ],
                            ),
                          ),
                          CircleAvatar(
                            radius: 27,
                            backgroundColor: AppColors.studentAccent.withValues(
                              alpha: .12,
                            ),
                            child: Text(
                              '${result['resolvedScore'] ?? result['score'] ?? '—'}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                color: AppColors.studentAccent,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if ((result['note'] ?? '').toString().isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text('Ghi chú: ${result['note']}'),
                      ],
                      if (reviewStatus != null) ...[
                        const Divider(height: 24),
                        Row(
                          children: [
                            const Icon(Icons.rate_review_outlined, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              _reviewLabel(reviewStatus),
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        if ((result['reviewResolution'] ?? '')
                            .toString()
                            .isNotEmpty)
                          Text(result['reviewResolution'].toString()),
                      ] else ...[
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: () => _request(result),
                          icon: const Icon(Icons.rate_review_outlined),
                          label: const Text('Yêu cầu phúc khảo'),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    ),
  );
}
