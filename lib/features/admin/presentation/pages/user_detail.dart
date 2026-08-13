import 'package:flutter/material.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/section_header.dart';

/// Hồ sơ quản trị dùng hoàn toàn dữ liệu Backend, không còn thông tin minh họa.
class AdminUserDetail extends StatefulWidget {
  const AdminUserDetail({
    super.key,
    required this.id,
    required this.name,
    required this.code,
    required this.role,
    required this.username,
    required this.status,
    this.email,
    this.phone,
    this.className,
    this.dateOfBirth,
    this.gender,
    this.address,
    this.enrollmentDate,
    this.guardianName,
    this.guardianPhone,
    this.mainSubject,
  });

  final String id;
  final String name;
  final String code;
  final String role;
  final String username;
  final String status;
  final String? email;
  final String? phone;
  final String? className;
  final String? dateOfBirth;
  final String? gender;
  final String? address;
  final String? enrollmentDate;
  final String? guardianName;
  final String? guardianPhone;
  final String? mainSubject;

  @override
  State<AdminUserDetail> createState() => _AdminUserDetailState();
}

class _AdminUserDetailState extends State<AdminUserDetail> {
  late Future<List<Map<String, dynamic>>> _history;
  Future<List<Map<String, dynamic>>>? _children;
  late bool _locked;

  ApiService get _api => sl<ApiService>();

  @override
  void initState() {
    super.initState();
    _locked = widget.status == 'LOCKED';
    _history = _api.loginHistory(widget.id);
    if (widget.role == 'PARENT') _children = _api.userChildren(widget.id);
  }

  Color get _color => switch (widget.role) {
        'TEACHER' => AppColors.teacherAccent,
        'STUDENT' => AppColors.studentAccent,
        'PARENT' => AppColors.parentAccent,
        _ => AppColors.adminAccent,
      };

  String get _roleLabel => switch (widget.role) {
        'TEACHER' => 'Giáo viên',
        'STUDENT' => 'Học sinh',
        'PARENT' => 'Phụ huynh',
        _ => 'Quản trị viên',
      };

  String _value(String? value) =>
      value == null || value.trim().isEmpty ? '—' : value;

  String _gender(String? value) => switch (value) {
        'MALE' => 'Nam',
        'FEMALE' => 'Nữ',
        'OTHER' => 'Khác',
        _ => _value(value),
      };

