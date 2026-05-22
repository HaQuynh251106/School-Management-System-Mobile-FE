import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/data/models/user_model.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/admin/presentation/pages/admin_home.dart';
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
      final atLogin = state.matchedLocation.startsWith('/login') ||
          state.matchedLocation.startsWith('/forgot-password');

      if (authState is AuthInitial || authState is AuthLoading) {
        return atSplash ? null : '/splash';
      }
      if (authState is AuthUnauthenticated || authState is AuthLoginFailure) {
        return atLogin ? null : '/login';
      }
      if (authState is AuthAuthenticated) {
        if (atSplash || atLogin) {
          return _homeForRole(authState.user);
        }
      }
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashPage()),
      GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
      GoRoute(
        path: '/forgot-password',
        builder: (_, __) => const ForgotPasswordPage(),
      ),
      GoRoute(path: '/admin', builder: (_, __) => const AdminHome()),
      GoRoute(path: '/teacher', builder: (_, __) => const TeacherHome()),
      GoRoute(path: '/student', builder: (_, __) => const StudentHome()),
      GoRoute(path: '/parent', builder: (_, __) => const ParentHome()),
    ],
  );

  String _homeForRole(UserModel user) {
    switch (user.role) {
      case 'ADMIN':
        return '/admin';
      case 'TEACHER':
        return '/teacher';
      case 'PARENT':
        return '/parent';
      default:
        return '/student';
    }
  }

  void dispose() => config.dispose();
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
