import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/session.dart';
import '../../core/widgets/async_state_view.dart';
import '../modules/module_hub_screen.dart';

class ChildDataScreen extends StatefulWidget {
  const ChildDataScreen({
    super.key,
    required this.module,
    required this.accent,
  });
  final AppModule module;
  final Color accent;

  @override
  State<ChildDataScreen> createState() => _ChildDataScreenState();
}

class _ChildDataScreenState extends State<ChildDataScreen> {
  late Future<List<Map<String, dynamic>>> future;

  @override
  void initState() {
    super.initState();
    future = load();
  }

  Map<String, dynamic>? get child {
    final session = context.read<AppSession>();
    for (final item in session.children) {
      if ('${item['id']}' == session.selectedChildId) return item;
    }
    return session.children.isEmpty ? null : session.children.first;
  }

  Future<List<Map<String, dynamic>>> load() async {
    final session = context.read<AppSession>();
    final selected = child;
    if (selected == null) return [];
    final id = '${selected['id']}';
    final endpoint = widget.module.endpoint;
    if (endpoint == '/me/assignments') {
      return session.api.list('/children/$id/assignments');
    }
    if (endpoint == '/me/timetable') {
      final classId = selected['classId'];
      if (classId == null) return [];
      return session.api.list('/timetableSlots', query: {'classId': classId});
    }
    if (endpoint == '/grades' || endpoint == '/attendance') {
      return session.api.list(endpoint, query: {'studentId': id});
    }
    if (endpoint == '/me/exam-agenda') {
      return session.api.list(endpoint, query: {'childId': id});
    }
    if (endpoint == '/invoices') {
      return session.api.list(endpoint, query: {'studentId': id});
    }
    return session.api.list(endpoint);
  }

  void reload() => setState(() => future = load());

  Future<void> select(String id) async {
    await context.read<AppSession>().selectChild(id);
    reload();
  }

  Future<void> pay(Map<String, dynamic> invoice) async {
    final api = context.read<AppSession>().api;
    try {
      final result = await api.post('/payments', {
        'invoiceId': invoice['id'],
        'method': 'MOMO',
      });
      final rawUrl = result['payUrl'] ?? result['deeplink'] ?? result['qrCodeUrl'];
      if (rawUrl != null) {
        final uri = Uri.tryParse('$rawUrl');
        if (uri != null) await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else if (result['callbackUrl'] != null &&
          result['sandboxCallback'] is Map) {
        await api.dio.post(
              '${result['callbackUrl']}',
              data: result['sandboxCallback'],
            );
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã khởi tạo giao dịch MoMo')),
      );
      reload();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Chưa thể khởi tạo thanh toán. Kiểm tra cấu hình MoMo.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<AppSession>();
    return Scaffold(
      appBar: AppBar(title: Text(widget.module.title)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: DropdownButtonFormField<String>(
              initialValue: session.selectedChildId,
              decoration: const InputDecoration(
                labelText: 'Học sinh đang theo dõi',
                prefixIcon: Icon(Icons.family_restroom),
              ),
              items: session.children
                  .map(
                    (item) => DropdownMenuItem(
                      value: '${item['id']}',
                      child: Text(
                        '${item['fullName'] ?? item['name']} · ${item['className'] ?? ''}',
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) select(value);
              },
            ),
          ),
          Expanded(
            child: AsyncStateView<List<Map<String, dynamic>>>(
              future: future,
              onRetry: reload,
              builder: (context, items) {
                if (items.isEmpty) {
                  return EmptyState(
                    title: 'Chưa có ${widget.module.title.toLowerCase()}',
                    message: 'Dữ liệu của học sinh đã chọn sẽ xuất hiện tại đây.',
                    icon: widget.module.icon,
                  );
                }
                return RefreshIndicator.adaptive(
                  onRefresh: () async {
                    reload();
                    await future;
                  },
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
                    itemCount: items.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final title = _title(item);
                      final status = '${item['status'] ?? ''}';
                      return Card(
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          leading: CircleAvatar(
                            backgroundColor: widget.accent.withValues(alpha: .1),
                            child: Icon(widget.module.icon, color: widget.accent),
                          ),
                          title: Text(title),
                          subtitle: Text(_subtitle(item)),
                          trailing: widget.module.endpoint == '/invoices' &&
                                  !const ['PAID', 'CANCELLED'].contains(status)
                              ? FilledButton(
                                  onPressed: () => pay(item),
                                  child: const Text('Thanh toán'),
                                )
                              : status.isEmpty
                                  ? null
                                  : Chip(label: Text(status)),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _title(Map<String, dynamic> item) =>
      '${item['title'] ?? item['subjectName'] ?? item['periodName'] ?? item['name'] ?? item['className'] ?? 'Thông tin'}';

  String _subtitle(Map<String, dynamic> item) {
    final values = [
      item['date'],
      item['deadline'],
      item['score'],
      item['amount'] == null ? null : '${item['amount']} đ',
      item['roomName'],
      item['description'],
    ].where((value) => value != null && '$value'.isNotEmpty);
    return values.take(3).join(' · ');
  }
}
