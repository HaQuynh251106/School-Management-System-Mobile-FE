import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/network/api_error_message.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/network/domain_realtime.dart';
import '../../../../core/network/realtime_service.dart';
import '../../../../core/theme/app_colors.dart';

class StudentExamResultsPage extends StatefulWidget {
  const StudentExamResultsPage({super.key});

  @override
  State<StudentExamResultsPage> createState() => _StudentExamResultsPageState();
}

class _StudentExamResultsPageState extends State<StudentExamResultsPage>
    with WidgetsBindingObserver {
  final _api = sl<ApiService>();
  late Future<List<Map<String, dynamic>>> _future = _api.examResults();
  late final DomainRealtimeSubscription _domainEvents;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _domainEvents = DomainRealtimeSubscription.listen(
      realtime: sl<RealtimeService>(),
      domains: const {
        MobileDataDomain.exams,
        MobileDataDomain.grades,
        MobileDataDomain.notifications,
      },
      onInvalidate: _scheduleReload,
    );
  }

  void _scheduleReload() {
    if (mounted) setState(() => _future = _api.examResults());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _scheduleReload();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_domainEvents.dispose());
    super.dispose();
  }

  Future<void> _reload() async {
    final future = _api.examResults();
    setState(() => _future = future);
    await future;
  }

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
                apiErrorMessage(
                  snapshot.error,
                  fallback: 'Không thể tải kết quả kỳ thi.',
                ),
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
                                  (result['examPeriodName'] ??
                                          result['examName'] ??
                                          'Điểm kiểm tra học kỳ')
                                      .toString(),
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
                      const SizedBox(height: 12),
                      const Text(
                        'Kết quả được đồng bộ từ bảng điểm chính thức của nhà trường.',
                        style: TextStyle(color: Colors.black54, fontSize: 12),
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
  );
}
