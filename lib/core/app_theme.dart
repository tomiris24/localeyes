import 'package:flutter/material.dart';

/// Brand palette of LocalEyes. Deep teal is the brand colour, pale teal is
/// the accent it sits on.
///
/// Teal rather than the blue every booking brand already owns: it keeps the
/// trust blue reads as, picks up the water and forest in the photography
/// instead of fighting it, and carries no loaded meaning in any of the
/// markets the app is headed for.
///
/// White on [brand] gives 5.5:1, [brand] on [canvas] gives 5.0:1 and
/// [brandSoft] on [ink] gives 13:1, so every pair passes WCAG AA.
///
/// [success] is the same teal on purpose. A separate green next to a green
/// brand stops reading as a signal, so the verified badge and the "free
/// today" pill borrow the accent rather than competing with it.
///
/// [canvas] and [line] are deliberately neutral rather than blue-tinted. The
/// feed is wall-to-wall photography, and a tinted background casts its hue
/// over every photo sitting on it — neutral greys let the pictures set the
/// colour of the screen.
class AppColors {
  AppColors._();

  static const Color brand = Color(0xFF0F766E);
  static const Color brandDeep = Color(0xFF115E59);
  static const Color brandSoft = Color(0xFF99F6E4);
  static const Color ink = Color(0xFF141F2F);
  static const Color inkMuted = Color(0xFF687586);
  static const Color canvas = Color(0xFFF4F4F5);
  static const Color line = Color(0xFFE7E7EA);
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
  static const Radius pill = Radius.circular(100);
  static const BorderRadius cardAll = BorderRadius.all(card);
  static const BorderRadius pillAll = BorderRadius.all(pill);
}

class AppTheme {
  AppTheme._();

  static ThemeData light() {
    final ColorScheme scheme = ColorScheme.fromSeed(
      seedColor: AppColors.brand,
    ).copyWith(primary: AppColors.brand, surface: Colors.white);

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
          backgroundColor: AppColors.brand,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.line,
          elevation: 0,
          minimumSize: const Size(0, 54),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.pillAll),
          textStyle: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.brand,
          minimumSize: const Size(0, 48),
          side: const BorderSide(color: AppColors.line),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.pillAll),
          textStyle: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600),
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
        selectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
        unselectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.ink,
        contentTextStyle: TextStyle(color: Colors.white, fontSize: 14),
      ),
    );
  }
}
