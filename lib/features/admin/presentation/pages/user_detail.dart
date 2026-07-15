import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/section_header.dart';

class AdminUserDetail extends StatelessWidget {
  const AdminUserDetail({
    super.key,
    required this.name,
    required this.code,
    required this.role,
    required this.username,
  });

  final String name;
  final String code;
  final String role;
  final String username;

  Color get _color => switch (role) {
        'TEACHER' => AppColors.teacherAccent,
        'STUDENT' => AppColors.studentAccent,
        'PARENT' => AppColors.parentAccent,
        _ => AppColors.adminAccent,
      };

  String get _label => switch (role) {
        'TEACHER' => 'Giáo viên',
        'STUDENT' => 'Học sinh',
        'PARENT' => 'Phụ huynh',
        _ => 'Quản trị viên',
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết người dùng'),
        backgroundColor: AppColors.adminAccent,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (v) => _handleAction(context, v),
            itemBuilder: (_) => const [
              PopupMenuItem(
                  value: 'reset',
                  child: ListTile(
                    leading: Icon(Icons.lock_reset_rounded),
                    title: Text('Reset mật khẩu'),
                    contentPadding: EdgeInsets.zero,
                  )),
              PopupMenuItem(
                  value: 'lock',
                  child: ListTile(
                    leading: Icon(Icons.lock_outline_rounded,
                        color: AppColors.warning),
                    title: Text('Khóa tài khoản',
                        style: TextStyle(color: AppColors.warning)),
                    contentPadding: EdgeInsets.zero,
                  )),
              PopupMenuItem(
                  value: 'delete',
                  child: ListTile(
                    leading: Icon(Icons.delete_outline, color: AppColors.error),
                    title: Text('Xóa tài khoản',
                        style: TextStyle(color: AppColors.error)),
                    contentPadding: EdgeInsets.zero,
                  )),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [_color, _color.withValues(alpha: 0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  child: Text(
                    name[0],
                    style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
                const SizedBox(height: 12),
                Text(name,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18)),
                const SizedBox(height: 4),
                Text('@$username',
                    style:
                        const TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(_label,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text('ACTIVE',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const SectionHeader(title: 'Thông tin cơ bản'),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                _Row(label: 'Mã', value: code.isEmpty ? '—' : code),
                const Divider(height: 0),
                const _Row(label: 'Số điện thoại', value: '0900 000 010'),
                const Divider(height: 0),
                const _Row(label: 'Email', value: 'user@sse.edu.vn'),
                const Divider(height: 0),
                const _Row(label: 'Ngày sinh', value: '15/08/2008'),
                const Divider(height: 0),
                const _Row(label: 'Giới tính', value: 'Nam'),
                const Divider(height: 0),
                const _Row(
                    label: 'Địa chỉ', value: '123 Đường Lê Lợi, Q.1, TP.HCM'),
              ],
            ),
          ),
          if (role == 'STUDENT') ...[
            const SizedBox(height: 20),
            const SectionHeader(title: 'Học tập'),
            const SizedBox(height: 8),
            const Card(
              child: Column(
                children: [
                  _Row(label: 'Lớp hiện tại', value: '10A1'),
                  Divider(height: 0),
                  _Row(label: 'Ngày nhập học', value: '05/09/2025'),
                  Divider(height: 0),
                  _Row(label: 'Phụ huynh', value: 'Phạm Văn Quân'),
                ],
              ),
            ),
          ],
          if (role == 'TEACHER') ...[
            const SizedBox(height: 20),
            const SectionHeader(title: 'Giảng dạy'),
            const SizedBox(height: 8),
            const Card(
              child: Column(
                children: [
                  _Row(label: 'Môn chính', value: 'Toán'),
                  Divider(height: 0),
                  _Row(label: 'Bằng cấp', value: 'Thạc sĩ Toán học'),
                  Divider(height: 0),
                  _Row(label: 'Ngày vào trường', value: '01/08/2018'),
                  Divider(height: 0),
                  _Row(label: 'GVCN lớp', value: '10A1'),
                  Divider(height: 0),
                  _Row(label: 'Số lớp dạy', value: '4 lớp'),
                ],
              ),
            ),
          ],
          if (role == 'PARENT') ...[
            const SizedBox(height: 20),
            const SectionHeader(title: 'Học sinh liên kết'),
            const SizedBox(height: 8),
            const Card(
              child: Column(
                children: [
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.studentAccent,
                      child: Text('A', style: TextStyle(color: Colors.white)),
                    ),
                    title: Text('Phạm Hoài An'),
                    subtitle: Text('Lớp 10A1 • Bố (Primary)'),
                  ),
                  Divider(height: 0),
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.teacherAccent,
                      child: Text('B', style: TextStyle(color: Colors.white)),
                    ),
                    title: Text('Phạm Hoài Bình'),
                    subtitle: Text('Lớp 8A1 • Bố'),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 20),
          const SectionHeader(title: 'Lịch sử đăng nhập'),
          const SizedBox(height: 8),
          const Card(
            child: Column(
              children: [
                _LoginRow(
                    time: '22/05 09:15',
                    device: 'iPhone 14 Pro',
                    success: true),
                Divider(height: 0),
                _LoginRow(
                    time: '21/05 18:30',
                    device: 'Chrome — macOS',
                    success: true),
                Divider(height: 0),
                _LoginRow(
                    time: '21/05 07:45',
                    device: 'iPhone 14 Pro',
                    success: true),
                Divider(height: 0),
                _LoginRow(
                    time: '20/05 23:12',
                    device: 'Unknown — 1 lần thất bại',
                    success: false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleAction(BuildContext context, String action) {
    final messages = {
      'reset': 'Đã gửi link reset mật khẩu qua email',
      'lock': 'Đã khóa tài khoản',
      'delete': 'Đã xóa tài khoản (soft-delete)',
    };
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(messages[action] ?? action),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(label,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      subtitle: Text(value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
    );
  }
}

class _LoginRow extends StatelessWidget {
  const _LoginRow({
    required this.time,
    required this.device,
    required this.success,
  });
  final String time;
  final String device;
  final bool success;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        success ? Icons.check_circle_rounded : Icons.error_rounded,
        color: success ? AppColors.success : AppColors.error,
        size: 20,
      ),
      title: Text(device,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
      subtitle: Text(time,
          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
    );
  }
}
