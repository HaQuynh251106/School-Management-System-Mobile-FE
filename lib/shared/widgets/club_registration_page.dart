import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../core/di/service_locator.dart';
import '../../core/network/api_service.dart';
import '../../core/theme/app_colors.dart';

class ClubRegistrationPage extends StatefulWidget {
  const ClubRegistrationPage({
    super.key,
    required this.accent,
    this.childId,
    this.childName,
  });

  final Color accent;
  final String? childId;
  final String? childName;

  @override
  State<ClubRegistrationPage> createState() => _ClubRegistrationPageState();
}

class _ClubRegistrationPageState extends State<ClubRegistrationPage> {
  late Future<_ClubData> _future = _load();
  String? _busyId;

  Future<_ClubData> _load() async {
    final api = sl<ApiService>();
    final values = await Future.wait([
      api.clubs(),
      widget.childId == null
          ? api.myClubRegistrations()
          : api.childClubRegistrations(widget.childId!),
    ]);
    return _ClubData(values[0], values[1]);
  }

  void _reload() => setState(() => _future = _load());

  Future<void> _register(Map<String, dynamic> club) async {
    final id = club['id'].toString();
    setState(() => _busyId = id);
    try {
      final result =
          await sl<ApiService>().registerClub(id, studentId: widget.childId);
      if (!mounted) return;
      _message(_statusMessage(result['status']?.toString()));
      _reload();
    } catch (error) {
      if (mounted) _message(_errorMessage(error), error: true);
    } finally {
      if (mounted) setState(() => _busyId = null);
    }
  }

  Future<void> _cancel(Map<String, dynamic> registration) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hủy đăng ký CLB?'),
        content: const Text(
            'Chỗ của bạn có thể được chuyển cho học sinh trong danh sách chờ.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Giữ đăng ký')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Hủy đăng ký')),
        ],
      ),
    );
    if (confirmed != true) return;
    final id = registration['id'].toString();
    setState(() => _busyId = id);
    try {
      await sl<ApiService>().cancelClubRegistration(id);
      if (!mounted) return;
      _message('Đã hủy đăng ký câu lạc bộ');
      _reload();
    } catch (error) {
      if (mounted) _message(_errorMessage(error), error: true);
    } finally {
      if (mounted) setState(() => _busyId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.childName == null
            ? 'Câu lạc bộ'
            : 'CLB của ${widget.childName}'),
        backgroundColor: widget.accent,
      ),
      body: FutureBuilder<_ClubData>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _ErrorState(
                message: _errorMessage(snapshot.error), onRetry: _reload);
          }
          final data = snapshot.data!;
          final byClub = <String, Map<String, dynamic>>{
            for (final item in data.registrations)
              item['clubId'].toString(): item,
          };
          if (data.clubs.isEmpty) {
            return RefreshIndicator(
              onRefresh: () async => _reload(),
              child: ListView(children: const [
                SizedBox(height: 180),
                Icon(Icons.groups_outlined,
                    size: 54, color: AppColors.textSecondary),
                SizedBox(height: 12),
                Center(child: Text('Chưa có câu lạc bộ đang mở')),
              ]),
            );
          }
          return RefreshIndicator(
            onRefresh: () async => _reload(),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: data.clubs.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final club = data.clubs[index];
                return _ClubCard(
                  club: club,
                  registration: byClub[club['id'].toString()],
                  accent: widget.accent,
                  busyId: _busyId,
                  onRegister: () => _register(club),
                  onCancel: _cancel,
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _message(String message, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: error ? AppColors.error : null,
    ));
  }
}

class _ClubCard extends StatelessWidget {
  const _ClubCard({
    required this.club,
    required this.registration,
    required this.accent,
    required this.busyId,
    required this.onRegister,
    required this.onCancel,
  });

  final Map<String, dynamic> club;
  final Map<String, dynamic>? registration;
  final Color accent;
  final String? busyId;
  final VoidCallback onRegister;
  final ValueChanged<Map<String, dynamic>> onCancel;

