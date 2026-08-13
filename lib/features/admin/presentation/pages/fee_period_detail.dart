import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/network/realtime_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/section_header.dart';

/// Chi tiết một đợt thu. Tất cả số liệu trên màn hình được tổng hợp từ các
/// hóa đơn thật của chính đợt thu, không dùng số mẫu ở phía mobile.
class AdminFeePeriodDetail extends StatefulWidget {
  const AdminFeePeriodDetail({
    super.key,
    required this.periodId,
    required this.code,
    required this.title,
    required this.status,
    this.dueDate,
  });

  final String periodId;
  final String code;
  final String title;
  final String status;
  final String? dueDate;

  @override
  State<AdminFeePeriodDetail> createState() => _AdminFeePeriodDetailState();
}

class _AdminFeePeriodDetailState extends State<AdminFeePeriodDetail>
    with WidgetsBindingObserver {
  late Future<List<Map<String, dynamic>>> _future = _load();
  StreamSubscription<RealtimeEvent>? _paymentEvents;
  Timer? _reloadDebounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final realtime = sl<RealtimeService>()..connect();
    _paymentEvents = realtime.events
        .where((event) => event.type == 'PAYMENT_STATUS_UPDATED')
        .listen((_) {
      _reloadDebounce?.cancel();
      _reloadDebounce = Timer(const Duration(milliseconds: 250), () {
        if (mounted) _refresh();
      });
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) _refresh();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _reloadDebounce?.cancel();
    _paymentEvents?.cancel();
    super.dispose();
  }

  Future<List<Map<String, dynamic>>> _load() =>
      sl<ApiService>().invoices(feePeriodId: widget.periodId);

  Future<void> _refresh() async {
    final future = _load();
    setState(() => _future = future);
    await future;
  }

  num _number(Object? value) =>
      value is num ? value : num.tryParse(value?.toString() ?? '') ?? 0;

  String _money(num amount) =>
      '${NumberFormat.decimalPattern('vi_VN').format(amount)} ₫';

  bool _paid(Map<String, dynamic> invoice) {
    final status = (invoice['status'] ?? '').toString().toUpperCase();
    return status == 'PAID' ||
        _number(invoice['paidAmount']) >= _number(invoice['totalAmount']);
  }

  @override
  Widget build(BuildContext context) {
    final isOpen = widget.status.toUpperCase() == 'OPEN';
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết đợt thu'),
        backgroundColor: AppColors.adminAccent,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: FilledButton.icon(
                onPressed: _refresh,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Tải lại dữ liệu đợt thu'),
              ),
            );
          }

          final invoices = snapshot.data ?? const <Map<String, dynamic>>[];
          final paidCount = invoices.where(_paid).length;
          final totalAmount = invoices.fold<num>(
              0, (sum, item) => sum + _number(item['totalAmount']));
          final paidAmount = invoices.fold<num>(
              0, (sum, item) => sum + _number(item['paidAmount']));
          final unpaid = invoices.where((item) => !_paid(item)).toList();
          final progress = totalAmount <= 0
              ? 0.0
              : (paidAmount / totalAmount).clamp(0, 1).toDouble();

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.adminAccent.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: AppColors.adminAccent.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        _StatusBadge(
                            status: widget.status,
                            color: isOpen
                                ? AppColors.success
                                : Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant),
                        const Spacer(),
                        Text(widget.code,
                            style: TextStyle(
                                fontSize: 11,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant)),
                      ]),
                      const SizedBox(height: 10),
                      Text(widget.title,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      if (widget.dueDate != null &&
                          widget.dueDate!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text('Hạn nộp: ${widget.dueDate}',
                            style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant)),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const SectionHeader(title: 'Tổng quan công nợ'),
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(
                    child: _StatBox(
                      label: 'Đã thanh toán',
                      value: '$paidCount/${invoices.length}',
                      color: AppColors.success,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _StatBox(
                      label: 'Chưa thanh toán',
                      value: '${unpaid.length}',
                      color: AppColors.warning,
                    ),
                  ),
                ]),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Tổng tiền đã phát hành',
                            style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant)),
                        Text(_money(totalAmount),
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.adminAccent)),
                        const SizedBox(height: 12),
                        LinearProgressIndicator(
                          value: progress,
                          color: AppColors.success,
                          backgroundColor:
                              Theme.of(context).colorScheme.outlineVariant,
                          minHeight: 10,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        const SizedBox(height: 8),
                        Row(children: [
                          Text('Đã thu: ${_money(paidAmount)}',
                              style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.success)),
                          const Spacer(),
                          Text('Còn lại: ${_money(totalAmount - paidAmount)}',
                              style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.warning)),
                        ]),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SectionHeader(
                    title: 'Hóa đơn chưa thanh toán (${unpaid.length})'),
                const SizedBox(height: 8),
                if (unpaid.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Center(
                          child: Text('Không có hóa đơn chưa thanh toán')),
                    ),
                  )
                else
                  ...unpaid.map((invoice) {
                    final total = _number(invoice['totalAmount']);
                    final paid = _number(invoice['paidAmount']);
                    return Card(
                      child: ListTile(
                        leading: const CircleAvatar(
                          child: Icon(Icons.receipt_long_outlined),
                        ),
                        title: Text((invoice['studentName'] ??
                                invoice['code'] ??
                                'Hóa đơn')
                            .toString()),
                        subtitle: Text(
                            '${invoice['classCode'] ?? ''} • ${invoice['code'] ?? ''}'),
                        trailing: Text(_money(total - paid),
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.warning)),
                      ),
                    );
                  }),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status, required this.color});
  final String status;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(status,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold)),
      );
}

class _StatBox extends StatelessWidget {
  const _StatBox({
    required this.label,
    required this.value,
    required this.color,
  });
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label,
              style: TextStyle(
                  fontSize: 11,
                  color: Theme.of(context).colorScheme.onSurfaceVariant)),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 18, color: color)),
        ]),
      );
}
