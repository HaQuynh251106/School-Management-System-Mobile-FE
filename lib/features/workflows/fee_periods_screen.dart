import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../app/session.dart';
import '../modules/create_record_sheet.dart';

class FeePeriodsScreen extends StatefulWidget {
  const FeePeriodsScreen({super.key, required this.accent});
  final Color accent;

  @override
  State<FeePeriodsScreen> createState() => _FeePeriodsScreenState();
}

class _FeePeriodsScreenState extends State<FeePeriodsScreen> {
  late Future<List<Map<String, dynamic>>> future;

  @override
  void initState() {
    super.initState();
    future = _load();
  }

  Future<List<Map<String, dynamic>>> _load() =>
      context.read<AppSession>().api.list('/fee-periods');

  void _reload() => setState(() => future = _load());

  Future<void> _create() async {
    final changed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => CreateRecordSheet(kind: 'fee', accent: widget.accent),
    );
    if (changed == true) _reload();
  }

  Future<void> _action(String path, String success) async {
    try {
      await context.read<AppSession>().api.dio.post(path);
      if (!mounted) return;
      _message(success);
      _reload();
    } catch (error) {
      if (mounted) _message(_friendly(error));
    }
  }

  Future<void> _delete(Map<String, dynamic> period) async {
    final accepted = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa đợt thu?'),
        content: const Text(
          'Chỉ đợt thu bản nháp chưa phát sinh hóa đơn mới có thể xóa.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
    if (accepted != true || !mounted) return;
    try {
      await context
          .read<AppSession>()
          .api
          .delete('/fee-periods/${period['id']}');
      if (mounted) _reload();
    } catch (error) {
      if (mounted) _message(_friendly(error));
    }
  }

  Future<void> _details(Map<String, dynamic> period) async {
    final items = await context
        .read<AppSession>()
        .api
        .list('/fee-periods/${period['id']}/items');
    if (!mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${period['name']}',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 4),
              Text(
                'Mã ${period['code']} · Hạn ${period['dueDate'] ?? 'chưa đặt'}',
              ),
              const SizedBox(height: 16),
              Text(
                'Các khoản thu',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              if (items.isEmpty)
                const Text('Chưa có khoản thu chi tiết.')
              else
                ...items.map(
                  (item) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.payments_outlined),
                    title: Text('${item['name']}'),
                    subtitle: Text(
                      item['gradeLevel'] == null
                          ? 'Áp dụng toàn trường'
                          : 'Khối ${item['gradeLevel']}',
                    ),
                    trailing: Text(
                      NumberFormat.currency(
                        locale: 'vi_VN',
                        symbol: 'đ',
                        decimalDigits: 0,
                      ).format(item['amount'] ?? 0),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _friendly(Object error) {
    final value = '$error';
    if (value.contains('409')) {
      return 'Trạng thái hiện tại chưa cho phép thao tác này.';
    }
    if (value.contains('400')) {
      return 'Đợt thu cần có ít nhất một khoản thu hợp lệ.';
    }
    return 'Không thể xử lý đợt thu. Vui lòng thử lại.';
  }

  void _message(String value) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(value)));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Quản lý khoản thu'),
      actions: [
        IconButton(onPressed: _reload, icon: const Icon(Icons.refresh_rounded)),
      ],
    ),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: _create,
      backgroundColor: widget.accent,
      foregroundColor: Colors.white,
      icon: const Icon(Icons.add_rounded),
      label: const Text('Tạo đợt thu'),
    ),
    body: FutureBuilder<List<Map<String, dynamic>>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('${snapshot.error}'));
        }
        final items = snapshot.data ?? [];
        if (items.isEmpty) {
          return const Center(child: Text('Chưa có đợt thu.'));
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
          itemCount: items.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final item = items[index];
            final status = '${item['status'] ?? 'DRAFT'}';
            return Card(
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () => _details(item),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor:
                                widget.accent.withValues(alpha: .1),
                            child: Icon(
                              Icons.account_balance_wallet_outlined,
                              color: widget.accent,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${item['name'] ?? item['code']}',
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                ),
                                Text(
                                  '${item['code']} · Hạn ${item['dueDate'] ?? 'chưa đặt'} · Khối ${item['applyToGrades'] ?? 'toàn trường'}',
                                ),
                              ],
                            ),
                          ),
                          Chip(
                            label: Text(
                              switch (status) {
                                'OPEN' => 'Đang thu',
                                'CLOSED' => 'Đã kết thúc',
                                _ => 'Bản nháp',
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          OutlinedButton.icon(
                            onPressed: () => _details(item),
                            icon: const Icon(Icons.visibility_outlined),
                            label: const Text('Chi tiết'),
                          ),
                          if (status == 'DRAFT')
                            FilledButton.tonalIcon(
                              onPressed: () => _action(
                                '/fee-periods/${item['id']}/open',
                                'Đã mở đợt thu.',
                              ),
                              icon: const Icon(Icons.lock_open_rounded),
                              label: const Text('Mở đợt'),
                            ),
                          if (status == 'OPEN')
                            FilledButton.icon(
                              onPressed: () => _action(
                                '/fee-periods/${item['id']}/generate-invoices',
                                'Đã phát hành hóa đơn đến phụ huynh.',
                              ),
                              icon: const Icon(Icons.send_rounded),
                              label: const Text('Phát hành hóa đơn'),
                            ),
                          if (status == 'OPEN')
                            OutlinedButton.icon(
                              onPressed: () => _action(
                                '/fee-periods/${item['id']}/close',
                                'Đã kết thúc đợt thu.',
                              ),
                              icon: const Icon(Icons.task_alt_rounded),
                              label: const Text('Kết thúc'),
                            ),
                          if (status == 'DRAFT')
                            IconButton(
                              tooltip: 'Xóa đợt thu',
                              onPressed: () => _delete(item),
                              icon: const Icon(Icons.delete_outline),
                            ),
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
