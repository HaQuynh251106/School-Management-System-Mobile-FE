import 'package:flutter/material.dart';

class AppPalette {
  const AppPalette._();
  static const blue = Color(0xFF386BFF);
  static const navy = Color(0xFF071A35);
  static const teal = Color(0xFF00A991);
  static const violet = Color(0xFF8255F5);
  static const orange = Color(0xFFFF9D3D);
  static const red = Color(0xFFEF5366);
  static const cyan = Color(0xFF18BCEB);

  static Color role(String role) => switch (role) {
    'ADMIN' => const Color(0xFF5B63F5),
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
      seedColor: dark ? const Color(0xFF8CB2FF) : AppPalette.blue,
      brightness: brightness,
      surface: dark ? const Color(0xFF13223A) : const Color(0xFFFDFEFF),
    );
    final border = dark ? const Color(0xFF26354B) : const Color(0xFFDDE3ED);
    final surface = dark ? const Color(0xFF141E2F) : Colors.white;
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colors,
      scaffoldBackgroundColor: dark
          ? const Color(0xFF101722)
          : const Color(0xFFF5F7FA),
      fontFamily: 'Roboto',
      textTheme:
          (dark
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
        scrolledUnderElevation: 0,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
        backgroundColor: dark ? const Color(0xFF182230) : Colors.white,
        foregroundColor: colors.onSurface,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: colors.onSurface,
          letterSpacing: -.3,
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: border),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: dark ? const Color(0xFF111B2B) : const Color(0xFFF8FAFD),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.primary, width: 1.8),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 52),
          elevation: 0,
          shadowColor: colors.primary.withValues(alpha: .28),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 76,
        elevation: 0,
        backgroundColor: surface,
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
        backgroundColor: surface,
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
        backgroundColor: dark
            ? const Color(0xFF20314D)
            : const Color(0xFF102A56),
        contentTextStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      dividerTheme: DividerThemeData(color: border),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: dark
            ? const Color(0xEB14243D)
            : const Color(0xEEFFFFFF),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: dark
            ? const Color(0xFF172235)
            : const Color(0xFFF5F7FA),
        selectedColor: colors.primary.withValues(alpha: .16),
        side: BorderSide(color: border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        labelStyle: const TextStyle(fontWeight: FontWeight.w700),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 1,
        highlightElevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      searchBarTheme: SearchBarThemeData(
        backgroundColor: WidgetStatePropertyAll(surface),
        surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
        elevation: const WidgetStatePropertyAll(0),
        side: WidgetStatePropertyAll(BorderSide(color: border)),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
