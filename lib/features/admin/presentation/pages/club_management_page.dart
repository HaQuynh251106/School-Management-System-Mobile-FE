import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/theme/app_colors.dart';

class ClubManagementPage extends StatefulWidget {
  const ClubManagementPage({super.key});

  @override
  State<ClubManagementPage> createState() => _ClubManagementPageState();
}

class _ClubManagementPageState extends State<ClubManagementPage> {
  late Future<_AdminClubData> _future = _load();
  String _registrationFilter = 'ALL';
  String? _busyRegistrationId;

  Future<_AdminClubData> _load() async {
    final api = sl<ApiService>();
    final values = await Future.wait([
      api.clubs(),
      api.adminClubRegistrations(),
    ]);
    return _AdminClubData(values[0], values[1]);
  }

  Future<void> _reload() async {
    setState(() {
      _future = _load();
    });
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Quản lý câu lạc bộ'),
          backgroundColor: AppColors.adminAccent,
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'Câu lạc bộ'),
              Tab(text: 'Đăng ký'),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _showCreateClub,
          backgroundColor: AppColors.adminAccent,
          icon: const Icon(Icons.add_rounded),
          label: const Text('Tạo CLB'),
        ),
        body: FutureBuilder<_AdminClubData>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return _ErrorState(
                message: _errorMessage(snapshot.error),
                onRetry: _reload,
              );
            }
            final data = snapshot.data!;
            return TabBarView(
              children: [
                _clubsView(data.clubs),
                _registrationsView(data.registrations),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _clubsView(List<Map<String, dynamic>> clubs) {
    if (clubs.isEmpty) {
      return _EmptyState(
        icon: Icons.groups_outlined,
        message: 'Chưa có câu lạc bộ',
        onRefresh: _reload,
      );
    }
    return RefreshIndicator(
      onRefresh: _reload,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        itemCount: clubs.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, index) => _AdminClubCard(club: clubs[index]),
      ),
    );
  }

  Widget _registrationsView(List<Map<String, dynamic>> registrations) {
    final visible = registrations
        .where(
          (item) =>
              _registrationFilter == 'ALL' ||
              item['status']?.toString() == _registrationFilter,
        )
        .toList();
    return RefreshIndicator(
      onRefresh: _reload,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
        children: [
          DropdownButtonFormField<String>(
            initialValue: _registrationFilter,
            decoration: const InputDecoration(
              labelText: 'Trạng thái đăng ký',
              prefixIcon: Icon(Icons.filter_list_rounded),
            ),
            items: const [
              DropdownMenuItem(value: 'ALL', child: Text('Tất cả')),
              DropdownMenuItem(value: 'PENDING', child: Text('Chờ duyệt')),
              DropdownMenuItem(value: 'WAITLIST', child: Text('Danh sách chờ')),
              DropdownMenuItem(value: 'APPROVED', child: Text('Đã duyệt')),
              DropdownMenuItem(value: 'REJECTED', child: Text('Từ chối')),
              DropdownMenuItem(value: 'CANCELLED', child: Text('Đã hủy')),
            ],
            onChanged: (value) =>
                setState(() => _registrationFilter = value ?? 'ALL'),
          ),
          const SizedBox(height: 12),
          if (visible.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 96),
              child: Column(
                children: [
                  Icon(
                    Icons.inbox_outlined,
                    size: 48,
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(height: 10),
                  Text('Không có đăng ký phù hợp'),
                ],
              ),
            )
          else
            ...visible.expand(
              (registration) => [
                _RegistrationRow(
                  registration: registration,
                  busy: _busyRegistrationId == registration['id'],
                  onApprove: () => _decide(registration, approve: true),
                  onReject: () => _decide(registration, approve: false),
                ),
                const Divider(height: 1),
              ],
            ),
        ],
      ),
    );
  }

  Future<void> _decide(
    Map<String, dynamic> registration, {
    required bool approve,
  }) async {
    final id = registration['id'].toString();
    final noteController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(approve ? 'Duyệt đăng ký?' : 'Từ chối đăng ký?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${registration['studentName']} · ${registration['clubName']}',
            ),
            const SizedBox(height: 12),
            TextField(
              controller: noteController,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: approve ? 'Ghi chú duyệt' : 'Lý do từ chối',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Đóng'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: approve
                ? null
                : FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: Text(approve ? 'Duyệt' : 'Từ chối'),
          ),
        ],
      ),
    );
    if (confirmed != true) {
      noteController.dispose();
      return;
    }
    final note = noteController.text.trim();
    noteController.dispose();
    setState(() => _busyRegistrationId = id);
    try {
      final api = sl<ApiService>();
      if (approve) {
        await api.approveClubRegistration(id, note: note.isEmpty ? null : note);
      } else {
        await api.rejectClubRegistration(id, note: note.isEmpty ? null : note);
      }
      if (!mounted) return;
      _message(approve ? 'Đã duyệt đăng ký' : 'Đã từ chối đăng ký');
      await _reload();
    } catch (error) {
      if (mounted) _message(_errorMessage(error), error: true);
    } finally {
      if (mounted) setState(() => _busyRegistrationId = null);
    }
  }

  Future<void> _showCreateClub() async {
    final formKey = GlobalKey<FormState>();
    final code = TextEditingController();
    final name = TextEditingController();
    final description = TextEditingController();
    final schedule = TextEditingController();
    final capacity = TextEditingController(text: '20');
    final fee = TextEditingController(text: '0');
    var approvalRequired = false;
    var registrationStart = DateTime.now();
    var registrationEnd = DateTime.now().add(const Duration(days: 30));
    var saving = false;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            8,
            16,
            16 + MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: Form(
            key: formKey,
            child: ListView(
              shrinkWrap: true,
              children: [
                const Center(
                  child: SizedBox(width: 32, child: Divider(thickness: 4)),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Tạo câu lạc bộ',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: code,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(
                    labelText: 'Mã CLB',
                    prefixIcon: Icon(Icons.tag_rounded),
                  ),
                  validator: _required,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: name,
                  decoration: const InputDecoration(
                    labelText: 'Tên câu lạc bộ',
                    prefixIcon: Icon(Icons.groups_rounded),
                  ),
                  validator: _required,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: description,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Mô tả',
                    prefixIcon: Icon(Icons.notes_rounded),
                  ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: schedule,
                  decoration: const InputDecoration(
                    labelText: 'Lịch sinh hoạt',
                    hintText: 'Ví dụ: Thứ Bảy 08:00-10:00',
                    prefixIcon: Icon(Icons.schedule_rounded),
                  ),
                  validator: _required,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: capacity,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Sức chứa',
                          prefixIcon: Icon(Icons.event_seat_outlined),
                        ),
                        validator: (value) =>
                            (int.tryParse(value ?? '') ?? 0) < 1
                            ? 'Sức chứa phải lớn hơn 0'
                            : null,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: fee,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Phí tham gia',
                          suffixText: 'đ',
                          prefixIcon: Icon(Icons.payments_outlined),
                        ),
                        validator: (value) =>
                            (int.tryParse(value ?? '') ?? -1) < 0
                            ? 'Phí không hợp lệ'
                            : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _DateField(
                  label: 'Bắt đầu đăng ký',
                  value: registrationStart,
                  onTap: () async {
                    final picked = await _pickDate(context, registrationStart);
                    if (picked != null) {
                      setSheetState(() => registrationStart = picked);
                    }
                  },
                ),
                const SizedBox(height: 10),
                _DateField(
                  label: 'Kết thúc đăng ký',
                  value: registrationEnd,
                  onTap: () async {
                    final picked = await _pickDate(context, registrationEnd);
                    if (picked != null) {
                      setSheetState(() => registrationEnd = picked);
                    }
                  },
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Cần quản trị viên phê duyệt'),
                  subtitle: const Text('Đăng ký mới sẽ ở trạng thái Chờ duyệt'),
                  value: approvalRequired,
                  onChanged: (value) =>
                      setSheetState(() => approvalRequired = value),
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: saving
                      ? null
                      : () async {
                          if (formKey.currentState?.validate() != true) return;
                          if (registrationEnd.isBefore(registrationStart)) {
                            _message(
                              'Ngày kết thúc phải sau ngày bắt đầu',
                              error: true,
                            );
                            return;
                          }
                          setSheetState(() => saving = true);
                          try {
                            await sl<ApiService>().createClub({
                              'code': code.text.trim(),
                              'name': name.text.trim(),
                              'description': description.text.trim(),
                              'schedule': schedule.text.trim(),
                              'capacity': int.parse(capacity.text),
                              'feeAmount': int.parse(fee.text),
                              'approvalRequired': approvalRequired,
                              'registrationStart': _isoDate(registrationStart),
                              'registrationEnd': _isoDate(registrationEnd),
                              'active': true,
                            });
                            if (!sheetContext.mounted) return;
                            Navigator.pop(sheetContext);
                            _message('Đã tạo câu lạc bộ');
                            await _reload();
                          } catch (error) {
                            if (mounted) {
                              _message(_errorMessage(error), error: true);
                            }
                          } finally {
                            if (sheetContext.mounted) {
                              setSheetState(() => saving = false);
                            }
                          }
                        },
                  icon: saving
                      ? const SizedBox.square(
                          dimension: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.check_rounded),
                  label: Text(saving ? 'Đang tạo...' : 'Tạo câu lạc bộ'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    code.dispose();
    name.dispose();
    description.dispose();
    schedule.dispose();
    capacity.dispose();
    fee.dispose();
  }

  void _message(String message, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: error ? AppColors.error : null,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _AdminClubCard extends StatelessWidget {
  const _AdminClubCard({required this.club});
  final Map<String, dynamic> club;

  @override
  Widget build(BuildContext context) {
    final capacity = (club['capacity'] as num?)?.toInt() ?? 0;
    final approved = (club['approvedCount'] as num?)?.toInt() ?? 0;
    final waiting = (club['waitlistCount'] as num?)?.toInt() ?? 0;
    final fee = (club['feeAmount'] as num?)?.toInt() ?? 0;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.adminAccent.withValues(alpha: .1),
                  child: const Icon(
                    Icons.groups_rounded,
                    color: AppColors.adminAccent,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        club['name']?.toString() ?? 'Câu lạc bộ',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        '${club['code']} · ${club['schedule']}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                _StatusBadge(
                  label: club['active'] == true ? 'Đang mở' : 'Tạm dừng',
                  color: club['active'] == true
                      ? AppColors.success
                      : AppColors.textSecondary,
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: capacity == 0 ? 0 : approved / capacity,
              minHeight: 6,
              borderRadius: BorderRadius.circular(3),
              color: AppColors.adminAccent,
              backgroundColor: AppColors.divider,
            ),
            const SizedBox(height: 7),
            Wrap(
              spacing: 14,
              runSpacing: 6,
              children: [
                Text('$approved/$capacity đã duyệt'),
                Text('$waiting chờ chỗ'),
                Text(fee == 0 ? 'Miễn phí' : '${_money(fee)} đ'),
                if (club['approvalRequired'] == true)
                  const Text('Cần phê duyệt'),
              ],
            ),
            const SizedBox(height: 7),
            Text(
              'Đăng ký: ${_displayDate(club['registrationStart'])} - ${_displayDate(club['registrationEnd'])}',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RegistrationRow extends StatelessWidget {
  const _RegistrationRow({
    required this.registration,
    required this.busy,
    required this.onApprove,
    required this.onReject,
  });
  final Map<String, dynamic> registration;
  final bool busy;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    final status = registration['status']?.toString() ?? '';
    final actionable = status == 'PENDING' || status == 'WAITLIST';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: AppColors.adminAccent.withValues(alpha: .1),
            child: Text((registration['studentName']?.toString() ?? 'H')[0]),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  registration['studentName']?.toString() ?? 'Học sinh',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  registration['clubName']?.toString() ?? '',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                _RegistrationStatus(status: status),
                if (registration['invoiceId'] != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Hóa đơn: ${registration['invoiceId']}',
                    style: const TextStyle(fontSize: 11),
                  ),
                ],
              ],
            ),
          ),
          if (actionable)
            busy
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : PopupMenuButton<String>(
                    tooltip: 'Xử lý đăng ký',
                    onSelected: (value) =>
                        value == 'approve' ? onApprove() : onReject(),
                    itemBuilder: (_) => const [
                      PopupMenuItem(
                        value: 'approve',
                        child: ListTile(
                          leading: Icon(
                            Icons.check_circle_outline_rounded,
                            color: AppColors.success,
                          ),
                          title: Text('Duyệt'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      PopupMenuItem(
                        value: 'reject',
                        child: ListTile(
                          leading: Icon(
                            Icons.cancel_outlined,
                            color: AppColors.error,
                          ),
                          title: Text('Từ chối'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  ),
        ],
      ),
    );
  }
}

class _RegistrationStatus extends StatelessWidget {
  const _RegistrationStatus({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      'PENDING' => ('Chờ duyệt', AppColors.warning),
      'WAITLIST' => ('Chờ chỗ', Colors.deepOrange),
      'APPROVED' => ('Đã duyệt', AppColors.success),
      'REJECTED' => ('Từ chối', AppColors.error),
      'CANCELLED' => ('Đã hủy', AppColors.textSecondary),
      _ => (status, AppColors.textSecondary),
    };
    return _StatusBadge(label: label, color: color);
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: color.withValues(alpha: .1),
      borderRadius: BorderRadius.circular(6),
    ),
    child: Text(
      label,
      style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700),
    ),
  );
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.value,
    required this.onTap,
  });
  final String label;
  final DateTime value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(6),
    child: InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.calendar_month_outlined),
        suffixIcon: const Icon(Icons.chevron_right_rounded),
      ),
      child: Text(_displayDate(value)),
    ),
  );
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.message,
    required this.onRefresh,
  });
  final IconData icon;
  final String message;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) => RefreshIndicator(
    onRefresh: onRefresh,
    child: ListView(
      children: [
        const SizedBox(height: 180),
        Icon(icon, size: 52, color: AppColors.textSecondary),
        const SizedBox(height: 10),
        Center(child: Text(message)),
      ],
    ),
  );
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});
  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline_rounded, size: 44),
          const SizedBox(height: 10),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Thử lại'),
          ),
        ],
      ),
    ),
  );
}

class _AdminClubData {
  const _AdminClubData(this.clubs, this.registrations);
  final List<Map<String, dynamic>> clubs;
  final List<Map<String, dynamic>> registrations;
}

String? _required(String? value) =>
    value == null || value.trim().isEmpty ? 'Không được để trống' : null;

Future<DateTime?> _pickDate(BuildContext context, DateTime initial) =>
    showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );

String _isoDate(DateTime value) =>
    '${value.year.toString().padLeft(4, '0')}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';

String _displayDate(Object? raw) {
  final date = raw is DateTime ? raw : DateTime.tryParse(raw?.toString() ?? '');
  if (date == null) return '—';
  return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
}

String _money(int value) {
  final chars = value.toString().split('').reversed.toList();
  final parts = <String>[];
  for (var i = 0; i < chars.length; i += 3) {
    parts.add(chars.skip(i).take(3).toList().reversed.join());
  }
  return parts.reversed.join('.');
}

String _errorMessage(Object? error) {
  if (error is DioException && error.response?.data is Map) {
    final data = error.response!.data as Map;
    return (data['error'] ?? data['message'] ?? 'Không thể thực hiện')
        .toString();
  }
  return 'Không thể tải dữ liệu câu lạc bộ';
}
