import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Brand tokens shared by all four product roles. Role-specific colors made
  // the same action look unrelated between Admin, Teacher, Student and Parent.
  static const primary = Color(0xFF0F766E);
  static const primaryDark = Color(0xFF115E59);
  static const primaryLight = Color(0xFF5EEAD4);
  static const secondary = Color(0xFF0D9488);
  static const error = Color(0xFFDC2626);
  static const warning = Color(0xFFD97706);
  static const success = Color(0xFF15803D);
  static const surface = Color(0xFFFFFFFF);
  static const background = Color(0xFFF4F8F7);
  static const onPrimary = Color(0xFFFFFFFF);
  static const textPrimary = Color(0xFF163633);
  static const textSecondary = Color(0xFF526A67);
  static const divider = Color(0xFFD7E5E3);

  /// Role colors are deliberately dark in the light theme. On a dark surface
  /// the same constants lose contrast, so shared widgets use the theme's
  /// brighter primary color instead.
  static Color adaptiveAccent(BuildContext context, Color lightAccent) =>
      Theme.of(context).brightness == Brightness.dark
      ? Theme.of(context).colorScheme.primary
      : lightAccent;

  /// Semantic colors need lighter variants on dark surfaces. Keeping the
  /// light-theme green/orange/red values makes scores and status badges fade
  /// into the background.
  static Color adaptiveSemantic(BuildContext context, Color lightColor) {
    if (Theme.of(context).brightness != Brightness.dark) return lightColor;
    if (lightColor == success) return const Color(0xFF4ADE80);
    if (lightColor == warning) return const Color(0xFFFBBF24);
    if (lightColor == error) return const Color(0xFFFF6B6B);
    if (lightColor == late) return const Color(0xFFFACC15);
    if (lightColor == primary || lightColor == secondary) return primaryLight;
    return Theme.of(context).colorScheme.primary;
  }

  static const adminAccent = primaryDark;
  static const academicStaffAccent = primaryDark;
  static const accountantAccent = Color(0xFF0F766E);
  static const teacherAccent = primary;
  static const studentAccent = Color(0xFF0E7490);
  static const parentAccent = Color(0xFF0F766E);

  // Attendance status colors
  static const present = success;
  static const absentExcused = warning;
  static const absentUnexcused = error;
  static const late = Color(0xFFCA8A04);
}
