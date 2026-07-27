import 'package:flutter/material.dart';

class AppPalette {
  const AppPalette._();
  static const blue = Color(0xFF2864E8);
  static const navy = Color(0xFF0A1730);
  static const teal = Color(0xFF079783);
  static const violet = Color(0xFF7A4CE0);
  static const orange = Color(0xFFF29A38);
  static const red = Color(0xFFE44C5E);

  static Color role(String role) => switch (role) {
    'ADMIN' => const Color(0xFF5261E8),
    'TEACHER' => teal,
    'PARENT' => violet,
    _ => blue,
  };
}

class AppTheme {
  const AppTheme._();

  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    final colors = ColorScheme.fromSeed(
      seedColor: dark ? const Color(0xFF87AEFF) : AppPalette.blue,
      brightness: brightness,
      surface: dark ? const Color(0xFF111C30) : Colors.white,
    );
    final border = dark ? const Color(0xFF273750) : const Color(0xFFDDE6F2);
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colors,
      scaffoldBackgroundColor: dark
          ? const Color(0xFF08111F)
          : const Color(0xFFF3F7FC),
      fontFamily: 'Roboto',
      textTheme: (dark
              ? Typography.material2021(colorScheme: colors).white
              : Typography.material2021(colorScheme: colors).black)
          .copyWith(
        headlineLarge: TextStyle(
          fontSize: 29,
          height: 1.15,
          fontWeight: FontWeight.w800,
          color: colors.onSurface,
          letterSpacing: -.7,
        ),
        headlineMedium: TextStyle(
          fontSize: 23,
          fontWeight: FontWeight.w800,
          color: colors.onSurface,
          letterSpacing: -.4,
        ),
        titleLarge: TextStyle(
          fontSize: 19,
          fontWeight: FontWeight.w800,
          color: colors.onSurface,
        ),
        titleMedium: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: colors.onSurface,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          height: 1.45,
          color: colors.onSurface,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          height: 1.4,
          color: colors.onSurfaceVariant,
        ),
        headlineSmall: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: colors.onSurface,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: colors.onSurface,
        ),
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: .5,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
        backgroundColor: colors.surface,
        foregroundColor: colors.onSurface,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: colors.onSurface,
          letterSpacing: -.3,
        ),
      ),
      cardTheme: CardThemeData(
        color: colors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(21),
          side: BorderSide(color: border),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: dark ? const Color(0xFF17243A) : Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colors.primary, width: 1.8),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        elevation: 0,
        backgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontSize: 11,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w800
                : FontWeight.w600,
          ),
        ),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: colors.surface,
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        selectedLabelTextStyle: TextStyle(
          color: colors.primary,
          fontWeight: FontWeight.w800,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
      dividerTheme: DividerThemeData(color: border),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
    );
  }
}
