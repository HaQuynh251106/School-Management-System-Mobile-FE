import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  static const _showDemoAccounts = bool.fromEnvironment(
    'SHOW_DEMO_ACCOUNTS',
    defaultValue: !kReleaseMode,
  );
  final _formKey = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthBloc>().add(
      AuthLoginRequested(
        username: _usernameCtrl.text.trim(),
        password: _passwordCtrl.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthLoginFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 840;
              if (wide) {
                return Row(
                  children: [
                    Expanded(flex: 11, child: _buildBrandPanel()),
                    Expanded(
                      flex: 9,
                      child: Center(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(48),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 430),
                            child: _buildLoginSurface(showHeader: false),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }
              return Stack(
                children: [
                  Positioned(
                    left: -80,
                    right: -80,
                    top: -180,
                    child: Container(
                      height: 390,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF1647B9), AppColors.primary],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 54, 20, 28),
                    child: _buildLoginSurface(showHeader: true),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLoginSurface({required bool showHeader}) {
    return Card(
      elevation: 12,
      shadowColor: Colors.black.withValues(alpha: .12),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (showHeader) ...[_buildHeader(), const SizedBox(height: 28)],
            if (!showHeader) ...[
              Text(
                'Chào mừng trở lại',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Đăng nhập để tiếp tục công việc trong ngày.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 30),
            ],
            _buildForm(),
            const SizedBox(height: 20),
            _buildLoginButton(),
            const SizedBox(height: 8),
            _buildForgotPassword(),
            const SizedBox(height: 22),
            _buildDemoAccounts(),
          ],
        ),
      ),
    );
  }

  Widget _buildBrandPanel() {
    return Container(
      margin: const EdgeInsets.all(18),
      padding: const EdgeInsets.all(56),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF123B9A), Color(0xFF2764E7), Color(0xFF2397C7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 66,
            height: 66,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .16),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.school_rounded,
              color: Colors.white,
              size: 36,
            ),
          ),
          const SizedBox(height: 34),
          const Text(
            'Một ứng dụng.\nCả trường học.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 42,
              height: 1.08,
              fontWeight: FontWeight.w800,
              letterSpacing: -1.2,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Lịch học, điểm danh, bài tập, kết quả, tài chính và trao đổi được đồng bộ an toàn theo thời gian thực.',
            style: TextStyle(color: Colors.white70, fontSize: 16, height: 1.55),
          ),
          const SizedBox(height: 36),
          const Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _BrandChip(Icons.bolt_rounded, 'Nhanh chóng'),
              _BrandChip(Icons.shield_outlined, 'Bảo mật'),
              _BrandChip(Icons.sync_rounded, 'Đồng bộ'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Icon(
            Icons.school_rounded,
            color: Colors.white,
            size: 40,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Trường học số',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
        Text(
          'Đăng nhập để tiếp tục',
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _usernameCtrl,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Tên đăng nhập',
              prefixIcon: Icon(Icons.person_outline_rounded),
            ),
            validator: (v) => (v == null || v.trim().isEmpty)
                ? 'Vui lòng nhập tên đăng nhập'
                : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _passwordCtrl,
            obscureText: _obscure,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _submit(),
            decoration: InputDecoration(
              labelText: 'Mật khẩu',
              prefixIcon: const Icon(Icons.lock_outline_rounded),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscure
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                ),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
            validator: (v) =>
                (v == null || v.isEmpty) ? 'Vui lòng nhập mật khẩu' : null,
          ),
        ],
      ),
    );
  }

  Widget _buildLoginButton() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final loading = state is AuthLoading;
        return SizedBox(
          height: 50,
          child: ElevatedButton(
            onPressed: loading ? null : _submit,
            child: loading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text('Đăng nhập'),
          ),
        );
      },
    );
  }

  Widget _buildForgotPassword() {
    return Align(
      alignment: Alignment.center,
      child: TextButton(
        onPressed: () => context.push('/forgot-password'),
        child: const Text('Quên mật khẩu?'),
      ),
    );
  }

  Widget _buildDemoAccounts() {
    if (!_showDemoAccounts) return const SizedBox.shrink();
    const accounts = [
      (
        'Quản trị',
        String.fromEnvironment('DEMO_ADMIN_USERNAME', defaultValue: 'admin'),
        String.fromEnvironment(
          'DEMO_ADMIN_PASSWORD',
          defaultValue: 'admin@123',
        ),
        AppColors.adminAccent,
      ),
      (
        'Giáo viên',
        String.fromEnvironment('DEMO_TEACHER_USERNAME', defaultValue: 'gv.hoa'),
        String.fromEnvironment(
          'DEMO_TEACHER_PASSWORD',
          defaultValue: 'teacher@123',
        ),
        AppColors.teacherAccent,
      ),
      (
        'Học sinh',
        String.fromEnvironment('DEMO_STUDENT_USERNAME', defaultValue: 'hs.an'),
        String.fromEnvironment(
          'DEMO_STUDENT_PASSWORD',
          defaultValue: 'student@123',
        ),
        AppColors.studentAccent,
      ),
      (
        'Phụ huynh',
        String.fromEnvironment('DEMO_PARENT_USERNAME', defaultValue: 'ph.pham'),
        String.fromEnvironment(
          'DEMO_PARENT_PASSWORD',
          defaultValue: 'parent@123',
        ),
        AppColors.parentAccent,
      ),
    ];
    final configured = accounts
        .where((account) => account.$2.isNotEmpty && account.$3.isNotEmpty)
        .toList();
    if (configured.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        const SizedBox(height: 12),
        const Text(
          'Đăng nhập nhanh',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: configured.map((a) {
            final (label, user, pass, color) = a;
            return ActionChip(
              backgroundColor: Colors.white,
              side: const BorderSide(color: AppColors.divider),
              label: Text(
                label,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              avatar: CircleAvatar(
                backgroundColor: color,
                radius: 8,
                child: Text(
                  label[0],
                  style: const TextStyle(color: Colors.white, fontSize: 8),
                ),
              ),
              onPressed: () {
                _usernameCtrl.text = user;
                _passwordCtrl.text = pass;
                _submit();
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _BrandChip extends StatelessWidget {
  const _BrandChip(this.icon, this.label);
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .13),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
