import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../app/session.dart';

class FinanceOverviewScreen extends StatefulWidget {
  const FinanceOverviewScreen({super.key, required this.accent});
  final Color accent;

  @override
  State<FinanceOverviewScreen> createState() => _FinanceOverviewScreenState();
}

class _FinanceOverviewScreenState extends State<FinanceOverviewScreen> {
  List<Map<String, dynamic>> periods = [];
  List<Map<String, dynamic>> classes = [];
  String? periodId;
  String grade = 'ALL';
  String status = 'ALL';
  bool loading = true;

  bool get isAdmin =>
      context.read<AppSession>().user?.role == 'ADMIN';

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    periods = await context.read<AppSession>().api.list('/fee-periods');
    periodId = periods.isEmpty ? null : '${periods.first['id']}';
    await _reload();
  }

  Future<void> _reload() async {
    setState(() => loading = true);
    try {
      final values = await context
          .read<AppSession>()
          .api
          .list('/finance/classes', query: {
            if (periodId != null) 'periodId': periodId,
            if (grade != 'ALL') 'gradeLevel': grade,
            if (status != 'ALL') 'status': status,
          });
      if (!mounted) return;
      setState(() {
        classes = values;
        loading = false;
      });
    } catch (error) {
      if (mounted) {
        setState(() => loading = false);
        _message('$error');
      }
    }
  }

  Future<void> _remind(Map<String, dynamic> item) async {
    final path = isAdmin
        ? '/finance/classes/${item['classId']}/remind-homeroom'
        : '/finance/homeroom/classes/${item['classId']}/remind';
    try {
      await context.read<AppSession>().api.dio.post(
        path,
        queryParameters: {if (periodId != null) 'periodId': periodId},
      );
      if (mounted) {
        _message(
          isAdmin
              ? 'Đã nhắc giáo viên chủ nhiệm.'
              : 'Đã nhắc phụ huynh còn công nợ.',
        );
        await _reload();
      }
    } catch (error) {
      if (mounted) _message('$error');
    }
  }

  Future<void> _notifyCompletion(Map<String, dynamic> item) async {
    try {
      await context.read<AppSession>().api.dio.post(
        '/finance/classes/${item['classId']}/notify-completion',
        queryParameters: {if (periodId != null) 'periodId': periodId},
      );
      if (mounted) {
        _message('Đã thông báo lớp hoàn thành nhiệm vụ tài chính.');
        await _reload();
      }
    } catch (error) {
      if (mounted) _message('$error');
    }
  }

  void _message(String value) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(value)));
  }

  String _money(num value) => NumberFormat.currency(
    locale: 'vi_VN',
    symbol: 'đ',
    decimalDigits: 0,
  ).format(value);

  @override
  Widget build(BuildContext context) {
    final total = classes.fold<num>(
      0,
      (sum, item) => sum + (item['totalAmount'] as num? ?? 0),
    );
    final paid = classes.fold<num>(
      0,
      (sum, item) => sum + (item['paidAmount'] as num? ?? 0),
    );
    return Scaffold(
      appBar: AppBar(
        title: Text(isAdmin ? 'Công nợ toàn trường' : 'Công nợ lớp chủ nhiệm'),
        actions: [
          IconButton(
            onPressed: _reload,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Column(
              children: [
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    SizedBox(
                      width: 290,
                      child: DropdownButtonFormField<String>(
                        initialValue: periodId,
                        decoration: const InputDecoration(
                          labelText: 'Khoản thu',
                          prefixIcon: Icon(Icons.payments_outlined),
                        ),
                        items: periods
                            .map(
                              (item) => DropdownMenuItem(
                                value: '${item['id']}',
                                child: Text('${item['name'] ?? item['code']}'),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          periodId = value;
                          _reload();
                        },
                      ),
                    ),
                    if (isAdmin)
                      SizedBox(
                        width: 180,
                        child: DropdownButtonFormField<String>(
                          initialValue: grade,
                          decoration:
                              const InputDecoration(labelText: 'Khối'),
                          items: const [
                            DropdownMenuItem(
                              value: 'ALL',
                              child: Text('Tất cả khối'),
                            ),
                            DropdownMenuItem(
                              value: 'K10',
                              child: Text('Khối 10'),
                            ),
                            DropdownMenuItem(
                              value: 'K11',
                              child: Text('Khối 11'),
                            ),
                            DropdownMenuItem(
                              value: 'K12',
                              child: Text('Khối 12'),
                            ),
                          ],
                          onChanged: (value) {
                            grade = value ?? 'ALL';
                            _reload();
                          },
                        ),
                      ),
                    SizedBox(
                      width: 210,
                      child: DropdownButtonFormField<String>(
                        initialValue: status,
                        decoration:
                            const InputDecoration(labelText: 'Trạng thái'),
                        items: const [
                          DropdownMenuItem(
                            value: 'ALL',
                            child: Text('Tất cả trạng thái'),
                          ),
                          DropdownMenuItem(
                            value: 'COMPLETED',
                            child: Text('Đã hoàn thành'),
                          ),
                          DropdownMenuItem(
                            value: 'INCOMPLETE',
                            child: Text('Chưa hoàn thành'),
                          ),
                          DropdownMenuItem(
                            value: 'OVERDUE',
                            child: Text('Có quá hạn'),
                          ),
                        ],
                        onChanged: (value) {
                          status = value ?? 'ALL';
                          _reload();
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Card(
                        color: widget.accent.withValues(alpha: .08),
                        child: ListTile(
                          title: const Text('Đã thu'),
                          subtitle: Text(_money(paid)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Card(
                        child: ListTile(
                          title: const Text('Còn phải thu'),
                          subtitle: Text(_money(total - paid)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : classes.isEmpty
                ? const Center(child: Text('Không có dữ liệu công nợ.'))
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                    itemCount: classes.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = classes[index];
                      final rate =
                          (item['collectionRate'] as num? ?? 0).toDouble();
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor:
                                        widget.accent.withValues(alpha: .1),
                                    child: Icon(
                                      Icons.school_outlined,
                                      color: widget.accent,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Lớp ${item['classCode']}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium,
                                        ),
                                        Text(
                                          'GVCN: ${item['homeroomTeacherName'] ?? 'chưa phân công'}',
                                        ),
                                      ],
                                    ),
                                  ),
                                  Chip(
                                    label: Text(
                                      item['completed'] == true
                                          ? 'Hoàn thành'
                                          : '${rate.toStringAsFixed(0)}%',
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              LinearProgressIndicator(
                                value: (rate / 100).clamp(0, 1),
                                minHeight: 8,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '${item['paidCount']}/${item['invoiceCount']} học sinh đã hoàn thành · Còn ${_money(item['outstanding'] as num? ?? 0)}',
                              ),
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  if (item['completed'] != true)
                                    FilledButton.tonalIcon(
                                      onPressed: () => _remind(item),
                                      icon: const Icon(
                                        Icons.notifications_active_outlined,
                                      ),
                                      label: Text(
                                        isAdmin
                                            ? 'Nhắc GVCN'
                                            : 'Nhắc phụ huynh',
                                      ),
                                    ),
                                  if (isAdmin &&
                                      item['completed'] == true &&
                                      item['completionNotified'] != true)
                                    OutlinedButton.icon(
                                      onPressed: () =>
                                          _notifyCompletion(item),
                                      icon: const Icon(Icons.verified_outlined),
                                      label: const Text(
                                        'Thông báo hoàn thành',
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
