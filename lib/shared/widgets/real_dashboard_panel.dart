import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RealDashboardPanel extends StatelessWidget {
  const RealDashboardPanel({
    super.key,
    required this.dashboard,
    required this.accent,
    this.onRetry,
    this.onShortcut,
  });

  final Map<String, dynamic> dashboard;
  final Color accent;
  final VoidCallback? onRetry;
  final ValueChanged<Map<String, dynamic>>? onShortcut;

  @override
  Widget build(BuildContext context) {
    final metrics = _maps(dashboard['metrics']);
    final charts = _maps(dashboard['charts']);
    final shortcuts = _maps(dashboard['shortcuts']);
    final errors = _maps(dashboard['errors']);
    final scope = dashboard['scope'] is Map
        ? (dashboard['scope'] as Map).cast<String, dynamic>()
        : const <String, dynamic>{};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SnapshotHeader(asOf: '${dashboard['asOf'] ?? ''}', scope: scope),
        if (errors.isNotEmpty) ...[
          const SizedBox(height: 10),
          ...errors.map((error) => _PartialError(
                error: error,
                onRetry: error['retryable'] == true ? onRetry : null,
              )),
        ],
        const SizedBox(height: 14),
        if (metrics.isEmpty && charts.isEmpty)
          _EmptyDashboard(onRetry: onRetry)
        else ...[
          _MetricGrid(metrics: metrics, accent: accent),
          if (shortcuts.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text('Mở nhanh', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            _ShortcutGrid(
              shortcuts: shortcuts,
              accent: accent,
              onTap: onShortcut,
            ),
          ],
          if (charts.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text('Phân tích', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ...charts.map((chart) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _ChartCard(chart: chart, accent: accent),
                )),
          ],
        ],
      ],
    );
  }

  static List<Map<String, dynamic>> _maps(dynamic value) => value is List
      ? value
          .whereType<Map>()
          .map((item) => item.cast<String, dynamic>())
          .toList()
      : const [];
}

class _SnapshotHeader extends StatelessWidget {
  const _SnapshotHeader({required this.asOf, required this.scope});
  final String asOf;
  final Map<String, dynamic> scope;

  @override
  Widget build(BuildContext context) {
    final parsed = DateTime.tryParse(asOf)?.toLocal();
    final time = parsed == null
        ? 'Chưa xác định thời điểm dữ liệu'
        : 'Cập nhật ${DateFormat('dd/MM/yyyy HH:mm').format(parsed)}';
    final role = '${scope['role'] ?? ''}';
    final objectIds =
        scope['objectIds'] is List ? scope['objectIds'] as List : const [];
    final scopeText = objectIds.isEmpty
        ? 'Toàn trường'
        : objectIds.length == 1
            ? 'Phạm vi 1 hồ sơ'
            : 'Phạm vi ${objectIds.length} hồ sơ';
    return Row(
      children: [
        const Icon(Icons.cloud_done_outlined, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Text('$time · $scopeText',
              style: Theme.of(context).textTheme.bodySmall),
        ),
        if (role.isNotEmpty)
          Text(role.replaceAll('_', ' '),
              style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }
}

class _MetricGrid extends StatelessWidget {
  const _MetricGrid({required this.metrics, required this.accent});
  final List<Map<String, dynamic>> metrics;
  final Color accent;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) {
          final columns = constraints.maxWidth >= 720 ? 4 : 2;
          final width = (constraints.maxWidth - (columns - 1) * 10) / columns;
          return Wrap(
            spacing: 10,
            runSpacing: 10,
            children: metrics
                .map((metric) => SizedBox(
                      width: width,
                      height: 148,
                      child: _MetricCard(metric: metric, accent: accent),
                    ))
                .toList(),
          );
        },
      );
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.metric, required this.accent});
  final Map<String, dynamic> metric;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final value = (metric['value'] as num?)?.toDouble() ?? 0;
    final format = '${metric['format'] ?? 'NUMBER'}';
    final display = switch (format) {
      'CURRENCY' =>
        NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0)
            .format(value),
      'PERCENT' => '${value.toStringAsFixed(1)}%',
      'PERCENT_OR_EMPTY' => value == 0 ? '—' : '${value.toStringAsFixed(1)}%',
      'DECIMAL_1' => value.toStringAsFixed(1),
      _ => NumberFormat.decimalPattern('vi_VN').format(value),
    };
    final trend = metric['trend'] is Map
        ? (metric['trend'] as Map).cast<String, dynamic>()
        : const <String, dynamic>{};
    return Container(
      constraints: const BoxConstraints(minHeight: 142),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(_metricIcon('${metric['key'] ?? ''}'), color: accent, size: 21),
          const SizedBox(height: 9),
          Text(display,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 3),
          Text('${metric['label'] ?? ''}',
              maxLines: 2, overflow: TextOverflow.ellipsis),
          const Spacer(),
          Text('${trend['label'] ?? metric['hint'] ?? ''}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _ShortcutGrid extends StatelessWidget {
  const _ShortcutGrid(
      {required this.shortcuts, required this.accent, this.onTap});
  final List<Map<String, dynamic>> shortcuts;
  final Color accent;
  final ValueChanged<Map<String, dynamic>>? onTap;

  @override
  Widget build(BuildContext context) => Column(
        children: shortcuts
            .map((shortcut) => Padding(
                  padding: const EdgeInsets.only(bottom: 7),
                  child: Material(
                    color: Theme.of(context).colorScheme.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: Theme.of(context).dividerColor),
                    ),
                    child: ListTile(
                      leading: Icon(_targetIcon('${shortcut['target'] ?? ''}'),
                          color: accent),
                      title: Text('${shortcut['label'] ?? ''}'),
                      trailing: onTap == null
                          ? null
                          : const Icon(Icons.chevron_right_rounded),
                      onTap: onTap == null ? null : () => onTap!(shortcut),
                    ),
                  ),
                ))
            .toList(),
      );
}

