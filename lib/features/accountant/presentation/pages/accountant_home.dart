import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/adaptive_role_scaffold.dart';
import '../../../../shared/widgets/role_page_intro.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

class AccountantHome extends StatefulWidget {
  const AccountantHome({super.key});

  @override
  State<AccountantHome> createState() => _AccountantHomeState();
}

class _AccountantHomeState extends State<AccountantHome> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) => AdaptiveRoleScaffold(
        index: _tab,
        onSelected: (value) => setState(() => _tab = value),
        accent: AppColors.accountantAccent,
        pages: const [
          _FinanceOverviewPage(),
          _FeePeriodsPage(),
          _DebtPage(),
          _ReconciliationPage(),
          _AccountantProfilePage(),
        ],
        destinations: const [
          RoleDestination(
              icon: Icons.dashboard_outlined,
              selectedIcon: Icons.dashboard_rounded,
              label: 'Tổng quan'),
          RoleDestination(
              icon: Icons.campaign_outlined,
              selectedIcon: Icons.campaign_rounded,
              label: 'Đợt thu'),
          RoleDestination(
              icon: Icons.receipt_long_outlined,
              selectedIcon: Icons.receipt_long_rounded,
              label: 'Công nợ'),
          RoleDestination(
              icon: Icons.qr_code_scanner_outlined,
              selectedIcon: Icons.qr_code_scanner_rounded,
              label: 'Đối soát'),
          RoleDestination(
              icon: Icons.person_outline,
              selectedIcon: Icons.person_rounded,
              label: 'Tôi'),
        ],
      );
}

class _FinanceData {
  const _FinanceData(this.periods, this.invoices, this.pending);
  final List<Map<String, dynamic>> periods;
  final List<Map<String, dynamic>> invoices;
  final List<Map<String, dynamic>> pending;
}

Future<_FinanceData> _loadFinance() async {
  final api = sl<ApiService>();
  final values = await Future.wait(
      [api.feePeriods(), api.invoices(), api.pendingVietQrPayments()]);
  return _FinanceData(values[0], values[1], values[2]);
}

num _number(dynamic value) =>
    value is num ? value : num.tryParse(value?.toString() ?? '') ?? 0;
String _money(num amount) =>
    NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0)
        .format(amount);

class _FinanceOverviewPage extends StatelessWidget {
  const _FinanceOverviewPage();

  @override
  Widget build(BuildContext context) => _FinanceFuture<_FinanceData>(
        title: 'Tổng quan tài chính',
        load: _loadFinance,
        builder: (context, data, reload) {
          final total = data.invoices
              .fold<num>(0, (sum, item) => sum + _number(item['totalAmount']));
          final paid = data.invoices
              .fold<num>(0, (sum, item) => sum + _number(item['paidAmount']));
          final overdue =
              data.invoices.where((item) => item['status'] == 'OVERDUE').length;
          return RefreshIndicator(
            onRefresh: reload,
            child: ListView(padding: const EdgeInsets.all(16), children: [
              const RolePageIntro(
                title: 'Trung tâm Kế toán',
                subtitle:
                    'Quản lý đợt thu, công nợ và đối soát VietQR theo dữ liệu thời gian thực.',
                accent: AppColors.accountantAccent,
                icon: Icons.account_balance_wallet_rounded,
                badges: ['VietQR', 'Phân quyền độc lập'],
              ),
              GridView.count(
                crossAxisCount: MediaQuery.sizeOf(context).width >= 620 ? 4 : 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.3,
                children: [
                  _FinanceMetric('Tổng phải thu', _money(total),
                      Icons.request_quote_rounded),
                  _FinanceMetric('Đã thu', _money(paid), Icons.savings_rounded),
                  _FinanceMetric('Quá hạn', '$overdue hóa đơn',
                      Icons.warning_amber_rounded),
                  _FinanceMetric(
                      'Chờ đối soát',
                      '${data.pending.length} giao dịch',
                      Icons.qr_code_2_rounded),
                ],
              ),
              const SizedBox(height: 20),
              Text('Tình trạng cần ưu tiên',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Card(
                  child: ListTile(
                      leading: const CircleAvatar(
                          child: Icon(Icons.pending_actions_rounded)),
                      title: Text(
                          '${data.pending.length} giao dịch VietQR đang chờ'),
                      subtitle: const Text(
                          'Kiểm tra nội dung chuyển khoản trước khi xác nhận.'))),
              Card(
                  child: ListTile(
                      leading: const CircleAvatar(
                          child: Icon(Icons.notifications_active_outlined)),
                      title: Text('$overdue hóa đơn quá hạn'),
                      subtitle: const Text(
                          'Lọc theo trạng thái trong mục Công nợ để xử lý.'))),
            ]),
          );
        },
      );
}

class _FeePeriodsPage extends StatelessWidget {
  const _FeePeriodsPage();

