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
        builder: (context, child) => _MobileAppFrame(child: child),
        routerConfig: _router.config,
      ),
    );
  }
}

/// Mobile FE luôn giữ ngôn ngữ bố cục điện thoại. Trên màn hình rộng (bản Web
/// preview hoặc macOS) ứng dụng được đặt trong một khung 390 px thay vì tự biến
/// thành dashboard desktop. Trên điện thoại thật widget không can thiệp.
class _MobileAppFrame extends StatelessWidget {
  const _MobileAppFrame({required this.child});

  static const double _maxPhoneWidth = 390;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    if (mediaQuery.size.width <= 430) return child ?? const SizedBox.shrink();

    final colors = Theme.of(context).colorScheme;
    final phonePadding = mediaQuery.padding.copyWith(
      top: mediaQuery.padding.top == 0 ? 10 : mediaQuery.padding.top,
      bottom: mediaQuery.padding.bottom == 0 ? 8 : mediaQuery.padding.bottom,
    );
    final phoneViewPadding = mediaQuery.viewPadding.copyWith(
      top: mediaQuery.viewPadding.top == 0 ? 10 : mediaQuery.viewPadding.top,
      bottom: mediaQuery.viewPadding.bottom == 0
          ? 8
          : mediaQuery.viewPadding.bottom,
    );
    final phoneMediaQuery = mediaQuery.copyWith(
      size: Size(_maxPhoneWidth, mediaQuery.size.height),
      padding: phonePadding,
      viewPadding: phoneViewPadding,
    );

    return ColoredBox(
      color: colors.surfaceContainerLowest,
      child: Center(
        child: Container(
          width: _maxPhoneWidth,
          height: mediaQuery.size.height,
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: colors.outlineVariant),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .14),
                blurRadius: 36,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: MediaQuery(
            data: phoneMediaQuery,
            child: child ?? const SizedBox.shrink(),
          ),
        ),
      ),
    );
  }
}
