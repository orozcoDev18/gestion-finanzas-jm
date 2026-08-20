import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Light Mode
  static const Color lightBackground = Color(0xFFF2F2F7);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightCardBorder = Color(0xFFE5E5EA);
  static const Color lightTextPrimary = Color(0xFF1C1C1E);
  static const Color lightTextSecondary = Color(0xFF8E8E93);
  static const Color lightDivider = Color(0xFFC6C6C8);

  // Dark Mode
  static const Color darkBackground = Color(0xFF000000);
  static const Color darkCard = Color(0xFF1C1C1E);
  static const Color darkCardBorder = Color(0xFF38383A);
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFF8E8E93);
  static const Color darkDivider = Color(0xFF48484A);

  // Primary Colors
  static const Color primary = Color(0xFF007AFF);
  static const Color primaryDark = Color(0xFF0A84FF);

  // Semantic Colors
  static const Color success = Color(0xFF34C759);
  static const Color successDark = Color(0xFF30D158);
  static const Color danger = Color(0xFFFF3B30);
  static const Color dangerDark = Color(0xFFFF453A);
  static const Color warning = Color(0xFFFF9500);
  static const Color warningDark = Color(0xFFFF9F0A);
  static const Color purple = Color(0xFFAF52DE);
  static const Color purpleDark = Color(0xFFBF5AF2);
  static const Color teal = Color(0xFF5AC8FA);
  static const Color tealDark = Color(0xFF64D2FF);
  static const Color pink = Color(0xFFFF2D55);
  static const Color pinkDark = Color(0xFFFF375F);
  static const Color orange = Color(0xFFFF9500);
  static const Color orangeDark = Color(0xFFFF9F0A);

  // Glass Colors
  static Color glassLight = Colors.white.withValues(alpha: 0.7);
  static Color glassDark = const Color(0xFF1C1C1E).withValues(alpha: 0.7);

  // Gradient for cards
  static LinearGradient get gradientLight => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFFFFFFF), Color(0xFFF2F2F7)],
      );

  static LinearGradient get gradientDark => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF2C2C2E), Color(0xFF1C1C1E)],
      );

  static const List<Color> chartColors = [
    Color(0xFF007AFF),
    Color(0xFFFF3B30),
    Color(0xFF34C759),
    Color(0xFFFF9500),
    Color(0xFFAF52DE),
    Color(0xFF5AC8FA),
    Color(0xFFFF2D55),
    Color(0xFF00C7BE),
  ];
}