  @override
  Widget build(BuildContext context) =>
      _FinanceFuture<List<Map<String, dynamic>>>(
        title: 'Đợt thu',
        load: sl<ApiService>().feePeriods,
        builder: (context, periods, reload) => RefreshIndicator(
          onRefresh: reload,
          child: ListView(padding: const EdgeInsets.all(16), children: [
            const RolePageIntro(
                title: 'Quản lý đợt thu',
                subtitle:
                    'Kiểm tra trạng thái trước khi sinh hóa đơn cho học sinh.',
                accent: AppColors.accountantAccent,
                icon: Icons.campaign_rounded),
            if (periods.isEmpty)
              const Center(
                  child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Text('Chưa có đợt thu'))),
            ...periods.map((period) => Card(
                    child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Expanded(
                              child: Text(
                                  (period['name'] ?? period['code'] ?? '')
                                      .toString(),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w800))),
                          _FinanceStatus((period['status'] ?? '').toString())
                        ]),
                        const SizedBox(height: 6),
                        Text('Hạn nộp: ${period['dueDate'] ?? 'chưa đặt'}'),
                        if (period['status'] == 'OPEN') ...[
                          const SizedBox(height: 10),
                          Align(
                              alignment: Alignment.centerRight,
                              child: FilledButton.tonalIcon(
                                onPressed: () async {
                                  final invoices = await sl<ApiService>()
                                      .generateInvoices(
                                          period['id'].toString());
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                'Đã đồng bộ ${invoices.length} hóa đơn')));
                                  }
                                },
                                icon: const Icon(Icons.receipt_long_rounded),
                                label: const Text('Sinh/đồng bộ hóa đơn'),
                              )),
                        ],
                      ]),
                ))),
          ]),
        ),
      );
}

class _DebtPage extends StatefulWidget {
  const _DebtPage();
  @override
  State<_DebtPage> createState() => _DebtPageState();
}

class _DebtPageState extends State<_DebtPage> {
  String _status = 'ALL';
  String _query = '';
  late Future<List<Map<String, dynamic>>> _future = _load();

  Future<List<Map<String, dynamic>>> _load() => sl<ApiService>().invoices(
      status: _status == 'ALL' ? null : _status,
      query: _query.trim().isEmpty ? null : _query.trim());
  void _reload() => setState(() => _future = _load());

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Hóa đơn và công nợ')),
        body: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Column(children: [
              TextField(
                  decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      labelText: 'Tìm học sinh hoặc mã hóa đơn'),
                  onChanged: (value) => _query = value,
                  onSubmitted: (_) => _reload()),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: _status,
                decoration:
                    const InputDecoration(labelText: 'Trạng thái công nợ'),
                items: const [
                  DropdownMenuItem(
                      value: 'ALL', child: Text('Tất cả trạng thái')),
                  DropdownMenuItem(
                      value: 'ISSUED', child: Text('Chưa thanh toán')),
                  DropdownMenuItem(value: 'OVERDUE', child: Text('Quá hạn')),
                  DropdownMenuItem(value: 'PAID', child: Text('Đã thanh toán')),
                ],
                onChanged: (value) {
                  _status = value ?? 'ALL';
                  _reload();
                },
              ),
            ]),
          ),
          Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: _future,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final invoices = snapshot.data!;
                    if (invoices.isEmpty) {
                      return const Center(
                          child: Text('Không có hóa đơn phù hợp bộ lọc'));
                    }
                    return RefreshIndicator(
                        onRefresh: () async => _reload(),
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                          itemCount: invoices.length,
                          itemBuilder: (context, index) {
                            final invoice = invoices[index];
                            final total = _number(invoice['totalAmount']);
                            final paid = _number(invoice['paidAmount']);
                            return Card(
                                child: ListTile(
                              leading: CircleAvatar(
                                  child: Text((invoice['classCode'] ?? '?')
                                      .toString()
                                      .replaceAll('Lớp ', ''))),
                              title: Text((invoice['studentName'] ??
                                      invoice['code'] ??
                                      '')
                                  .toString()),
                              subtitle: Text(
                                  '${invoice['code'] ?? ''} • Còn ${_money(total - paid)}'),
                              trailing: _FinanceStatus(
                                  (invoice['status'] ?? '').toString()),
                            ));
                          },
                        ));
                  })),
        ]),
      );
}

