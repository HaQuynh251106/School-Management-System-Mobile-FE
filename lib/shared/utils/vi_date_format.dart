import 'package:intl/intl.dart';

/// Formats API dates consistently for Vietnamese users.
///
/// Date-only ISO values are deliberately kept in their calendar date instead
/// of being converted through UTC, which could otherwise shift the day.
String formatViDate(Object? value, {String fallback = '—'}) {
  final raw = (value ?? '').toString().trim();
  if (raw.isEmpty) return fallback;

  final dateOnly = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(raw);
  final parsed = dateOnly == null
      ? DateTime.tryParse(raw)?.toLocal()
      : DateTime(
          int.parse(dateOnly.group(1)!),
          int.parse(dateOnly.group(2)!),
          int.parse(dateOnly.group(3)!),
        );
  return parsed == null ? raw : DateFormat('dd/MM/yyyy').format(parsed);
}

String formatViDateTime(Object? value, {String fallback = '—'}) {
  final raw = (value ?? '').toString().trim();
  if (raw.isEmpty) return fallback;
  final parsed = DateTime.tryParse(raw)?.toLocal();
  return parsed == null ? raw : DateFormat('dd/MM/yyyy HH:mm').format(parsed);
}

String formatViDateRange(Object? start, Object? end, {String fallback = '—'}) {
  final startLabel = formatViDate(start, fallback: '');
  final endLabel = formatViDate(end, fallback: '');
  if (startLabel.isEmpty && endLabel.isEmpty) return fallback;
  if (startLabel.isEmpty) return endLabel;
  if (endLabel.isEmpty) return startLabel;
  return '$startLabel – $endLabel';
}
