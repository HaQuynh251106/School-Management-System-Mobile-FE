import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/login_screen.dart';
import '../features/home/role_home_screen.dart';
import 'session.dart';

class AppRouter {
  AppRouter(this.session);
  final AppSession session;

  late final GoRouter config = GoRouter(
    initialLocation: '/',
    refreshListenable: session,
    redirect: (context, state) {
      final signedIn = session.status == SessionStatus.signedIn;
      final atLogin = state.matchedLocation == '/login';
      if (!signedIn && !atLogin && session.status != SessionStatus.booting) {
        return '/login';
      }
      if (signedIn && atLogin) return '/';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/',
        builder: (context, state) => session.status == SessionStatus.booting
            ? const _BootScreen()
            : const RoleHomeScreen(),
      ),
    ],
  );
}

class _BootScreen extends StatelessWidget {
  const _BootScreen();

  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: CircularProgressIndicator()));
}
