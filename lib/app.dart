import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/di/service_locator.dart';
import 'core/theme/theme_controller.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/auth/presentation/bloc/auth_state.dart';

class SseApp extends StatefulWidget {
  const SseApp({super.key});

  @override
  State<SseApp> createState() => _SseAppState();
}

class _SseAppState extends State<SseApp> {
  late final AppRouter _router;

  @override
  void initState() {
    super.initState();
    final authBloc = context.read<AuthBloc>();
    _router = AppRouter(authBloc);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && authBloc.state is AuthInitial) {
        authBloc.add(const AuthStarted());
      }
    });
  }

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: sl<ThemeController>(),
      builder: (context, _) => MaterialApp.router(
        title: 'Trường học số',
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: sl<ThemeController>().mode,
        debugShowCheckedModeBanner: false,
        routerConfig: _router.config,
      ),
    );
  }
}
