import 'package:flutter/material.dart';

/// Palette of LocalEyes: a neutral interface with one accent.
///
/// Deep teal stays the brand colour, but it is now spent only where it means
/// something — icons, links, active states, verified badges. Everything that
/// used to be a wash of pale mint is a cool grey instead, and the primary
/// buttons are near-black, which keeps a photo-heavy feed calm and reads as
/// current rather than as a 2018 teal app.
///
/// White on [action] gives 16:1, white on [brand] gives 5.5:1 and [brand] on
/// [surface] gives 4.8:1, so every pair passes WCAG AA.
///
/// [success] is the same teal on purpose. A separate green next to a green
/// brand stops reading as a signal, so the verified badge and the "free
/// today" pill borrow the accent rather than competing with it.
class AppColors {
  AppColors._();

  static const Color brand = Color(0xFF0F766E);
  static const Color brandDeep = Color(0xFF115E59);

  /// Pale teal wash behind an accent icon — the only tinted fill left.
  static const Color brandTint = Color(0xFFE4F0EE);

  /// Primary buttons and anything that has to win the page.
  static const Color action = Color(0xFF111827);

  static const Color ink = Color(0xFF111827);
  static const Color inkMuted = Color(0xFF6B7280);
  static const Color canvas = Color(0xFFF6F7F9);

  /// Fills that sit on [canvas]: segmented tracks, chips, input backgrounds.
  static const Color surface = Color(0xFFECEEF2);

  static const Color line = Color(0xFFE2E5EA);
  static const Color star = Color(0xFFF5A623);
  static const Color success = Color(0xFF0F766E);
}

/// Shared spacing and radius values, so every screen uses the same rhythm.
class AppSpacing {
  AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;

  /// Screens never go wider than this, so the layout stays readable on tablets.
  static const double maxContentWidth = 1120;

  /// Below this width we use one column, above it two columns.
  static const double wideBreakpoint = 840;
}

class AppRadius {
  AppRadius._();

  static const Radius card = Radius.circular(20);

  /// Buttons are rounded rectangles, not capsules: a 16 px corner next to a
  /// 20 px card keeps the screen on one rhythm.
  static const Radius button = Radius.circular(16);
  static const BorderRadius buttonAll = BorderRadius.all(button);
  static const Radius pill = Radius.circular(100);
  static const BorderRadius cardAll = BorderRadius.all(card);
  static const BorderRadius pillAll = BorderRadius.all(pill);
}

class AppTheme {
  AppTheme._();

  static ThemeData light() {
    final ColorScheme scheme = ColorScheme.fromSeed(seedColor: AppColors.brand)
        .copyWith(primary: AppColors.brand, surface: Colors.white);

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.canvas,
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w800,
          color: AppColors.ink,
          height: 1.15,
        ),
        headlineSmall: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: AppColors.ink,
          height: 1.2,
        ),
        titleLarge: TextStyle(
          fontSize: 19,
          fontWeight: FontWeight.w700,
          color: AppColors.ink,
          height: 1.25,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.ink,
        ),
        titleSmall: TextStyle(
          fontSize: 13.5,
          fontWeight: FontWeight.w600,
          color: AppColors.ink,
        ),
        bodyLarge: TextStyle(fontSize: 15, height: 1.5, color: AppColors.ink),
        bodyMedium: TextStyle(
          fontSize: 13.5,
          height: 1.45,
          color: AppColors.inkMuted,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          height: 1.4,
          color: AppColors.inkMuted,
        ),
        labelLarge: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.canvas,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 19,
          fontWeight: FontWeight.w700,
          color: AppColors.ink,
        ),
        iconTheme: IconThemeData(color: AppColors.ink),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.line,
        thickness: 1,
        space: 1,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.action,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.surface,
          disabledForegroundColor: AppColors.inkMuted,
          elevation: 0,
          minimumSize: const Size(0, 52),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadius.buttonAll,
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.ink,
          minimumSize: const Size(0, 48),
          side: const BorderSide(color: AppColors.line),
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadius.buttonAll,
          ),
          textStyle: const TextStyle(
            fontSize: 14.5,
            fontWeight: FontWeight.w600,
            letterSpacing: 0,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.brand,
          textStyle: const TextStyle(
            fontSize: 14.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      // The root screen uses a classic BottomNavigationBar, so its colours
      // are set here once instead of on every tab.
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedItemColor: AppColors.brand,
        unselectedItemColor: AppColors.inkMuted,
        selectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.action,
        contentTextStyle: TextStyle(color: Colors.white, fontSize: 14),
      ),
    );
  }
}
