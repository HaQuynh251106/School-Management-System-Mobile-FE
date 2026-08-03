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
  final search = TextEditingController();
  List<Map<String, dynamic>> periods = [];
  List<Map<String, dynamic>> classes = [];
  List<Map<String, dynamic>> invoices = [];
  String? periodId;
  String? classId;
  String grade = 'ALL';
  String status = 'ALL';
  bool loading = true;
  bool loadingInvoices = false;
  String? sendingId;

  bool get isAdmin => context.read<AppSession>().user?.role == 'ADMIN';

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    try {
      periods = await context.read<AppSession>().api.list('/fee-periods');
      final open = periods.where((item) => item['status'] == 'OPEN');
      periodId = open.isNotEmpty
          ? '${open.first['id']}'
          : periods.isEmpty
          ? null
          : '${periods.first['id']}';
      await _reload();
    } catch (error) {
      if (mounted) {
        setState(() => loading = false);
        _message('$error');
      }
    }
  }

  Future<void> _reload() async {
    setState(() => loading = true);
    try {
      final values = await context.read<AppSession>().api.list(
        '/finance/classes',
        query: {
          if (periodId != null) 'periodId': periodId,
          if (grade != 'ALL') 'gradeLevel': grade,
        },
      );
      if (!mounted) return;
      final nextClassId = values.any((item) => '${item['classId']}' == classId)
          ? classId
          : values.isEmpty
          ? null
          : '${values.first['classId']}';
      setState(() {
        classes = values;
        classId = nextClassId;
        loading = false;
      });
      await _loadInvoices();
    } catch (error) {
      if (mounted) {
        setState(() => loading = false);
        _message('$error');
      }
    }
  }

  Future<void> _loadInvoices() async {
    if (classId == null) {
      setState(() => invoices = []);
      return;
    }
    setState(() => loadingInvoices = true);
    try {
      final values = await context.read<AppSession>().api.list(
        '/invoices',
        query: {'classId': classId, if (periodId != null) 'periodId': periodId},
      );
      if (!mounted) return;
      setState(() {
        invoices = values;
        loadingInvoices = false;
      });
    } catch (error) {
      if (mounted) {
        setState(() => loadingInvoices = false);
        _message('$error');
      }
    }
  }

  Future<void> _selectClass(String value) async {
    setState(() => classId = value);
    await _loadInvoices();
  }

  Future<void> _remindClass(Map<String, dynamic> item) async {
    final path = isAdmin
        ? '/finance/classes/${item['classId']}/remind-homeroom'
        : '/finance/homeroom/classes/${item['classId']}/remind';
    setState(() => sendingId = 'class');
    try {
      final response = await context.read<AppSession>().api.dio.post(
        path,
        queryParameters: {if (periodId != null) 'periodId': periodId},
      );
      if (!mounted) return;
      final data = response.data is Map ? response.data as Map : const {};
      final recipients = data['recipientCount'];
      _message(
        isAdmin
            ? 'Đã gửi nhắc việc đến giáo viên chủ nhiệm.'
            : recipients == null
            ? 'Đã gửi nhắc phụ huynh còn công nợ.'
            : 'Đã gửi nhắc đến $recipients phụ huynh.',
      );
    } catch (error) {
      if (mounted) _message('$error');
    } finally {
      if (mounted) setState(() => sendingId = null);
    }
  }

  Future<void> _remindInvoice(Map<String, dynamic> invoice) async {
    setState(() => sendingId = '${invoice['id']}');
    try {
      final response = await context.read<AppSession>().api.dio.post(
        '/finance/homeroom/invoices/${invoice['id']}/remind',
      );
      if (!mounted) return;
      final data = response.data is Map ? response.data as Map : const {};
      _message(
        'Đã gửi nhắc đến ${data['recipientCount'] ?? 1} phụ huynh của ${invoice['studentName']}.',
      );
    } catch (error) {
      if (mounted) _message('$error');
    } finally {
      if (mounted) setState(() => sendingId = null);
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

  String _money(dynamic value) => NumberFormat.currency(
    locale: 'vi_VN',
    symbol: 'đ',
    decimalDigits: 0,
  ).format(value is num ? value : 0);

  bool _isOverdue(Map<String, dynamic> invoice) {
    if (invoice['status'] == 'PAID' || invoice['dueDate'] == null) return false;
    final due = DateTime.tryParse('${invoice['dueDate']}');
    return due != null &&
        due.isBefore(
          DateTime(
            DateTime.now().year,
            DateTime.now().month,
            DateTime.now().day,
          ),
        );
  }

  String _statusOf(Map<String, dynamic> invoice) =>
      _isOverdue(invoice) ? 'OVERDUE' : '${invoice['status'] ?? 'PENDING'}';

  List<Map<String, dynamic>> get _filteredInvoices {
    final query = search.text.trim().toLowerCase();
    return invoices.where((item) {
      final invoiceStatus = _statusOf(item);
      final matchesStatus = status == 'ALL' || invoiceStatus == status;
      final haystack =
          '${item['studentName'] ?? ''} ${item['parentName'] ?? ''} ${item['code'] ?? ''}'
              .toLowerCase();
      return matchesStatus && (query.isEmpty || haystack.contains(query));
    }).toList();
  }

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
    final overdueCount = classes.fold<num>(
      0,
      (sum, item) => sum + (item['overdueCount'] as num? ?? 0),
    );
    final selected = classes
        .where((item) => '${item['classId']}' == classId)
        .firstOrNull;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isAdmin ? 'Tài chính toàn trường' : 'Công nợ lớp chủ nhiệm',
        ),
        actions: [
          IconButton(
            tooltip: 'Đồng bộ dữ liệu',
            onPressed: _reload,
            icon: const Icon(Icons.sync_rounded),
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator.adaptive(
              onRefresh: _reload,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
                children: [
                  _FinanceHero(
                    accent: widget.accent,
                    isAdmin: isAdmin,
                    outstanding: total - paid,
                  ),
                  const SizedBox(height: 14),
                  _FilterPanel(
                    accent: widget.accent,
                    periods: periods,
                    periodId: periodId,
                    grade: grade,
                    showGrade: isAdmin,
                    onPeriod: (value) {
                      periodId = value;
                      _reload();
                    },
                    onGrade: (value) {
                      grade = value;
                      _reload();
                    },
                  ),
                  const SizedBox(height: 14),
                  _FinanceKpis(
                    accent: widget.accent,
                    paid: paid,
                    outstanding: total - paid,
                    completed: classes
                        .where((item) => item['completed'] == true)
                        .length,
                    overdue: overdueCount.toInt(),
                    money: _money,
                  ),
                  const SizedBox(height: 20),
                  _SectionHeading(
                    icon: Icons.school_rounded,
                    title: isAdmin
                        ? 'Tiến độ theo lớp'
                        : 'Lớp chủ nhiệm của bạn',
                    caption:
                        'Chọn lớp để xem chi tiết từng học sinh và phụ huynh',
                    accent: widget.accent,
                  ),
                  const SizedBox(height: 10),
                  if (classes.isEmpty)
                    _IllustratedEmpty(
                      title: 'Chưa có dữ liệu công nợ',
                      message: isAdmin
                          ? 'Hãy mở đợt thu và phát hành hóa đơn để bắt đầu theo dõi.'
                          : 'Chưa có hóa đơn nào được phát hành cho lớp bạn chủ nhiệm.',
                    )
                  else
                    SizedBox(
                      height: 142,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: classes.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 10),
                        itemBuilder: (_, index) {
                          final item = classes[index];
                          return _ClassFinanceCard(
                            item: item,
                            selected: '${item['classId']}' == classId,
                            accent: widget.accent,
                            money: _money,
                            onTap: () => _selectClass('${item['classId']}'),
                          );
                        },
                      ),
                    ),
                  if (selected != null) ...[
                    const SizedBox(height: 22),
                    _DebtHeader(
                      item: selected,
                      isAdmin: isAdmin,
                      accent: widget.accent,
                      money: _money,
                      sending: sendingId == 'class',
                      onRemind: () => _remindClass(selected),
                      onComplete: () => _notifyCompletion(selected),
                    ),
                    const SizedBox(height: 12),
                    _InvoiceFilters(
                      controller: search,
                      status: status,
                      accent: widget.accent,
                      onSearch: () => setState(() {}),
                      onStatus: (value) => setState(() => status = value),
                    ),
                    const SizedBox(height: 10),
                    if (loadingInvoices)
                      const Padding(
                        padding: EdgeInsets.all(38),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (_filteredInvoices.isEmpty)
                      const _IllustratedEmpty(
                        title: 'Không có hóa đơn phù hợp',
                        message:
                            'Thử thay đổi từ khóa hoặc trạng thái đang lọc.',
                        compact: true,
                      )
                    else
                      ..._filteredInvoices.map(
                        (invoice) => _InvoiceCard(
                          invoice: invoice,
                          status: _statusOf(invoice),
                          accent: widget.accent,
                          money: _money,
                          canRemind: !isAdmin,
                          sending: sendingId == '${invoice['id']}',
                          onRemind: () => _remindInvoice(invoice),
                        ),
                      ),
                  ],
                ],
              ),
            ),
    );
  }
}

