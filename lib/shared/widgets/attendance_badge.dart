import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class AttendanceBadge extends StatelessWidget {
  const AttendanceBadge(this.status, {super.key});

  final String status;

  @override
  Widget build(BuildContext context) {
    final (label, baseColor) = switch (status) {
      'PRESENT' => ('Có mặt', AppColors.present),
      'ABSENT_EXCUSED' => ('Vắng phép', AppColors.absentExcused),
      'ABSENT_UNEXCUSED' => ('Vắng không phép', AppColors.absentUnexcused),
      'LATE' => ('Muộn', AppColors.late),
      _ => (status, Theme.of(context).colorScheme.onSurfaceVariant),
    };
    final color = AppColors.adaptiveSemantic(context, baseColor);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
