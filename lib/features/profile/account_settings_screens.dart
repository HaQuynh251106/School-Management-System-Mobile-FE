import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/session.dart';
import '../../core/widgets/async_state_view.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key, required this.accent});
  final Color accent;

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  late Future<List<Map<String, dynamic>>> future;

  @override
  void initState() {
    super.initState();
    future = context.read<AppSession>().api.list('/notification-preferences');
  }

  void reload() => setState(
        () => future =
            context.read<AppSession>().api.list('/notification-preferences'),
      );

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Cấu hình thông báo')),
        body: AsyncStateView<List<Map<String, dynamic>>>(
          future: future,
          onRetry: reload,
          builder: (context, items) {
            final byChannel = {
              for (final item in items) '${item['channel']}': item
            };
            const channels = [
              ('IN_APP', 'Thông báo trong ứng dụng', Icons.notifications),
              ('PUSH', 'Thông báo đẩy', Icons.phone_android),
              ('EMAIL', 'Email quan trọng', Icons.email_outlined),
            ];
            return ListView(
              padding: const EdgeInsets.all(18),
              children: [
                Text(
                  'Chọn cách bạn muốn nhận thông tin từ nhà trường.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                Card(
                  child: Column(
                    children: channels.map((channel) {
                      final current = byChannel[channel.$1];
                      final enabled = current?['enabled'] != false;
                      return SwitchListTile.adaptive(
                        secondary: Icon(channel.$3, color: widget.accent),
                        title: Text(channel.$2),
                        value: enabled,
                        onChanged: (value) async {
                          await context.read<AppSession>().api.put(
                            '/notification-preferences',
                            {'channel': channel.$1, 'enabled': value},
                          );
                          reload();
                        },
                      );
                    }).toList(),
                  ),
                ),
              ],
            );
          },
        ),
      );
}

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key, required this.accent});
  final Color accent;

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final key = GlobalKey<FormState>();
  final current = TextEditingController();
  final next = TextEditingController();
  final confirm = TextEditingController();
  bool saving = false;
  bool obscure = true;

  @override
  void dispose() {
    current.dispose();
    next.dispose();
    confirm.dispose();
    super.dispose();
  }

  Future<void> save() async {
    if (!key.currentState!.validate()) return;
    setState(() => saving = true);
    try {
      await context.read<AppSession>().api.dio.put('/me/password', data: {
        'currentPassword': current.text,
        'newPassword': next.text,
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã đổi mật khẩu thành công')),
      );
      Navigator.pop(context);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mật khẩu hiện tại không đúng')),
      );
      setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Đổi mật khẩu')),
        body: Form(
          key: key,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              TextFormField(
                controller: current,
                obscureText: obscure,
                decoration:
                    const InputDecoration(labelText: 'Mật khẩu hiện tại'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Không được để trống' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: next,
                obscureText: obscure,
                decoration: const InputDecoration(labelText: 'Mật khẩu mới'),
                validator: (value) => value == null || value.length < 10
                    ? 'Cần ít nhất 10 ký tự'
                    : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: confirm,
                obscureText: obscure,
                decoration:
                    const InputDecoration(labelText: 'Nhập lại mật khẩu mới'),
                validator: (value) =>
                    value != next.text ? 'Mật khẩu chưa trùng khớp' : null,
              ),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                value: !obscure,
                onChanged: (value) => setState(() => obscure = !value),
                title: const Text('Hiện mật khẩu'),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: saving ? null : save,
                style: FilledButton.styleFrom(backgroundColor: widget.accent),
                icon: const Icon(Icons.lock_reset_rounded),
                label: Text(saving ? 'Đang cập nhật...' : 'Đổi mật khẩu'),
              ),
            ],
          ),
        ),
      );
}

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final account = TextEditingController();
  bool sending = false;
  String? message;

  @override
  void dispose() {
    account.dispose();
    super.dispose();
  }

  Future<void> send() async {
    if (account.text.trim().isEmpty) return;
    setState(() => sending = true);
    try {
      final value = account.text.trim();
      final result = await context.read<AppSession>().api.post(
        '/auth/forgot-password',
        value.contains('@') ? {'email': value} : {'username': value},
      );
      setState(() {
        sending = false;
        message =
            '${result['message'] ?? 'Nếu tài khoản tồn tại, hướng dẫn đã được gửi.'}';
      });
    } catch (_) {
      setState(() {
        sending = false;
        message = 'Không thể gửi yêu cầu lúc này.';
      });
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Khôi phục mật khẩu')),
        body: ListView(
          padding: const EdgeInsets.all(22),
          children: [
            const Icon(Icons.mark_email_read_outlined, size: 64),
            const SizedBox(height: 18),
            Text(
              'Nhận hướng dẫn đặt lại mật khẩu',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Nhập tên đăng nhập hoặc email đã đăng ký.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextField(
              controller: account,
              decoration: const InputDecoration(
                labelText: 'Tên đăng nhập hoặc email',
                prefixIcon: Icon(Icons.alternate_email),
              ),
            ),
            const SizedBox(height: 14),
            FilledButton(
              onPressed: sending ? null : send,
              child: Text(sending ? 'Đang gửi...' : 'Gửi hướng dẫn'),
            ),
            if (message != null) ...[
              const SizedBox(height: 18),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(message!, textAlign: TextAlign.center),
                ),
              ),
            ],
          ],
        ),
      );
}
