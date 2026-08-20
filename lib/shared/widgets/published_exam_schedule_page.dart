import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/di/service_locator.dart';
import '../../core/network/api_error_message.dart';
import '../../core/network/api_service.dart';
import '../../core/network/domain_realtime.dart';
import '../../core/network/realtime_service.dart';
import '../utils/vi_date_format.dart';

class PublishedExamSchedulePage extends StatefulWidget {
  const PublishedExamSchedulePage({super.key, this.childId});

  final String? childId;

  @override
  State<PublishedExamSchedulePage> createState() =>
      _PublishedExamSchedulePageState();
}

class _PublishedExamSchedulePageState extends State<PublishedExamSchedulePage>
    with WidgetsBindingObserver {
  final _api = sl<ApiService>();
  late Future<List<Map<String, dynamic>>> _future = _load();
  late final DomainRealtimeSubscription _events;

  Future<List<Map<String, dynamic>>> _load() =>
      _api.examAgenda(childId: widget.childId);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _events = DomainRealtimeSubscription.listen(
      realtime: sl<RealtimeService>(),
      domains: const {MobileDataDomain.exams},
      onInvalidate: _reload,
    );
  }

  void _reload() {
    if (mounted) setState(() => _future = _load());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _reload();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_events.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Lịch thi đã công bố')),
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
                  fallback: 'Không thể tải lịch thi đã công bố.',
                ),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }
        final rows = snapshot.data ?? const [];
        return RefreshIndicator(
          onRefresh: () async {
            _reload();
            await _future;
          },
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (rows.isEmpty) ...const [
                SizedBox(height: 120),
                Icon(Icons.event_busy_outlined, size: 52),
                SizedBox(height: 12),
                Text(
                  'Chưa có lịch thi được công bố',
                  textAlign: TextAlign.center,
                ),
              ] else
                ...rows.map(
                  (row) => Card(
                    child: ListTile(
                      leading: const Icon(Icons.event_available_outlined),
                      title: Text(
                        '${row['subjectName'] ?? 'Môn thi'}',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      subtitle: Text(
                        '${row['periodName'] ?? row['semesterName'] ?? ''}\n'
                        '${formatViDate(row['examDate'])} · '
                        '${row['startTime'] ?? ''}–${row['endTime'] ?? ''}'
                        '${row['roomCode'] == null ? '' : ' · Phòng ${row['roomCode']}'}'
                        '${row['dutyRole'] == null ? '' : '\nNhiệm vụ: ${row['dutyRole']}'}',
                      ),
                      isThreeLine: true,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    ),
  );
}
