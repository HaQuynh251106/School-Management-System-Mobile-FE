import 'package:flutter/material.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/theme/app_colors.dart';

class _Template {
  const _Template({
    required this.id,
    required this.code,
    required this.name,
    required this.channel,
    required this.subject,
    required this.body,
    this.active = true,
  });
  final String? id;
  final String code;
  final String name;
  final String channel;
  final String subject;
  final String body;
  final bool active;

  factory _Template.fromJson(Map<String, dynamic> m) => _Template(
        id: m['id']?.toString(),
        code: (m['code'] ?? '').toString(),
        name: (m['name'] ?? '').toString(),
        channel: (m['channel'] ?? '').toString(),
        subject: (m['titleTemplate'] ?? '').toString(),
        body: (m['bodyTemplate'] ?? '').toString(),
        active: m['active'] == true,
      );
}

class NotificationTemplatesPage extends StatefulWidget {
  const NotificationTemplatesPage({super.key});

  @override
  State<NotificationTemplatesPage> createState() =>
      _NotificationTemplatesPageState();
}

class _NotificationTemplatesPageState extends State<NotificationTemplatesPage> {
  late Future<List<Map<String, dynamic>>> _future =
      sl<ApiService>().notificationTemplates();

  void _reload() =>
      setState(() => _future = sl<ApiService>().notificationTemplates());

  static (Color, IconData) _channelStyle(BuildContext context, String channel) {
    switch (channel) {
      case 'PUSH':
        return (AppColors.studentAccent, Icons.notifications_active_rounded);
      case 'EMAIL':
        return (AppColors.parentAccent, Icons.email_outlined);
      case 'IN_APP':
        return (AppColors.teacherAccent, Icons.app_settings_alt_outlined);
      default:
        return (
          Theme.of(context).colorScheme.onSurfaceVariant,
          Icons.message_outlined
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mẫu thông báo'),
        backgroundColor: AppColors.adminAccent,
        actions: [
          IconButton(
              icon: const Icon(Icons.add_rounded),
              tooltip: 'Tạo mẫu thông báo',
              onPressed: () => _showEdit(
                    context,
                    const _Template(
                      id: null,
                      code: '',
                      name: '',
                      channel: 'IN_APP',
                      subject: '',
                      body: '',
                    ),
                  )),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(
                child: Text('Không thể tải mẫu thông báo.',
                    style: TextStyle(
                        color:
                            Theme.of(context).colorScheme.onSurfaceVariant)));
          }
          final templates = (snap.data ?? []).map(_Template.fromJson).toList();
          if (templates.isEmpty) {
            return Center(
                child: Text('Chưa có mẫu thông báo',
                    style: TextStyle(
                        color:
                            Theme.of(context).colorScheme.onSurfaceVariant)));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: templates.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) {
              final t = templates[i];
              final (color, icon) = _channelStyle(context, t.channel);
              return Card(
                margin: EdgeInsets.zero,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => _showEdit(context, t),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(icon, color: color, size: 18),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(t.name,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13)),
                                  Text(t.code,
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurfaceVariant)),
                                ],
                              ),
                            ),
                            Switch(
                              value: t.active,
                              onChanged: (active) => _save(t, active: active),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (t.channel == 'EMAIL' &&
                                  t.subject.isNotEmpty) ...[
                                Text(t.subject,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12)),
                                const SizedBox(height: 4),
                              ],
                              Text(t.body,
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                      height: 1.4)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          children: [
                            _Chip(label: t.channel, color: color),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _save(_Template template,
      {String? code,
      String? name,
      String? channel,
      String? subject,
      String? body,
      bool? active}) async {
    try {
      await sl<ApiService>().saveNotificationTemplate({
        if (template.id != null) 'id': template.id,
        'code': (code ?? template.code).trim(),
        'name': (name ?? template.name).trim(),
        'channel': channel ?? template.channel,
        'titleTemplate': (subject ?? template.subject).trim(),
        'bodyTemplate': (body ?? template.body).trim(),
        'active': active ?? template.active,
      });
      _reload();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã lưu mẫu thông báo')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không thể lưu mẫu thông báo. Vui lòng thử lại.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _showEdit(BuildContext context, _Template t) async {
    final code = TextEditingController(text: t.code);
    final name = TextEditingController(text: t.name);
    final subject = TextEditingController(text: t.subject);
    final body = TextEditingController(text: t.body);
    var channel = t.channel;
    final accepted = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, update) => Padding(
          padding: EdgeInsets.fromLTRB(
              20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t.id == null ? 'Tạo mẫu thông báo' : 'Sửa mẫu thông báo',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 16),
                TextField(
                  controller: code,
                  enabled: t.id == null,
                  decoration: const InputDecoration(labelText: 'Mã mẫu'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: name,
                  decoration: const InputDecoration(labelText: 'Tên mẫu'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: channel,
                  decoration: const InputDecoration(labelText: 'Kênh'),
                  items: const ['IN_APP', 'EMAIL', 'PUSH']
                      .map((value) =>
                          DropdownMenuItem(value: value, child: Text(value)))
                      .toList(),
                  onChanged: (value) =>
                      update(() => channel = value ?? 'IN_APP'),
                ),
                if (channel == 'EMAIL') ...[
                  const SizedBox(height: 12),
                  TextField(
                    controller: subject,
                    decoration: const InputDecoration(
                        labelText: 'Tiêu đề email', isDense: true),
                  ),
                ],
                const SizedBox(height: 12),
                TextField(
                  controller: body,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    labelText: 'Nội dung mẫu',
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Biến hỗ trợ: {{studentName}} {{parentName}} {{teacherName}} '
                  '{{period}} {{date}} {{score}} {{subject}} {{invoiceCode}} '
                  '{{totalAmount}} {{dueDate}}',
                  style: TextStyle(
                      fontSize: 10,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontStyle: FontStyle.italic),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton(
                        onPressed: () {
                          final valid = code.text.trim().isNotEmpty &&
                              name.text.trim().isNotEmpty &&
                              body.text.trim().isNotEmpty;
                          if (valid) Navigator.pop(ctx, true);
                        },
                        style: FilledButton.styleFrom(
                            backgroundColor: AppColors.adminAccent),
                        child: const Text('Lưu'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
    if (accepted == true) {
      await _save(t,
          code: code.text,
          name: name.text,
          channel: channel,
          subject: subject.text,
          body: body.text);
    }
    code.dispose();
    name.dispose();
    subject.dispose();
    body.dispose();
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 10, color: color, fontWeight: FontWeight.w600)),
    );
  }
}