class _ReconciliationPage extends StatefulWidget {
  const _ReconciliationPage();
  @override
  State<_ReconciliationPage> createState() => _ReconciliationPageState();
}

class _ReconciliationPageState extends State<_ReconciliationPage> {
  late Future<List<Map<String, dynamic>>> _future =
      sl<ApiService>().pendingVietQrPayments();
  void _reload() =>
      setState(() => _future = sl<ApiService>().pendingVietQrPayments());

  Future<void> _confirm(String paymentId) async {
    final controller = TextEditingController();
    final reference = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text('Xác nhận giao dịch VietQR'),
              content: TextField(
                  controller: controller,
                  autofocus: true,
                  decoration: const InputDecoration(
                      labelText: 'Mã giao dịch ngân hàng')),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Hủy')),
                FilledButton(
                    onPressed: () =>
                        Navigator.pop(context, controller.text.trim()),
                    child: const Text('Xác nhận đã nhận'))
              ],
            ));
    if (reference == null || reference.isEmpty) return;
    await sl<ApiService>().confirmVietQrPayment(paymentId, reference);
    _reload();
  }

  Future<void> _reject(String paymentId) async {
    await sl<ApiService>().rejectVietQrPayment(paymentId);
    _reload();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Đối soát VietQR')),
        body: FutureBuilder<List<Map<String, dynamic>>>(
            future: _future,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final items = snapshot.data!;
              return RefreshIndicator(
                  onRefresh: () async => _reload(),
                  child: ListView(padding: const EdgeInsets.all(16), children: [
                    const RolePageIntro(
                        title: 'Giao dịch chờ đối soát',
                        subtitle:
                            'Chỉ xác nhận sau khi tiền đã xuất hiện trên tài khoản ngân hàng.',
                        accent: AppColors.accountantAccent,
                        icon: Icons.qr_code_scanner_rounded),
                    if (items.isEmpty)
                      const Center(
                          child: Padding(
                              padding: EdgeInsets.all(32),
                              child: Text('Không có giao dịch chờ đối soát'))),
                    ...items.map((raw) {
                      final payment = raw['payment'] is Map
                          ? (raw['payment'] as Map).cast<String, dynamic>()
                          : raw;
                      final invoice = raw['invoice'] is Map
                          ? (raw['invoice'] as Map).cast<String, dynamic>()
                          : <String, dynamic>{};
                      final id =
                          (payment['id'] ?? raw['paymentId'] ?? '').toString();
                      return Card(
                          child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(children: [
                                      const Icon(Icons.qr_code_2_rounded,
                                          color: AppColors.accountantAccent),
                                      const SizedBox(width: 8),
                                      Expanded(
                                          child: Text(
                                              (invoice['studentName'] ??
                                                      payment['payerName'] ??
                                                      'Giao dịch VietQR')
                                                  .toString(),
                                              style: const TextStyle(
                                                  fontWeight:
                                                      FontWeight.w800))),
                                      Text(_money(_number(payment['amount'])))
                                    ]),
                                    const SizedBox(height: 6),
                                    Text(
                                        'Nội dung: ${raw['transferContent'] ?? payment['txnRef'] ?? ''}'),
                                    const SizedBox(height: 12),
                                    Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          OutlinedButton(
                                              onPressed: id.isEmpty
                                                  ? null
                                                  : () => _reject(id),
                                              child: const Text('Từ chối')),
                                          const SizedBox(width: 8),
                                          FilledButton(
                                              onPressed: id.isEmpty
                                                  ? null
                                                  : () => _confirm(id),
                                              child: const Text('Xác nhận'))
                                        ]),
                                  ])));
                    }),
                  ]));
            }),
      );
}

