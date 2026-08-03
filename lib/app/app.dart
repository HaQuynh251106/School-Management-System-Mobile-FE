import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/widgets/glass_ui.dart';
import 'app_router.dart';
import 'app_theme.dart';
import 'session.dart';

class SmartSchoolApp extends StatefulWidget {
  const SmartSchoolApp({super.key});

  @override
  State<SmartSchoolApp> createState() => _SmartSchoolAppState();
}

class _SmartSchoolAppState extends State<SmartSchoolApp> {
  late final AppRouter router;

  @override
  void initState() {
    super.initState();
    router = AppRouter(context.read<AppSession>());
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<AppSession>();
    return MaterialApp.router(
      title: 'Trường học số',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: session.themeMode,
      routerConfig: router.config,
      builder: (context, child) =>
          AppAuroraBackground(child: child ?? const SizedBox.shrink()),
    );
  }
}
