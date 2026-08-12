import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class UpcomingExamBanner extends StatelessWidget {
  const UpcomingExamBanner({
    super.key,
    required this.exams,
    required this.accent,
    required this.onTap,
    this.studentName,
  });

  final List<Map<String, dynamic>> exams;
  final Color accent;
  final VoidCallback onTap;
  final String? studentName;

  @override
  Widget build(BuildContext context) {
    final upcoming =
        exams.where((item) {
          final status = '${item['status'] ?? ''}'.toUpperCase();
          return status == 'UPCOMING' || status == 'TODAY';
        }).toList()..sort((a, b) {
          final aKey = '${a['examDate'] ?? ''} ${a['startTime'] ?? ''}';
          final bKey = '${b['examDate'] ?? ''} ${b['startTime'] ?? ''}';
          return aKey.compareTo(bKey);
        });
    if (upcoming.isEmpty) return const SizedBox.shrink();

    final next = upcoming.first;
    final date = DateTime.tryParse('${next['examDate'] ?? ''}');
    final dateLabel = date == null
        ? '${next['examDate'] ?? ''}'
        : DateFormat('dd/MM/yyyy').format(date);
    final subject = '${next['subjectName'] ?? 'Môn thi'}';
    final room = '${next['roomCode'] ?? ''}'.trim();
    final time = '${next['startTime'] ?? ''}'.trim();
    final today = '${next['status'] ?? ''}'.toUpperCase() == 'TODAY';
    final suffix = studentName == null ? '' : ' của $studentName';

    return Material(
      color: accent.withValues(alpha: .1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: accent.withValues(alpha: .35)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.event_note_rounded,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      today
                          ? 'Kỳ thi diễn ra hôm nay$suffix'
                          : 'Kỳ thi sắp diễn ra$suffix',
                      style: TextStyle(
                        color: accent,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '$subject • $dateLabel${time.isEmpty ? '' : ' lúc $time'}${room.isEmpty ? '' : ' • Phòng $room'}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (upcoming.length > 1)
                      Text(
                        'Còn ${upcoming.length - 1} môn thi khác',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}
