import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _current = TextEditingController();
  final _next = TextEditingController();
  final _confirmation = TextEditingController();
  bool _obscure = true;
  bool _busy = false;

  @override
  void dispose() {
    _current.dispose();
    _next.dispose();
    _confirmation.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _busy = true);
    try {
      await sl<ApiService>().changePassword(_current.text, _next.text);
      if (!mounted) return;
      context.read<AuthBloc>().add(const AuthLogoutRequested());
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Không thể đổi mật khẩu. Vui lòng kiểm tra lại và thử lại.',
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const CircleAvatar(
                          radius: 30,
                          backgroundColor: AppColors.primary,
                          child: Icon(
                            Icons.admin_panel_settings_rounded,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        const SizedBox(height: 18),
                        const Text(
                          'Đổi mật khẩu',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Nhập mật khẩu hiện tại và đặt mật khẩu mới cho tài khoản.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 24),
                        _passwordField(_current, 'Mật khẩu hiện tại'),
                        const SizedBox(height: 14),
                        _passwordField(
                          _next,
                          'Mật khẩu mới',
                          validateNew: true,
                        ),
                        const SizedBox(height: 14),
                        _passwordField(
                          _confirmation,
                          'Xác nhận mật khẩu mới',
                          validateConfirmation: true,
                        ),
                        const SizedBox(height: 20),
                        FilledButton(
                          onPressed: _busy ? null : _submit,
                          child: Text(
                            _busy
                                ? 'Đang cập nhật...'
                                : 'Đổi mật khẩu và đăng nhập lại',
                          ),
                        ),
                        TextButton.icon(
                          onPressed: _busy
                              ? null
                              : () => context.read<AuthBloc>().add(
                                  const AuthLogoutRequested(),
                                ),
                          icon: const Icon(Icons.logout_rounded, size: 18),
                          label: const Text('Đăng xuất'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _passwordField(
    TextEditingController controller,
    String label, {
    bool validateNew = false,
    bool validateConfirmation = false,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: _obscure,
      autocorrect: false,
      enableSuggestions: false,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.lock_outline_rounded),
        suffixIcon: IconButton(
          onPressed: () => setState(() => _obscure = !_obscure),
          icon: Icon(
            _obscure
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
          ),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Không được để trống';
        if (validateNew && value.length < 10) return 'Cần ít nhất 10 ký tự';
        if (validateNew && value == _current.text) {
          return 'Mật khẩu mới phải khác mật khẩu hiện tại';
        }
        if (validateConfirmation && value != _next.text) {
          return 'Mật khẩu xác nhận không khớp';
        }
        return null;
      },
    );
  }
}