class _ChartCard extends StatelessWidget {
  const _ChartCard({required this.chart, required this.accent});
  final Map<String, dynamic> chart;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final data = RealDashboardPanel._maps(chart['data']);
    final max = (chart['max'] as num?)?.toDouble() ?? 0;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${chart['title'] ?? ''}',
              style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 3),
          Text('${chart['subtitle'] ?? ''}',
              style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 12),
          if (data.isEmpty)
            const Text('Chưa có dữ liệu trong phạm vi này')
          else
            ...data.take(8).map((datum) {
              final value = (datum['value'] as num?)?.toDouble() ?? 0;
              final ratio = max <= 0 ? 0.0 : (value / max).clamp(0.0, 1.0);
              return Padding(
                padding: const EdgeInsets.only(bottom: 9),
                child: Row(
                  children: [
                    SizedBox(
                      width: 86,
                      child: Text('${datum['label'] ?? ''}',
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: LinearProgressIndicator(
                        value: ratio,
                        minHeight: 8,
                        color: accent,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                        '${value.toStringAsFixed(value % 1 == 0 ? 0 : 1)}${chart['suffix'] ?? ''}',
                        style: Theme.of(context).textTheme.labelSmall),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}

class _PartialError extends StatelessWidget {
  const _PartialError({required this.error, this.onRetry});
  final Map<String, dynamic> error;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.error_outline_rounded,
                color: Theme.of(context).colorScheme.onErrorContainer),
            const SizedBox(width: 10),
            Expanded(
                child: Text(
                    '${error['message'] ?? 'Một phần dữ liệu chưa tải được'}')),
            if (onRetry != null)
              IconButton(
                tooltip: 'Thử lại',
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
              ),
          ],
        ),
      );
}

class _EmptyDashboard extends StatelessWidget {
  const _EmptyDashboard({this.onRetry});
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 28),
          child: Column(
            children: [
              const Icon(Icons.query_stats_rounded, size: 42),
              const SizedBox(height: 10),
              const Text('Chưa có dữ liệu dashboard'),
              if (onRetry != null) ...[
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Thử lại'),
                ),
              ],
            ],
          ),
        ),
      );
}

IconData _metricIcon(String key) => switch (key) {
      'users' || 'children' => Icons.people_outline_rounded,
      'classes' => Icons.class_outlined,
      'attendance' => Icons.fact_check_outlined,
      'grades' => Icons.grade_outlined,
      'assignments' => Icons.assignment_outlined,
      'invoices' || 'payments' || 'overdue' => Icons.receipt_long_outlined,
      'notifications' || 'alerts' => Icons.notifications_active_outlined,
      _ => Icons.insights_outlined,
    };

IconData _targetIcon(String target) => switch (target) {
      'users' => Icons.people_outline_rounded,
      'timetable' => Icons.schedule_outlined,
      'finance' || 'reconciliation' => Icons.receipt_long_outlined,
      'assignments' => Icons.assignment_outlined,
      'attendance' => Icons.fact_check_outlined,
      'notifications' => Icons.notifications_outlined,
      'exams' => Icons.event_note_outlined,
      _ => Icons.open_in_new_rounded,
    };