  Future<void> _handleAction(String action) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      if (action == 'reset') {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Đặt lại xác thực?'),
            content: const Text(
              'Tất cả phiên đăng nhập hiện tại của người dùng sẽ bị thu hồi. '
              'Tài khoản LOCAL nhận link đặt lại; tài khoản SSO được hướng dẫn qua hệ thống chung.',
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Hủy')),
              FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Xác nhận')),
            ],
          ),
        );
        if (confirmed != true || !mounted) return;
        final result = await _api.resetUserPassword(widget.id);
        if (!mounted) return;
        await showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(result['authType'] == 'SSO'
                ? 'Tài khoản đăng nhập qua hệ thống chung'
                : 'Đã gửi link đặt lại'),
            content: Text(result['message']?.toString() ??
                'Yêu cầu đặt lại xác thực đã được xử lý.'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Đóng'))
            ],
          ),
        );
        return;
      }
      if (_locked) {
        await _api.unlockUser(widget.id);
      } else {
        await _api.lockUser(widget.id);
      }
      if (!mounted) return;
      setState(() => _locked = !_locked);
      messenger.showSnackBar(SnackBar(
        content: Text(_locked ? 'Đã khóa tài khoản' : 'Đã mở khóa tài khoản'),
        behavior: SnackBarBehavior.floating,
      ));
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(const SnackBar(
        content: Text('Không thể thực hiện. Vui lòng thử lại.'),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết người dùng'),
        backgroundColor: AppColors.adminAccent,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: _handleAction,
            itemBuilder: (_) => [
              const PopupMenuItem(
                  value: 'reset',
                  child: ListTile(
                      leading: Icon(Icons.lock_reset_rounded),
                      title: Text('Đặt lại mật khẩu'),
                      contentPadding: EdgeInsets.zero)),
              PopupMenuItem(
                  value: 'lock',
                  child: ListTile(
                      leading: Icon(
                          _locked
                              ? Icons.lock_open_rounded
                              : Icons.lock_outline_rounded,
                          color: AppColors.warning),
                      title: Text(
                          _locked ? 'Mở khóa tài khoản' : 'Khóa tài khoản',
                          style: const TextStyle(color: AppColors.warning)),
                      contentPadding: EdgeInsets.zero)),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _identityCard(),
          const SizedBox(height: 20),
          const SectionHeader(title: 'Thông tin liên hệ'),
          const SizedBox(height: 8),
          Card(
              child: Column(children: [
            _InfoRow(label: 'Mã', value: _value(widget.code)),
            const Divider(height: 0),
            _InfoRow(label: 'Số điện thoại', value: _value(widget.phone)),
            const Divider(height: 0),
            _InfoRow(label: 'Email', value: _value(widget.email)),
            if (widget.dateOfBirth != null) ...[
              const Divider(height: 0),
              _InfoRow(label: 'Ngày sinh', value: _value(widget.dateOfBirth)),
              const Divider(height: 0),
              _InfoRow(label: 'Giới tính', value: _gender(widget.gender)),
            ],
            if (widget.address != null) ...[
              const Divider(height: 0),
              _InfoRow(label: 'Địa chỉ', value: _value(widget.address)),
            ],
          ])),
          if (widget.role == 'STUDENT') ...[
            const SizedBox(height: 20),
            const SectionHeader(title: 'Thông tin học tập'),
            const SizedBox(height: 8),
            Card(
                child: Column(children: [
              _InfoRow(label: 'Lớp hiện tại', value: _value(widget.className)),
              const Divider(height: 0),
              _InfoRow(
                  label: 'Ngày nhập học', value: _value(widget.enrollmentDate)),
              const Divider(height: 0),
              _InfoRow(
                  label: 'Người giám hộ', value: _value(widget.guardianName)),
              const Divider(height: 0),
              _InfoRow(
                  label: 'SĐT người giám hộ',
                  value: _value(widget.guardianPhone)),
            ])),
          ],
          if (widget.role == 'TEACHER') ...[
            const SizedBox(height: 20),
            const SectionHeader(title: 'Thông tin giảng dạy'),
            const SizedBox(height: 8),
            Card(
                child: Column(children: [
              _InfoRow(label: 'Mã giáo viên', value: _value(widget.code)),
              const Divider(height: 0),
              _InfoRow(
                  label: 'Môn chuyên ngành', value: _value(widget.mainSubject)),
            ])),
          ],
          if (_children != null) ...[
            const SizedBox(height: 20),
            const SectionHeader(title: 'Học sinh đã liên kết'),
            const SizedBox(height: 8),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _children,
              builder: (context, snap) {
                if (snap.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                final children = snap.data ?? const [];
                if (children.isEmpty) {
                  return const Card(
                      child: ListTile(title: Text('Chưa liên kết học sinh')));
                }
                return Card(
                    child: Column(
                        children: children
                            .map((child) => ListTile(
                                  leading: const CircleAvatar(
                                      child: Icon(Icons.school_rounded)),
                                  title:
                                      Text(child['fullName']?.toString() ?? ''),
                                  subtitle: Text(
                                      '${child['studentCode'] ?? ''} · ${child['className'] ?? 'Chưa xếp lớp'}'),
                                ))
                            .toList()));
              },
            ),
          ],
          const SizedBox(height: 20),
          const SectionHeader(title: 'Lịch sử đăng nhập'),
          const SizedBox(height: 8),
          FutureBuilder<List<Map<String, dynamic>>>(
            future: _history,
            builder: (context, snap) {
              if (snap.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snap.hasError) {
                return const Card(
                    child: ListTile(
                        title: Text('Không thể tải lịch sử đăng nhập.')));
              }
              final history = snap.data ?? const [];
              if (history.isEmpty) {
                return const Card(
                    child: ListTile(title: Text('Chưa có lịch sử đăng nhập')));
              }
              return Card(
                  child: Column(
                      children: history
                          .take(10)
                          .map((item) => ListTile(
                                leading: Icon(
                                    item['success'] == true
                                        ? Icons.check_circle_rounded
                                        : Icons.error_rounded,
                                    color: item['success'] == true
                                        ? AppColors.success
                                        : AppColors.error),
                                title: Text(item['success'] == true
                                    ? 'Đăng nhập thành công'
                                    : 'Đăng nhập thất bại'),
                                subtitle: Text(
                                    '${item['createdAt'] ?? ''}\nIP: ${item['ipAddress'] ?? 'Không rõ'}${item['failureReason'] == null ? '' : ' · ${item['failureReason']}'}'),
                                isThreeLine: true,
                              ))
                          .toList()));
            },
          ),
        ],
      ),
    );
  }

  Widget _identityCard() => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient:
              LinearGradient(colors: [_color, _color.withValues(alpha: .72)]),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(children: [
          CircleAvatar(
              radius: 40,
              backgroundColor: Colors.white.withValues(alpha: .18),
              child: Text(widget.name.isEmpty ? '?' : widget.name[0],
                  style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white))),
          const SizedBox(height: 12),
          Text(widget.name,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18)),
          Text('@${widget.username}',
              style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 10),
          Wrap(spacing: 8, children: [
            _chip(_roleLabel, Colors.white.withValues(alpha: .2)),
            _chip(_locked ? 'Đã khóa' : 'Đang hoạt động',
                _locked ? AppColors.warning : AppColors.success),
          ]),
        ]),
      );

  Widget _chip(String label, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration:
            BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
        child: Text(label,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700)),
      );
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => ListTile(
        title: Text(label,
            style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurfaceVariant)),
        subtitle: Text(value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      );
}
