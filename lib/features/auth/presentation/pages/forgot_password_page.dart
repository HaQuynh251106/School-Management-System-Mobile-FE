import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quên mật khẩu'),
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        elevation: 0,
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) async {
          if (state is AuthForgotPasswordSent) {
            final returnToLogin = await showDialog<bool>(
              context: context,
              barrierDismissible: false,
              builder: (dialogContext) => AlertDialog(
                title: Text(state.emailDeliveryAvailable
                    ? 'Đã tiếp nhận yêu cầu'
                    : 'Chưa thể gửi email'),
                content: Text(state.emailDeliveryAvailable
                    ? 'Nếu tài khoản hợp lệ, bạn sẽ nhận được email đặt lại mật khẩu. Hãy kiểm tra cả thư rác.'
                    : 'Máy chủ hiện chưa cấu hình kênh email. Vui lòng liên hệ quản trị viên để được hỗ trợ.'),
                actions: [
                  if (state.devResetToken?.isNotEmpty == true)
                    TextButton(
                      onPressed: () {
                        Navigator.of(dialogContext).pop(false);
                        context.go(
                            '/reset-password?token=${Uri.encodeQueryComponent(state.devResetToken!)}');
                      },
                      child: const Text('Tiếp tục trên máy local'),
                    ),
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(true),
                    child: const Text('Về đăng nhập'),
                  ),
                ],
              ),
            );
            if (returnToLogin == true && context.mounted) {
              context.go('/login');
            }
          } else if (state is AuthForgotPasswordFailed) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(state.message),
              behavior: SnackBarBehavior.floating,
            ));
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.lock_reset_rounded,
                    size: 56, color: AppColors.primary),
                const SizedBox(height: 20),
                Text(
                  'Nhập email đã đăng ký, chúng tôi sẽ gửi link đặt lại mật khẩu.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email / Tên đăng nhập',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Vui lòng nhập email'
                      : null,
                ),
                const SizedBox(height: 24),
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    final loading = state is AuthLoading;
                    return SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: loading
                            ? null
                            : () {
                                if (_formKey.currentState!.validate()) {
                                  context.read<AuthBloc>().add(
                                        AuthForgotPasswordRequested(
                                          email: _emailCtrl.text.trim(),
                                        ),
                                      );
                                }
                              },
                        child: loading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Gửi link đặt lại'),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: () => context.go('/login'),
                  icon: const Icon(Icons.arrow_back_rounded),
                  label: const Text('Về đăng nhập'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
