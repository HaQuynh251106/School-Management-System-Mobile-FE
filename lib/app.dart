import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';

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
    _router = AppRouter(context.read<AuthBloc>());
  }

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Smart School',
      theme: AppTheme.light,
      debugShowCheckedModeBanner: false,
      routerConfig: _router.config,
    );
  }
}
