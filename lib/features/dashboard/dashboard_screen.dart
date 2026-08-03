import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/session.dart';
import '../../core/widgets/async_state_view.dart';
import '../../core/widgets/glass_ui.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key, required this.role, required this.accent});
  final String role;
  final Color accent;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<Map<String, dynamic>> future;

  @override
  void initState() {
    super.initState();
    future = context.read<AppSession>().api.map('/dashboard');
  }

  void reload() =>
      setState(() => future = context.read<AppSession>().api.map('/dashboard'));

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AppSession>().user!;
    return SafeArea(
      child: RefreshIndicator.adaptive(
        onRefresh: () async => reload(),
        child: AsyncStateView<Map<String, dynamic>>(
          future: future,
          onRetry: reload,
          builder: (context, data) {
            final metrics = _maps(data['metrics']);
            final charts = _maps(data['charts']);
            final tasks = _maps(data['tasks'] ?? data['today']);
            final notices = _maps(
              data['announcements'] ?? data['notifications'],
            );
            return ListView(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 110),
              children: [
                _GreetingCard(
                  name: user.fullName,
                  role: user.role,
                  accent: widget.accent,
                  className: user.className,
                ),
                const SizedBox(height: 20),
                _SectionTitle(
                  title: 'Thông tin quan trọng',
                  caption: 'Cập nhật trực tiếp từ hệ thống',
                  icon: Icons.auto_awesome_rounded,
                  color: widget.accent,
                ),
                const SizedBox(height: 12),
                if (metrics.isEmpty)
                  const _SoftEmpty(text: 'Chưa có số liệu tổng quan')
                else
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: metrics.length.clamp(0, 6),
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 260,
                          mainAxisExtent: 128,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                    itemBuilder: (_, index) => EntranceMotion(
                      index: index,
                      child: _MetricCard(
                        data: metrics[index],
                        accent: widget.accent,
                        index: index,
                      ),
                    ),
                  ),
                if (charts.isNotEmpty) ...[
                  const SizedBox(height: 26),
                  _SectionTitle(
                    title: 'Phân tích nhanh',
                    caption: 'Số liệu trực quan hỗ trợ ra quyết định',
                    icon: Icons.bar_chart_rounded,
                    color: widget.accent,
                  ),
                  const SizedBox(height: 12),
                  ...charts
                      .take(3)
                      .map(
                        (chart) =>
                            _ChartCard(chart: chart, accent: widget.accent),
                      ),
                ],
                const SizedBox(height: 26),
                _SectionTitle(
                  title: 'Cần xử lý',
                  caption: 'Ưu tiên theo thời gian và mức độ quan trọng',
                  icon: Icons.task_alt_rounded,
                  color: widget.accent,
                ),
                const SizedBox(height: 12),
                if (tasks.isEmpty)
                  const _SoftEmpty(text: 'Bạn chưa có công việc cần xử lý')
                else
                  ...tasks
                      .take(5)
                      .map(
                        (item) => _InfoTile(
                          item: item,
                          icon: Icons.check_circle_outline_rounded,
                          accent: widget.accent,
                        ),
                      ),
                const SizedBox(height: 26),
                _SectionTitle(
                  title: 'Thông báo mới',
                  caption: 'Những nội dung bạn cần biết',
                  icon: Icons.notifications_active_outlined,
                  color: widget.accent,
                ),
                const SizedBox(height: 12),
                if (notices.isEmpty)
                  const _SoftEmpty(text: 'Chưa có thông báo mới')
                else
                  ...notices
                      .take(4)
                      .map(
                        (item) => _InfoTile(
                          item: item,
                          icon: Icons.campaign_outlined,
                          accent: widget.accent,
                        ),
                      ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  const _ChartCard({required this.chart, required this.accent});
  final Map<String, dynamic> chart;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final points = _maps(chart['data']);
    final max = points.fold<double>(
      1,
      (value, item) => ((item['value'] as num?)?.toDouble() ?? 0) > value
          ? (item['value'] as num).toDouble()
          : value,
    );
    return GlassPanel(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${chart['title'] ?? 'Biểu đồ'}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          if (chart['subtitle'] != null)
            Text(
              '${chart['subtitle']}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          const SizedBox(height: 16),
          ...points.take(8).map((point) {
            final value = (point['value'] as num?)?.toDouble() ?? 0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 11),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text('${point['label'] ?? ''}')),
                      Text(
                        '${point['value'] ?? 0}${chart['suffix'] ?? ''}',
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  LinearProgressIndicator(
                    value: max == 0 ? 0 : value / max,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(8),
                    color: accent,
                    backgroundColor: accent.withValues(alpha: .1),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

List<Map<String, dynamic>> _maps(dynamic raw) {
  if (raw is List) {
    return raw.whereType<Map>().map((e) => e.cast<String, dynamic>()).toList();
  }
  if (raw is Map) {
    return raw.entries
        .map(
          (entry) => <String, dynamic>{
            'label': entry.key,
            'value': entry.value,
          },
        )
        .toList();
  }
  return [];
}

class _GreetingCard extends StatelessWidget {
  const _GreetingCard({
    required this.name,
    required this.role,
    required this.accent,
    this.className,
  });
  final String name;
  final String role;
  final Color accent;
  final String? className;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: .1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.school_outlined, color: accent, size: 28),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _welcome(),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 3),
                  Text(name, style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 5),
                  Text(
                    '${_roleName(role)}${className == null ? '' : ' · $className'}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _welcome() {
    final hour = DateTime.now().hour;
    if (hour < 11) return 'Chào buổi sáng';
    if (hour < 18) return 'Chào buổi chiều';
    return 'Chào buổi tối';
  }

  String _roleName(String value) => switch (value) {
    'ADMIN' => 'Quản trị viên',
    'TEACHER' => 'Giáo viên',
    'PARENT' => 'Phụ huynh',
    _ => 'Học sinh',
  };
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
    required this.caption,
    required this.icon,
    required this.color,
  });
  final String title;
  final String caption;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(
          color: color.withValues(alpha: .11),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color, size: 21),
      ),
      const SizedBox(width: 11),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            Text(caption, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    ],
  );
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.data,
    required this.accent,
    required this.index,
  });
  final Map<String, dynamic> data;
  final Color accent;
  final int index;

  @override
  Widget build(BuildContext context) {
    final label =
        '${data['label'] ?? data['title'] ?? data['name'] ?? 'Chỉ số'}';
    final value = '${data['value'] ?? data['count'] ?? data['total'] ?? '—'}';
    final colors = [
      accent,
      const Color(0xFF0F9D82),
      const Color(0xFF7A5AF8),
      const Color(0xFFEF8F35),
    ];
    final color = colors[index % colors.length];
    return GlassPanel(
      padding: const EdgeInsets.all(17),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          color.withValues(alpha: .13),
          Theme.of(context).colorScheme.surface.withValues(alpha: .34),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.insights_rounded, color: color),
          const Spacer(),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.item,
    required this.icon,
    required this.accent,
  });
  final Map<String, dynamic> item;
  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final title =
        '${item['title'] ?? item['name'] ?? item['label'] ?? 'Cập nhật'}';
    final subtitle =
        '${item['body'] ?? item['description'] ?? item['value'] ?? item['status'] ?? ''}';
    return GlassPanel(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
        leading: CircleAvatar(
          backgroundColor: accent.withValues(alpha: .11),
          child: Icon(icon, color: accent, size: 21),
        ),
        title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: subtitle.isEmpty
            ? null
            : Text(subtitle, maxLines: 2, overflow: TextOverflow.ellipsis),
        trailing: const Icon(Icons.chevron_right_rounded),
      ),
    );
  }
}

class _SoftEmpty extends StatelessWidget {
  const _SoftEmpty({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) => GlassPanel(
    padding: const EdgeInsets.all(22),
    child: Row(
      children: [
        const Icon(Icons.check_circle_outline_rounded),
        const SizedBox(width: 12),
        Expanded(child: Text(text)),
      ],
    ),
  );
}
