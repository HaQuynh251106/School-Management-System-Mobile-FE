import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light => _build(
        ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.light,
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          surface: const Color(0xFFFDFEFF),
          error: AppColors.error,
        ),
      );

  static ThemeData get dark => _build(
        ColorScheme.fromSeed(
          seedColor: AppColors.primaryLight,
          brightness: Brightness.dark,
          primary: const Color(0xFF8DB9FF),
          secondary: const Color(0xFF65D9C7),
          surface: const Color(0xFF121B2B),
          error: const Color(0xFFFFB4AB),
        ),
      );

  static ThemeData _build(ColorScheme colors) {
    final dark = colors.brightness == Brightness.dark;
    final background = dark ? const Color(0xFF09111F) : const Color(0xFFF3F7FC);
    final outline = dark ? const Color(0xFF26354D) : const Color(0xFFDCE5F2);
    final appBarBackground = dark ? const Color(0xFF121B2B) : colors.primary;
    final appBarForeground = dark ? colors.onSurface : Colors.white;
    final textTheme = Typography.material2021(
      platform: TargetPlatform.android,
      colorScheme: colors,
    ).black.apply(
          bodyColor: colors.onSurface,
          displayColor: colors.onSurface,
          fontFamily: 'Roboto',
        );

    return ThemeData(
      useMaterial3: true,
      brightness: colors.brightness,
      colorScheme: colors,
      scaffoldBackgroundColor: background,
      fontFamily: 'Roboto',
      textTheme: textTheme.copyWith(
        displaySmall: textTheme.displaySmall?.copyWith(
          fontSize: 30,
          fontWeight: FontWeight.w800,
          height: 1.16,
          letterSpacing: -0.8,
        ),
        headlineLarge: textTheme.headlineLarge?.copyWith(
          fontSize: 27,
          fontWeight: FontWeight.w800,
          height: 1.2,
          letterSpacing: -0.55,
        ),
        headlineMedium: textTheme.headlineMedium?.copyWith(
          fontSize: 23,
          fontWeight: FontWeight.w700,
          height: 1.25,
          letterSpacing: -0.4,
        ),
        titleLarge: textTheme.titleLarge?.copyWith(
          fontSize: 19,
          fontWeight: FontWeight.w700,
          height: 1.3,
          letterSpacing: -0.25,
        ),
        titleMedium: textTheme.titleMedium?.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          height: 1.35,
        ),
        bodyLarge: textTheme.bodyLarge?.copyWith(fontSize: 16, height: 1.5),
        bodyMedium: textTheme.bodyMedium?.copyWith(fontSize: 14, height: 1.45),
        labelLarge: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: appBarBackground,
        foregroundColor: appBarForeground,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 1,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: appBarForeground,
          fontSize: 20,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.3,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shadowColor: Colors.black.withValues(alpha: dark ? .22 : .07),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: outline),
        ),
        color: colors.surface,
        margin: EdgeInsets.zero,
      ),
      listTileTheme: ListTileThemeData(
        textColor: colors.onSurface,
        iconColor: colors.onSurfaceVariant,
        subtitleTextStyle: TextStyle(color: colors.onSurfaceVariant),
      ),
      iconTheme: IconThemeData(color: colors.onSurfaceVariant),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: dark ? const Color(0xFF172338) : Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        labelStyle: TextStyle(color: colors.onSurfaceVariant),
        hintStyle: TextStyle(color: colors.onSurfaceVariant),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: colors.primary, width: 1.7),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: colors.error),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: colors.onPrimary,
          elevation: 0,
          minimumSize: const Size(48, 52),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 15),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 50),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(48, 50),
          side: BorderSide(color: outline),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        elevation: 0,
        backgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: colors.primaryContainer,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontSize: 11,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w600,
            color: states.contains(WidgetState.selected)
                ? colors.primary
                : colors.onSurfaceVariant,
          ),
        ),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: colors.surface,
        elevation: 0,
        indicatorShape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        selectedIconTheme: IconThemeData(color: colors.primary),
        selectedLabelTextStyle:
            TextStyle(color: colors.primary, fontWeight: FontWeight.w700),
        unselectedLabelTextStyle: TextStyle(color: colors.onSurfaceVariant),
      ),
      chipTheme: ChipThemeData(
        side: BorderSide(color: outline),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: colors.surfaceContainerHigh,
        selectedColor: colors.primaryContainer,
        labelStyle: TextStyle(
          color: colors.onSurface,
          fontWeight: FontWeight.w600,
        ),
      ),
      tabBarTheme: TabBarThemeData(
        dividerColor: Colors.transparent,
        labelColor: colors.onPrimaryContainer,
        unselectedLabelColor: colors.onSurfaceVariant,
        labelStyle: const TextStyle(fontWeight: FontWeight.w700),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
      dividerTheme: DividerThemeData(color: outline, thickness: 1, space: 1),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor:
            dark ? const Color(0xFFE2E8F5) : const Color(0xFF152238),
        contentTextStyle:
            TextStyle(color: dark ? const Color(0xFF152238) : Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: colors.primary),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}