class _FinanceHero extends StatelessWidget {
  const _FinanceHero({
    required this.accent,
    required this.isAdmin,
    required this.outstanding,
  });
  final Color accent;
  final bool isAdmin;
  final num outstanding;

  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(minHeight: 190),
    clipBehavior: Clip.antiAlias,
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [const Color(0xFF12345E), accent, const Color(0xFF079783)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(28),
      boxShadow: [
        BoxShadow(
          color: accent.withValues(alpha: .2),
          blurRadius: 28,
          offset: const Offset(0, 12),
        ),
      ],
    ),
    child: LayoutBuilder(
      builder: (context, constraints) {
        final showImage = constraints.maxWidth >= 600;
        return Row(
          children: [
            Expanded(
              flex: 6,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: .14),
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: const Text(
                        'KHÔNG GIAN TÀI CHÍNH MINH BẠCH',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: .4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      isAdmin
                          ? 'Nắm chắc công nợ,\nđiều hành chủ động'
                          : 'Đồng hành cùng\nphụ huynh trong lớp',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        height: 1.12,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      outstanding > 0
                          ? 'Theo dõi đúng người còn nợ và gửi nhắc hạn chỉ trong vài giây.'
                          : 'Mọi nghĩa vụ tài chính trong phạm vi của bạn đã hoàn thành.',
                      style: const TextStyle(
                        color: Colors.white70,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (showImage)
              Expanded(
                flex: 4,
                child: Image.asset(
                  'assets/illustrations/teacher-finance.png',
                  height: 210,
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                ),
              ),
          ],
        );
      },
    ),
  );
}

class _FilterPanel extends StatelessWidget {
  const _FilterPanel({
    required this.accent,
    required this.periods,
    required this.periodId,
    required this.grade,
    required this.showGrade,
    required this.onPeriod,
    required this.onGrade,
  });
  final Color accent;
  final List<Map<String, dynamic>> periods;
  final String? periodId;
  final String grade;
  final bool showGrade;
  final ValueChanged<String?> onPeriod;
  final ValueChanged<String> onGrade;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.tune_rounded, color: accent),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Phạm vi theo dõi',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                    Text(
                      'Chọn đợt thu và khối cần kiểm tra',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              SizedBox(
                width: 320,
                child: DropdownButtonFormField<String>(
                  initialValue: periodId,
                  decoration: const InputDecoration(
                    labelText: 'Đợt thu',
                    prefixIcon: Icon(Icons.receipt_long_rounded),
                  ),
                  items: periods
                      .map(
                        (item) => DropdownMenuItem(
                          value: '${item['id']}',
                          child: Text(
                            '${item['name'] ?? item['code']} · ${_periodStatus(item['status'])}',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: onPeriod,
                ),
              ),
              if (showGrade)
                SizedBox(
                  width: 190,
                  child: DropdownButtonFormField<String>(
                    initialValue: grade,
                    decoration: const InputDecoration(
                      labelText: 'Khối lớp',
                      prefixIcon: Icon(Icons.layers_rounded),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'ALL',
                        child: Text('Tất cả khối'),
                      ),
                      DropdownMenuItem(value: 'K10', child: Text('Khối 10')),
                      DropdownMenuItem(value: 'K11', child: Text('Khối 11')),
                      DropdownMenuItem(value: 'K12', child: Text('Khối 12')),
                    ],
                    onChanged: (value) => onGrade(value ?? 'ALL'),
                  ),
                ),
            ],
          ),
        ],
      ),
    ),
  );

  static String _periodStatus(dynamic value) => switch ('$value') {
    'OPEN' => 'Đang thu',
    'CLOSED' => 'Đã đóng',
    _ => 'Bản nháp',
  };
}

