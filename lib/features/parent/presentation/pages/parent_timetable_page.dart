import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/network/domain_realtime.dart';
import '../../../../core/network/realtime_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../timetable/data/timetable_slot.dart';

class ParentTimetablePage extends StatefulWidget {
  const ParentTimetablePage({
    super.key,
    required this.studentId,
    required this.studentName,
    required this.className,
  });

  final String studentId;
  final String studentName;
  final String className;

  @override
  State<ParentTimetablePage> createState() => _ParentTimetablePageState();
}

class _ParentTimetablePageState extends State<ParentTimetablePage>
    with WidgetsBindingObserver {
  static const _days = <String, String>{
    'MON': 'Thứ Hai',
    'TUE': 'Thứ Ba',
    'WED': 'Thứ Tư',
    'THU': 'Thứ Năm',
    'FRI': 'Thứ Sáu',
    'SAT': 'Thứ Bảy',
  };

  late Future<List<TimetableSlot>> _future;
  StreamSubscription<RealtimeEvent>? _events;
  Timer? _reloadDebounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _reload();
    final realtime = sl<RealtimeService>()..connect();
    _events = realtime.events
        .where(
          (event) => realtimeEventAffects(event, const {
            MobileDataDomain.timetable,
            MobileDataDomain.notifications,
          }),
        )
        .listen((_) => _scheduleReload());
  }

  void _reload() {
    _future = sl<ApiService>().childTimetable(widget.studentId);
  }

  Future<void> _refresh() async {
    setState(_reload);
    await _future;
  }

  void _scheduleReload() {
    _reloadDebounce?.cancel();
    _reloadDebounce = Timer(const Duration(milliseconds: 250), () {
      if (mounted) setState(_reload);
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) setState(_reload);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _reloadDebounce?.cancel();
    _events?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Lịch học của con'),
      backgroundColor: AppColors.parentAccent,
    ),
    body: FutureBuilder<List<TimetableSlot>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return _ErrorState(onRetry: () => setState(_reload));
        }
        final rows = snapshot.data ?? const <TimetableSlot>[];
        return RefreshIndicator(
          onRefresh: _refresh,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            children: [
              _StudentHeader(
                name: widget.studentName,
                className: widget.className,
                lessonCount: rows.length,
              ),
              const SizedBox(height: 18),
              if (rows.isEmpty)
                const _EmptyState()
              else
                for (final entry in _days.entries) ...[
                  if (rows.any((row) => row.dayOfWeek == entry.key)) ...[
                    SectionHeader(title: entry.value),
                    const SizedBox(height: 8),
                    ..._ofDay(rows, entry.key).map(_LessonCard.new),
                    const SizedBox(height: 12),
                  ],
                ],
            ],
          ),
        );
      },
    ),
  );

  List<TimetableSlot> _ofDay(List<TimetableSlot> rows, String day) {
    final result = rows.where((row) => row.dayOfWeek == day).toList();
    result.sort((a, b) => a.periodNo.compareTo(b.periodNo));
    return result;
  }
}

class _StudentHeader extends StatelessWidget {
  const _StudentHeader({
    required this.name,
    required this.className,
    required this.lessonCount,
  });

  final String name;
  final String className;
  final int lessonCount;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: AppColors.parentAccent,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(
      children: [
        const CircleAvatar(
          backgroundColor: Colors.white24,
          child: Icon(Icons.calendar_month_rounded, color: Colors.white),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'Lớp $className · $lessonCount tiết/tuần',
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _LessonCard extends StatelessWidget {
  const _LessonCard(this.item);

  final TimetableSlot item;

  @override
  Widget build(BuildContext context) {
    final period = item.periodNo;
    final start = item.startTime;
    final end = item.endTime;
    final room = item.roomCode.trim();
    final teacher = item.teacherName.trim();
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.parentAccent.withValues(alpha: .12),
          child: Text(
            period > 0 ? '$period' : '—',
            style: const TextStyle(
              color: AppColors.parentAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          item.subjectName.isEmpty ? 'Môn học' : item.subjectName,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          [
            if (start.isNotEmpty || end.isNotEmpty) '$start–$end',
            if (teacher.isNotEmpty) teacher,
            if (room.isNotEmpty) 'Phòng $room',
          ].join(' · '),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.symmetric(vertical: 80, horizontal: 24),
    child: Column(
      children: [
        Icon(Icons.event_busy_rounded, size: 52),
        SizedBox(height: 12),
        Text(
          'Chưa có thời khóa biểu được công bố',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 6),
        Text(
          'Lịch nháp của nhà trường sẽ không hiển thị tại đây.',
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off_rounded, size: 48),
          const SizedBox(height: 12),
          const Text('Không thể tải lịch học của con'),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Thử lại'),
          ),
        ],
      ),
    ),
  );
}
