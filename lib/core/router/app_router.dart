import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../auth/mobile_role_access.dart';
import '../../features/auth/data/models/user_model.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_event.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/reset_password_page.dart';
import '../../features/auth/presentation/pages/change_password_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/teacher/presentation/pages/teacher_home.dart';
import '../../features/student/presentation/pages/student_home.dart';
import '../../features/parent/presentation/pages/parent_home.dart';

class AppRouter {
  AppRouter(this._authBloc);

  final AuthBloc _authBloc;

  late final GoRouter config = GoRouter(
    initialLocation: '/splash',
    refreshListenable: _GoRouterRefreshBloc(_authBloc),
    redirect: (context, state) {
      final authState = _authBloc.state;
      final atSplash = state.matchedLocation == '/splash';
      final atLogin =
          state.matchedLocation.startsWith('/login') ||
          state.matchedLocation.startsWith('/forgot-password') ||
          state.matchedLocation.startsWith('/reset-password');
      final atPasswordChange = state.matchedLocation == '/change-password';

      if (authState is AuthInitial || authState is AuthLoading) {
        return atSplash ? null : '/splash';
      }
      if (authState is AuthUnauthenticated ||
          authState is AuthLoginFailure ||
          authState is AuthForgotPasswordSent) {
        return atLogin ? null : '/login';
      }
      if (authState is AuthAuthenticated) {
        final home = homeForRole(authState.user);
        if (home == unsupportedMobileRolePath) {
          return state.matchedLocation == unsupportedMobileRolePath
              ? null
              : unsupportedMobileRolePath;
        }
        if (authState.user.passwordChangeRequired) {
          return atPasswordChange ? null : '/change-password';
        }
        if (atSplash || atLogin || atPasswordChange) {
          return home;
        }
        if (mobileRoleHomes.values.contains(state.matchedLocation) &&
            state.matchedLocation != home) {
          return home;
        }
      }
      return null;
    },
    errorBuilder: (_, __) => const _UnsupportedRolePage(),
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashPage()),
      GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
      GoRoute(
        path: '/change-password',
        builder: (_, __) => const ChangePasswordPage(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (_, __) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: '/reset-password',
        builder: (_, state) =>
            ResetPasswordPage(initialToken: state.uri.queryParameters['token']),
      ),
      GoRoute(path: '/teacher', builder: (_, __) => const TeacherHome()),
      GoRoute(path: '/student', builder: (_, __) => const StudentHome()),
      GoRoute(path: '/parent', builder: (_, __) => const ParentHome()),
      GoRoute(
        path: '/unsupported-role',
        builder: (_, __) => const _UnsupportedRolePage(),
      ),
    ],
  );

  static String homeForRole(UserModel user) => homePathForMobileRole(user.role);

  void dispose() => config.dispose();
}

class _UnsupportedRolePage extends StatelessWidget {
  const _UnsupportedRolePage();

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Sử dụng phiên bản Web')),
    body: SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.computer_rounded, size: 48),
              const SizedBox(height: 16),
              const Text(
                unsupportedMobileRoleMessage,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () =>
                    context.read<AuthBloc>().add(const AuthLogoutRequested()),
                child: const Text('Đăng xuất'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _GoRouterRefreshBloc extends ChangeNotifier {
  _GoRouterRefreshBloc(AuthBloc bloc) {
    _subscription = bloc.stream.listen((_) => notifyListeners());
  }

  late final dynamic _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
