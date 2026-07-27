import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/session.dart';
import '../../core/widgets/async_state_view.dart';
import '../modules/create_record_sheet.dart';

class LeaveRequestsScreen extends StatefulWidget {
  const LeaveRequestsScreen({super.key, required this.accent});
  final Color accent;

  @override
  State<LeaveRequestsScreen> createState() => _LeaveRequestsScreenState();
}

class _LeaveRequestsScreenState extends State<LeaveRequestsScreen> {
  late Future<List<Map<String, dynamic>>> future;

  @override
  void initState() {
    super.initState();
    future = load();
  }

  Future<List<Map<String, dynamic>>> load() =>
      context.read<AppSession>().api.list('/leave-requests');

  void reload() => setState(() => future = load());

  Future<void> create() async {
    final changed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => CreateRecordSheet(kind: 'leave', accent: widget.accent),
    );
    if (changed == true) reload();
  }

  Future<void> decide(String id, String action) async {
    final note = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_actionLabel(action)),
        content: TextField(
          controller: note,
          maxLines: 3,
          decoration: const InputDecoration(labelText: 'Ghi chú (không bắt buộc)'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Đóng'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      await context.read<AppSession>().api.post(
        '/leave-requests/$id/$action',
        note.text.trim().isEmpty ? {} : {'note': note.text.trim()},
      );
      reload();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không thể xử lý đơn ở trạng thái hiện tại')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final role = context.watch<AppSession>().user!.role;
    return Scaffold(
      appBar: AppBar(title: const Text('Đơn xin nghỉ học')),
      floatingActionButton: role == 'STUDENT'
          ? FloatingActionButton.extended(
              onPressed: create,
              backgroundColor: widget.accent,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: const Text('Tạo đơn'),
            )
          : null,
      body: AsyncStateView<List<Map<String, dynamic>>>(
        future: future,
        onRetry: reload,
        builder: (context, items) {
          if (items.isEmpty) {
            return const EmptyState(
              title: 'Chưa có đơn xin nghỉ',
              message: 'Các đơn thuộc phạm vi của bạn sẽ xuất hiện tại đây.',
              icon: Icons.event_available_outlined,
            );
          }
          return RefreshIndicator.adaptive(
            onRefresh: () async {
              reload();
              await future;
            },
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
              itemCount: items.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final item = items[index];
                final actions = _actions(role, '${item['status']}');
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${item['studentName'] ?? 'Đơn xin nghỉ'}',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                            Chip(label: Text(_status('${item['status']}'))),
                          ],
                        ),
                        Text(
                          '${item['startDate']} → ${item['endDate']}',
                          style: TextStyle(
                            color: widget.accent,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text('${item['reason'] ?? ''}'),
                        if (actions.isNotEmpty) ...[
                          const SizedBox(height: 14),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: actions
                                .map(
                                  (action) => action.contains('reject') ||
                                          action == 'cancel'
                                      ? OutlinedButton(
                                          onPressed: () =>
                                              decide('${item['id']}', action),
                                          child: Text(_actionLabel(action)),
                                        )
                                      : FilledButton(
                                          onPressed: () =>
                                              decide('${item['id']}', action),
                                          child: Text(_actionLabel(action)),
                                        ),
                                )
                                .toList(),
                          ),
                        ],
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

  List<String> _actions(String role, String status) {
    if (role == 'PARENT' && status == 'PENDING_PARENT') {
      return const ['parent-confirm', 'parent-reject'];
    }
    if (role == 'TEACHER' && status == 'PENDING_HOMEROOM') {
      return const ['approve', 'reject'];
    }
    if (role == 'STUDENT' &&
        const ['PENDING_PARENT', 'PENDING_HOMEROOM'].contains(status)) {
      return const ['cancel'];
    }
    return const [];
  }

  String _actionLabel(String action) => switch (action) {
        'parent-confirm' => 'Phụ huynh xác nhận',
        'parent-reject' => 'Phụ huynh từ chối',
        'approve' => 'GVCN duyệt',
        'reject' => 'GVCN từ chối',
        'cancel' => 'Hủy đơn',
        _ => action,
      };

  String _status(String status) => switch (status) {
        'PENDING_PARENT' => 'Chờ phụ huynh',
        'PENDING_HOMEROOM' => 'Chờ GVCN',
        'APPROVED' => 'Đã duyệt',
        'REJECTED' => 'Từ chối',
        'CANCELLED' => 'Đã hủy',
        _ => status,
      };
}
