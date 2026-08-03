import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/app_theme.dart';
import '../../app/session.dart';
import '../../core/widgets/glass_ui.dart';
import '../profile/account_settings_screens.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final formKey = GlobalKey<FormState>();
  final username = TextEditingController();
  final password = TextEditingController();
  bool obscure = true;

  @override
  void dispose() {
    username.dispose();
    password.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    if (!formKey.currentState!.validate()) return;
    await context.read<AppSession>().login(username.text, password.text);
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<AppSession>();
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 850;
            final form = _LoginForm(
              formKey: formKey,
              username: username,
              password: password,
              obscure: obscure,
              loading: session.status == SessionStatus.signingIn,
              error: session.error,
              onTogglePassword: () => setState(() => obscure = !obscure),
              onSubmit: submit,
            );
            if (wide) {
              return Row(
                children: [
                  const Expanded(flex: 11, child: _BrandPanel()),
                  Expanded(
                    flex: 9,
                    child: Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(48),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 430),
                          child: form,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }
            return Stack(
              children: [
                const Positioned(
                  left: -110,
                  right: -110,
                  top: -230,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Color(0xFF143A92), AppPalette.blue],
                      ),
                    ),
                    child: SizedBox(height: 440),
                  ),
                ),
                SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 54, 20, 30),
                  child: Column(
                    children: [
                      const _MobileBrand(),
                      const SizedBox(height: 28),
                      form,
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _LoginForm extends StatelessWidget {
  const _LoginForm({
    required this.formKey,
    required this.username,
    required this.password,
    required this.obscure,
    required this.loading,
    required this.error,
    required this.onTogglePassword,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController username;
  final TextEditingController password;
  final bool obscure;
  final bool loading;
  final String? error;
  final VoidCallback onTogglePassword;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) => GlassPanel(
    blur: 28,
    opacity: .78,
    padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
    child: Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Chào mừng trở lại',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 6),
          Text(
            'Đăng nhập để bắt đầu ngày làm việc.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          if (error != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.errorContainer.withValues(alpha: .6),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                error!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onErrorContainer,
                ),
              ),
            ),
          ],
          const SizedBox(height: 26),
          TextFormField(
            controller: username,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.username],
            decoration: const InputDecoration(
              labelText: 'Tên đăng nhập',
              prefixIcon: Icon(Icons.person_outline_rounded),
            ),
            validator: (value) => value == null || value.trim().isEmpty
                ? 'Vui lòng nhập tên đăng nhập'
                : null,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: password,
            obscureText: obscure,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.password],
            onFieldSubmitted: (_) => onSubmit(),
            decoration: InputDecoration(
              labelText: 'Mật khẩu',
              prefixIcon: const Icon(Icons.lock_outline_rounded),
              suffixIcon: IconButton(
                tooltip: obscure ? 'Hiện mật khẩu' : 'Ẩn mật khẩu',
                onPressed: onTogglePassword,
                icon: Icon(
                  obscure
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                ),
              ),
            ),
            validator: (value) => value == null || value.isEmpty
                ? 'Vui lòng nhập mật khẩu'
                : null,
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: loading ? null : onSubmit,
            child: loading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Đăng nhập'),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
            ),
            child: const Text('Quên mật khẩu?'),
          ),
        ],
      ),
    ),
  );
}

class _BrandPanel extends StatelessWidget {
  const _BrandPanel();

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.all(18),
    clipBehavior: Clip.antiAlias,
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(34)),
    child: Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          'assets/illustrations/school-community-hero.png',
          fit: BoxFit.cover,
        ),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xF20B2450), Color(0xC8144A82), Color(0x3316A3C8)],
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.all(58),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Logo(size: 68),
              SizedBox(height: 34),
              Text(
                'Một ứng dụng.\nCả trường học.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 43,
                  height: 1.06,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1.25,
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Học tập, vận hành, tài chính và trao đổi được kết nối an toàn trong cùng một không gian.',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  height: 1.55,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _MobileBrand extends StatelessWidget {
  const _MobileBrand();

  @override
  Widget build(BuildContext context) => const Column(
    children: [
      _Logo(size: 64),
      SizedBox(height: 14),
      Text(
        'Trường học số',
        style: TextStyle(
          color: Colors.white,
          fontSize: 25,
          fontWeight: FontWeight.w800,
        ),
      ),
      SizedBox(height: 4),
      Text('Kết nối để cùng tiến bộ', style: TextStyle(color: Colors.white70)),
    ],
  );
}

class _Logo extends StatelessWidget {
  const _Logo({required this.size});
  final double size;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: .16),
      borderRadius: BorderRadius.circular(size * .28),
      border: Border.all(color: Colors.white24),
    ),
    child: Icon(Icons.school_rounded, color: Colors.white, size: size * .52),
  );
}