  @override
  Widget build(BuildContext context) {
    final status = registration?['status']?.toString();
    final active = const {'PENDING', 'WAITLIST', 'APPROVED'}.contains(status);
    final available = (club['availableSlots'] as num?)?.toInt() ?? 0;
    final fee = (club['feeAmount'] as num?)?.toInt() ?? 0;
    final busy = busyId == club['id'] || busyId == registration?['id'];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: .1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(Icons.groups_rounded, color: accent),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(club['name']?.toString() ?? 'Câu lạc bộ',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 3),
                      Text(club['schedule']?.toString() ?? '',
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                if (status != null) _StatusBadge(status: status),
              ],
            ),
            if ((club['description']?.toString() ?? '').isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(club['description'].toString()),
            ],
            const SizedBox(height: 12),
            Wrap(
              spacing: 14,
              runSpacing: 8,
              children: [
                _Info(
                    icon: Icons.event_seat_outlined,
                    text: '$available chỗ còn lại'),
                _Info(
                    icon: Icons.payments_outlined,
                    text: fee == 0 ? 'Miễn phí' : '${_money(fee)} đ'),
                if (club['approvalRequired'] == true)
                  const _Info(
                      icon: Icons.verified_user_outlined,
                      text: 'Cần xét duyệt'),
              ],
            ),
            if (status == 'WAITLIST') ...[
              const SizedBox(height: 8),
              Text(
                  'Vị trí danh sách chờ: ${registration?['waitlistPosition'] ?? '—'}',
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textSecondary)),
            ],
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: active
                  ? OutlinedButton.icon(
                      onPressed: busy ? null : () => onCancel(registration!),
                      icon: busy
                          ? const SizedBox.square(
                              dimension: 16,
                              child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.close_rounded),
                      label: const Text('Hủy đăng ký'),
                    )
                  : FilledButton.icon(
                      onPressed: busy ? null : onRegister,
                      icon: busy
                          ? const SizedBox.square(
                              dimension: 16,
                              child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.add_rounded),
                      label: Text(
                          available == 0 ? 'Vào danh sách chờ' : 'Đăng ký'),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Info extends StatelessWidget {
  const _Info({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 5),
          Text(text, style: const TextStyle(fontSize: 12)),
        ],
      );
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      'APPROVED' => ('Đã duyệt', Colors.green),
      'PENDING' => ('Chờ duyệt', Colors.orange),
      'WAITLIST' => ('Chờ chỗ', Colors.deepOrange),
      'CANCELLED' => ('Đã hủy', AppColors.textSecondary),
      'REJECTED' => ('Từ chối', AppColors.error),
      _ => (status, AppColors.textSecondary),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: 11, fontWeight: FontWeight.w700)),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

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
                  label: const Text('Thử lại')),
            ],
          ),
        ),
      );
}

class _ClubData {
  const _ClubData(this.clubs, this.registrations);
  final List<Map<String, dynamic>> clubs;
  final List<Map<String, dynamic>> registrations;
}

String _statusMessage(String? status) => switch (status) {
      'APPROVED' => 'Đăng ký thành công',
      'PENDING' => 'Đã gửi đăng ký, đang chờ duyệt',
      'WAITLIST' => 'CLB đã đủ chỗ, bạn đã vào danh sách chờ',
      _ => 'Đã cập nhật đăng ký',
    };

String _errorMessage(Object? error) {
  if (error is DioException && error.response?.data is Map) {
    final data = error.response!.data as Map;
    return (data['message'] ?? data['error'] ?? 'Không thể thực hiện')
        .toString();
  }
  return 'Không thể tải dữ liệu câu lạc bộ';
}

String _money(int value) {
  final chars = value.toString().split('').reversed.toList();
  final parts = <String>[];
  for (var i = 0; i < chars.length; i += 3) {
    parts.add(chars.skip(i).take(3).toList().reversed.join());
  }
  return parts.reversed.join('.');
}