class _AccountantProfilePage extends StatelessWidget {
  const _AccountantProfilePage();
  @override
  Widget build(BuildContext context) {
    final state = context.watch<AuthBloc>().state;
    final user = state is AuthAuthenticated ? state.user : null;
    return Scaffold(
        appBar: AppBar(title: const Text('Tài khoản Kế toán')),
        body: ListView(padding: const EdgeInsets.all(16), children: [
          const RolePageIntro(
              title: 'Hồ sơ công việc',
              subtitle: 'Tài khoản chuyên trách tài chính và đối soát.',
              accent: AppColors.accountantAccent,
              icon: Icons.badge_rounded),
          Card(
              child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: Text(user?.fullName ?? ''),
                  subtitle: Text('@${user?.username ?? ''}'))),
          Card(
            child: ListTile(
              leading: const Icon(Icons.logout_rounded, color: AppColors.error),
              title: const Text('Đăng xuất'),
              onTap: () =>
                  context.read<AuthBloc>().add(const AuthLogoutRequested()),
            ),
          ),
        ]));
  }
}

class _FinanceFuture<T> extends StatefulWidget {
  const _FinanceFuture(
      {required this.title, required this.load, required this.builder});
  final String title;
  final Future<T> Function() load;
  final Widget Function(BuildContext, T, Future<void> Function()) builder;
  @override
  State<_FinanceFuture<T>> createState() => _FinanceFutureState<T>();
}

class _FinanceFutureState<T> extends State<_FinanceFuture<T>> {
  late Future<T> _future = widget.load();
  Future<void> _reload() async {
    setState(() => _future = widget.load());
    await _future;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: FutureBuilder<T>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                  child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        Text('Không thể tải dữ liệu: ${snapshot.error}',
                            textAlign: TextAlign.center),
                        const SizedBox(height: 12),
                        FilledButton.tonal(
                            onPressed: _reload, child: const Text('Thử lại'))
                      ])));
            }
            return widget.builder(context, snapshot.data as T, _reload);
          }));
}

class _FinanceMetric extends StatelessWidget {
  const _FinanceMetric(this.label, this.value, this.icon);
  final String label;
  final String value;
  final IconData icon;
  @override
  Widget build(BuildContext context) => Card(
      child: Padding(
          padding: const EdgeInsets.all(14),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(icon, color: AppColors.accountantAccent),
            const Spacer(),
            Text(value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w800)),
            Text(label, maxLines: 1)
          ])));
}

class _FinanceStatus extends StatelessWidget {
  const _FinanceStatus(this.status);
  final String status;
  @override
  Widget build(BuildContext context) {
    final label = switch (status) {
      'PAID' => 'Đã thu',
      'OVERDUE' => 'Quá hạn',
      'ISSUED' => 'Chưa thu',
      'OPEN' => 'Đang mở',
      'DRAFT' => 'Bản nháp',
      'COMPLETED' => 'Hoàn tất',
      _ => status
    };
    final color = switch (status) {
      'PAID' || 'COMPLETED' => AppColors.success,
      'OVERDUE' => AppColors.error,
      'OPEN' => AppColors.accountantAccent,
      _ => AppColors.warning
    };
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(
            color: color.withValues(alpha: .1),
            borderRadius: BorderRadius.circular(99)),
        child: Text(label,
            style: TextStyle(
                color: color, fontSize: 11, fontWeight: FontWeight.w800)));
  }
}