class _FinanceKpis extends StatelessWidget {
  const _FinanceKpis({
    required this.accent,
    required this.paid,
    required this.outstanding,
    required this.completed,
    required this.overdue,
    required this.money,
  });
  final Color accent;
  final num paid;
  final num outstanding;
  final int completed;
  final int overdue;
  final String Function(dynamic) money;

  @override
  Widget build(BuildContext context) {
    final items = [
      ('Đã thu', money(paid), Icons.trending_up_rounded, accent),
      (
        'Còn phải thu',
        money(outstanding),
        Icons.account_balance_wallet_rounded,
        const Color(0xFF7A5AF8),
      ),
      (
        'Lớp hoàn thành',
        '$completed',
        Icons.verified_rounded,
        const Color(0xFF079783),
      ),
      (
        'Hóa đơn quá hạn',
        '$overdue',
        Icons.warning_amber_rounded,
        const Color(0xFFE44C5E),
      ),
    ];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 310,
        mainAxisExtent: 112,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemBuilder: (_, index) {
        final item = items[index];
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(11),
                  decoration: BoxDecoration(
                    color: item.$4.withValues(alpha: .1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(item.$3, color: item.$4),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        item.$1,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.$2,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({
    required this.icon,
    required this.title,
    required this.caption,
    required this.accent,
  });
  final IconData icon;
  final String title;
  final String caption;
  final Color accent;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(
          color: accent.withValues(alpha: .1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: accent),
      ),
      const SizedBox(width: 10),
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

class _ClassFinanceCard extends StatelessWidget {
  const _ClassFinanceCard({
    required this.item,
    required this.selected,
    required this.accent,
    required this.money,
    required this.onTap,
  });
  final Map<String, dynamic> item;
  final bool selected;
  final Color accent;
  final String Function(dynamic) money;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final rate = (item['collectionRate'] as num? ?? 0).toDouble();
    return SizedBox(
      width: 280,
      child: Card(
        color: selected ? accent.withValues(alpha: .08) : null,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: selected ? accent : Theme.of(context).dividerColor,
            width: selected ? 1.6 : 1,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: accent.withValues(alpha: .12),
                      child: Icon(Icons.school_rounded, color: accent),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Lớp ${item['classCode']}',
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                          Text(
                            '${item['paidCount'] ?? 0}/${item['invoiceCount'] ?? 0} học sinh hoàn thành',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    if (selected)
                      Icon(Icons.check_circle_rounded, color: accent),
                  ],
                ),
                const Spacer(),
                LinearProgressIndicator(
                  value: (rate / 100).clamp(0, 1),
                  minHeight: 7,
                  borderRadius: BorderRadius.circular(99),
                  color: item['completed'] == true
                      ? const Color(0xFF079783)
                      : accent,
                ),
                const SizedBox(height: 7),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${rate.toStringAsFixed(0)}% đã thu',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      'Còn ${money(item['outstanding'])}',
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DebtHeader extends StatelessWidget {
  const _DebtHeader({
    required this.item,
    required this.isAdmin,
    required this.accent,
    required this.money,
    required this.sending,
    required this.onRemind,
    required this.onComplete,
  });
  final Map<String, dynamic> item;
  final bool isAdmin;
  final Color accent;
  final String Function(dynamic) money;
  final bool sending;
  final VoidCallback onRemind;
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 12,
        runSpacing: 12,
        children: [
          SizedBox(
            width: 420,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Chi tiết công nợ lớp ${item['classCode']}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  '${item['paidCount']}/${item['invoiceCount']} học sinh đã hoàn thành · Còn ${money(item['outstanding'])}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          if (item['completed'] == true)
            isAdmin && item['completionNotified'] != true
                ? OutlinedButton.icon(
                    onPressed: onComplete,
                    icon: const Icon(Icons.verified_outlined),
                    label: const Text('Báo hoàn thành'),
                  )
                : const Chip(
                    avatar: Icon(
                      Icons.check_circle_rounded,
                      color: Color(0xFF079783),
                    ),
                    label: Text('Đã hoàn thành'),
                  )
          else
            FilledButton.icon(
              onPressed: sending ? null : onRemind,
              icon: const Icon(Icons.notifications_active_rounded),
              label: Text(
                sending
                    ? 'Đang gửi...'
                    : isAdmin
                    ? 'Nhắc GVCN'
                    : 'Nhắc tất cả phụ huynh',
              ),
            ),
        ],
      ),
    ),
  );
}

class _InvoiceFilters extends StatelessWidget {
  const _InvoiceFilters({
    required this.controller,
    required this.status,
    required this.accent,
    required this.onSearch,
    required this.onStatus,
  });
  final TextEditingController controller;
  final String status;
  final Color accent;
  final VoidCallback onSearch;
  final ValueChanged<String> onStatus;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(13),
      child: Column(
        children: [
          TextField(
            controller: controller,
            onChanged: (_) => onSearch(),
            decoration: const InputDecoration(
              hintText: 'Tìm học sinh, phụ huynh hoặc mã hóa đơn',
              prefixIcon: Icon(Icons.search_rounded),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 38,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                for (final item in const [
                  ('ALL', 'Tất cả'),
                  ('PENDING', 'Chưa thanh toán'),
                  ('PARTIAL', 'Đã thu một phần'),
                  ('OVERDUE', 'Quá hạn'),
                  ('PAID', 'Đã thanh toán'),
                ])
                  Padding(
                    padding: const EdgeInsets.only(right: 7),
                    child: ChoiceChip(
                      selectedColor: accent.withValues(alpha: .16),
                      label: Text(item.$2),
                      selected: status == item.$1,
                      onSelected: (_) => onStatus(item.$1),
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

class _InvoiceCard extends StatelessWidget {
  const _InvoiceCard({
    required this.invoice,
    required this.status,
    required this.accent,
    required this.money,
    required this.canRemind,
    required this.sending,
    required this.onRemind,
  });
  final Map<String, dynamic> invoice;
  final String status;
  final Color accent;
  final String Function(dynamic) money;
  final bool canRemind;
  final bool sending;
  final VoidCallback onRemind;

  @override
  Widget build(BuildContext context) {
    final total = invoice['totalAmount'] as num? ?? 0;
    final paid = invoice['paidAmount'] as num? ?? 0;
    final dueDate = DateTime.tryParse('${invoice['dueDate'] ?? ''}');
    final statusInfo = switch (status) {
      'PAID' => (
        'Đã thanh toán',
        const Color(0xFF079783),
        Icons.check_circle_rounded,
      ),
      'PARTIAL' => (
        'Đã thu một phần',
        const Color(0xFF7A5AF8),
        Icons.timelapse_rounded,
      ),
      'OVERDUE' => (
        'Quá hạn',
        const Color(0xFFE44C5E),
        Icons.warning_amber_rounded,
      ),
      _ => ('Chưa thanh toán', const Color(0xFFF29A38), Icons.schedule_rounded),
    };
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: statusInfo.$2.withValues(alpha: .11),
                  child: Icon(statusInfo.$3, color: statusInfo.$2),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${invoice['studentName'] ?? 'Học sinh'}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.family_restroom_rounded, size: 15),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              'Phụ huynh: ${invoice['parentName'] ?? 'Chưa liên kết'}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                _StatusBadge(text: statusInfo.$1, color: statusInfo.$2),
              ],
            ),
            const SizedBox(height: 13),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _MoneyCell(label: 'Phải thu', value: money(total)),
                  ),
                  Expanded(
                    child: _MoneyCell(
                      label: 'Đã thu',
                      value: money(paid),
                      color: const Color(0xFF079783),
                    ),
                  ),
                  Expanded(
                    child: _MoneyCell(
                      label: 'Còn lại',
                      value: money(total - paid),
                      color: statusInfo.$2,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 11),
            Row(
              children: [
                Icon(Icons.receipt_long_outlined, size: 16, color: accent),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '${invoice['code'] ?? ''} · Hạn ${dueDate == null ? '—' : DateFormat('dd/MM/yyyy').format(dueDate)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                if (canRemind && status != 'PAID')
                  FilledButton.tonalIcon(
                    onPressed: sending ? null : onRemind,
                    icon: const Icon(
                      Icons.notifications_active_outlined,
                      size: 18,
                    ),
                    label: Text(sending ? 'Đang gửi' : 'Nhắc riêng'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MoneyCell extends StatelessWidget {
  const _MoneyCell({required this.label, required this.value, this.color});
  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: Theme.of(context).textTheme.bodySmall),
      const SizedBox(height: 3),
      Text(
        value,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontWeight: FontWeight.w900, color: color),
      ),
    ],
  );
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.text, required this.color});
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
    decoration: BoxDecoration(
      color: color.withValues(alpha: .1),
      borderRadius: BorderRadius.circular(99),
    ),
    child: Text(
      text,
      style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w800),
    ),
  );
}

class _IllustratedEmpty extends StatelessWidget {
  const _IllustratedEmpty({
    required this.title,
    required this.message,
    this.compact = false,
  });
  final String title;
  final String message;
  final bool compact;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: EdgeInsets.all(compact ? 16 : 22),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (!compact)
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Image.asset(
                'assets/illustrations/teacher-finance.png',
                width: 105,
                height: 105,
                fit: BoxFit.cover,
              ),
            ),
          if (!compact) const SizedBox(width: 16),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(message, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
