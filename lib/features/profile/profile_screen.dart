import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/session.dart';
import 'account_settings_screens.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, required this.accent});
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final session = context.watch<AppSession>();
    final user = session.user!;
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 24, 18, 110),
        children: [
          Center(
            child: Container(
              width: 92,
              height: 92,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [accent, Color.lerp(accent, Colors.black, .22)!],
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: accent.withValues(alpha: .2),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                user.fullName.trim().isEmpty
                    ? '?'
                    : user.fullName.trim()[0].toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            user.fullName,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          Text(
            _role(user.role),
            textAlign: TextAlign.center,
            style: TextStyle(color: accent, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 26),
          Card(
            margin: EdgeInsets.zero,
            child: Column(
              children: [
                _ProfileRow(
                  icon: Icons.alternate_email,
                  label: 'Tên đăng nhập',
                  value: user.username,
                ),
                if (user.email != null)
                  _ProfileRow(
                    icon: Icons.email_outlined,
                    label: 'Email',
                    value: user.email!,
                  ),
                if (user.className != null)
                  _ProfileRow(
                    icon: Icons.groups_outlined,
                    label: 'Lớp',
                    value: user.className!,
                  ),
                if (user.mainSubject != null)
                  _ProfileRow(
                    icon: Icons.menu_book_outlined,
                    label: 'Môn phụ trách',
                    value: user.mainSubject!,
                  ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Card(
            margin: EdgeInsets.zero,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.palette_outlined),
                  title: const Text('Giao diện'),
                  subtitle: Text(_themeName(session.themeMode)),
                  trailing: DropdownButton<ThemeMode>(
                    value: session.themeMode,
                    underline: const SizedBox.shrink(),
                    items: const [
                      DropdownMenuItem(
                        value: ThemeMode.system,
                        child: Text('Hệ thống'),
                      ),
                      DropdownMenuItem(
                        value: ThemeMode.light,
                        child: Text('Sáng'),
                      ),
                      DropdownMenuItem(
                        value: ThemeMode.dark,
                        child: Text('Tối'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) session.setTheme(value);
                    },
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.notifications_active_outlined),
                  title: Text('Cấu hình thông báo'),
                  subtitle: Text('Push, email và loại nội dung muốn nhận'),
                  trailing: Icon(Icons.chevron_right_rounded),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          NotificationSettingsScreen(accent: accent),
                    ),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.lock_outline_rounded),
                  title: Text('Đổi mật khẩu'),
                  subtitle: Text('Bảo vệ tài khoản của bạn'),
                  trailing: Icon(Icons.chevron_right_rounded),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChangePasswordScreen(accent: accent),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: session.logout,
            icon: const Icon(Icons.logout_rounded),
            label: const Text('Đăng xuất'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Smart School Mobile · phiên bản 2.0',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  String _role(String value) => switch (value) {
    'ADMIN' => 'Quản trị viên',
    'TEACHER' => 'Giáo viên',
    'PARENT' => 'Phụ huynh',
    _ => 'Học sinh',
  };

  String _themeName(ThemeMode mode) => switch (mode) {
    ThemeMode.light => 'Chế độ sáng',
    ThemeMode.dark => 'Chế độ tối',
    _ => 'Theo thiết bị',
  };
}

class _ProfileRow extends StatelessWidget {
  const _ProfileRow({
    required this.icon,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => ListTile(
    leading: Icon(icon),
    title: Text(label),
    trailing: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 220),
      child: Text(
        value,
        textAlign: TextAlign.end,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
    ),
  );
}
