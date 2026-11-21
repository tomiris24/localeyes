import 'package:flutter/material.dart';

/// Every colour the app paints with, in both themes.
///
/// The tokens are semantic — `canvas`, `surface`, `line`, `ink` — so a screen
/// never has to know whether it is being drawn light or dark. The two
/// instances below hold the values from the design system; widgets read them
/// through `context.palette`, and the whole app follows the phone's
/// appearance setting.
///
/// Fills are flat colours, never gradients: the photographs carry the screen,
/// and a gradient on a card or a button only competes with them.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.brightness,
    required this.canvas,
    required this.surface,
    required this.surfaceHigh,
    required this.line,
    required this.ink,
    required this.inkMuted,
    required this.brand,
    required this.brandDeep,
    required this.brandTint,
    required this.action,
    required this.success,
    required this.warning,
    required this.error,
    required this.star,
    required this.photoScrim,
  });

  final Brightness brightness;

  /// The page itself.
  final Color canvas;

  /// Cards and sheets.
  final Color surface;

  /// Chips, input fills and segmented tracks — one step from a card.
  final Color surfaceHigh;

  final Color line;
  final Color ink;
  final Color inkMuted;

  /// Indigo, the one accent: the selected tab, a link, an active filter.
  final Color brand;

  /// The filled accent, deep enough to carry white text.
  final Color brandDeep;

  /// A wash of the accent behind an icon or a soft chip.
  final Color brandTint;

  /// Secondary buttons and the sticky bars — near-black, or near-white in the
  /// dark theme.
  final Color action;

  final Color success;
  final Color warning;
  final Color error;
  final Color star;

  /// A flat scrim over a photograph, so white type stays readable on any
  /// frame.
  final Color photoScrim;

  static const AppPalette light = AppPalette(
    brightness: Brightness.light,
    canvas: Color(0xFFF8FAFC),
    surface: Color(0xFFFFFFFF),
    surfaceHigh: Color(0xFFF1F5F9),
    line: Color(0xFFE2E8F0),
    ink: Color(0xFF0F172A),
    inkMuted: Color(0xFF64748B),
    brand: Color(0xFF6366F1),
    brandDeep: Color(0xFF4F46E5),
    brandTint: Color(0xFFEEF0FE),
    action: Color(0xFF0F172A),
    success: Color(0xFF10B981),
    warning: Color(0xFFF59E0B),
    error: Color(0xFFEF4444),
    star: Color(0xFFF59E0B),
    photoScrim: Color(0x73000000),
  );

  static const AppPalette dark = AppPalette(
    brightness: Brightness.dark,
    canvas: Color(0xFF0B0B0F),
    surface: Color(0xFF1F2937),
    surfaceHigh: Color(0xFF2A3545),
    line: Color(0xFF334155),
    ink: Color(0xFFF1F5F9),
    inkMuted: Color(0xFF94A3B8),
    brand: Color(0xFF8E97FF),
    brandDeep: Color(0xFF4F46E5),
    brandTint: Color(0xFF262A52),
    action: Color(0xFF4F46E5),
    success: Color(0xFF34D399),
    warning: Color(0xFFFBBF24),
    error: Color(0xFFF87171),
    star: Color(0xFFFBBF24),
    photoScrim: Color(0x8C000000),
  );

  bool get isDark => brightness == Brightness.dark;

  /// What sits on top of [action] and [brandDeep].
  Color get onAction => Colors.white;

  @override
  AppPalette copyWith({Brightness? brightness}) => this;

  /// The two palettes are not blended: the app switches appearance with the
  /// phone, and a half-light card on the way there would only flicker.
  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) =>
      t < 0.5 ? this : (other as AppPalette? ?? this);
}

extension AppPaletteContext on BuildContext {
  /// The colours of the theme in force. Falls back to the light palette for a
  /// widget pumped outside [AppTheme] — a test, usually.
  AppPalette get palette =>
      Theme.of(this).extension<AppPalette>() ?? AppPalette.light;
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

  static const Radius card = Radius.circular(16);

  /// Buttons and chips are capsules.
  static const Radius button = Radius.circular(100);
  static const Radius pill = Radius.circular(100);
  static const BorderRadius buttonAll = BorderRadius.all(button);
  static const BorderRadius cardAll = BorderRadius.all(card);
  static const BorderRadius pillAll = BorderRadius.all(pill);
}

/// How tall the interactive things are, from the design system.
class AppSize {
  AppSize._();

  static const double buttonLarge = 48;
  static const double buttonMedium = 44;
  static const double buttonSmall = 36;
  static const double chip = 32;
  static const double search = 48;
  static const double field = 44;
}

class AppTheme {
  AppTheme._();

  /// Plus Jakarta Sans, shipped with the app as one variable file. The weight
  /// axis is driven by [FontVariation], which is what a variable font needs —
  /// `fontWeight` alone only picks a named instance.
  static const String fontFamily = 'PlusJakartaSans';

  static TextStyle _font(
    double size,
    int weight, {
    required double height,
    required Color color,
  }) => TextStyle(
    fontFamily: fontFamily,
    fontSize: size,
    height: height,
    color: color,
    fontWeight: FontWeight.values[(weight ~/ 100) - 1],
    fontVariations: <FontVariation>[FontVariation('wght', weight.toDouble())],
  );

  static ThemeData light() => _build(AppPalette.light);

  static ThemeData dark() => _build(AppPalette.dark);

  static ThemeData _build(AppPalette palette) {
    final ColorScheme scheme =
        ColorScheme.fromSeed(
          seedColor: palette.brand,
          brightness: palette.brightness,
        ).copyWith(
          primary: palette.brand,
          onPrimary: palette.onAction,
          surface: palette.surface,
          onSurface: palette.ink,
          error: palette.error,
          outlineVariant: palette.line,
        );

    // The scale from the design system: H1 32 / H2 24 / H3 20 semibold,
    // body 16 and 14 regular at 150%, caption 12.
    final TextTheme text = TextTheme(
      headlineMedium: _font(30, 700, height: 1.2, color: palette.ink),
      headlineSmall: _font(24, 600, height: 1.2, color: palette.ink),
      titleLarge: _font(20, 600, height: 1.3, color: palette.ink),
      titleMedium: _font(16, 600, height: 1.3, color: palette.ink),
      titleSmall: _font(14, 600, height: 1.3, color: palette.ink),
      bodyLarge: _font(16, 400, height: 1.5, color: palette.ink),
      bodyMedium: _font(14, 400, height: 1.5, color: palette.inkMuted),
      bodySmall: _font(12, 400, height: 1.4, color: palette.inkMuted),
      labelLarge: _font(14, 500, height: 1.2, color: palette.ink),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: palette.brightness,
      colorScheme: scheme,
      extensions: <ThemeExtension<dynamic>>[palette],
      fontFamily: fontFamily,
      scaffoldBackgroundColor: palette.canvas,
      canvasColor: palette.canvas,
      textTheme: text,
      appBarTheme: AppBarTheme(
        backgroundColor: palette.canvas,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: _font(20, 600, height: 1.3, color: palette.ink),
        iconTheme: IconThemeData(color: palette.ink),
      ),
      dividerTheme: DividerThemeData(
        color: palette.line,
        thickness: 1,
        space: 1,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: palette.brandDeep,
          foregroundColor: palette.onAction,
          disabledBackgroundColor: palette.surfaceHigh,
          disabledForegroundColor: palette.inkMuted,
          elevation: 0,
          minimumSize: const Size(0, AppSize.buttonLarge),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadius.buttonAll,
          ),
          textStyle: _font(
            15,
            600,
            height: 1.2,
            color: palette.onAction,
          ).copyWith(letterSpacing: 0),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: palette.ink,
          backgroundColor: palette.surface,
          minimumSize: const Size(0, AppSize.buttonMedium),
          side: BorderSide(color: palette.line),
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadius.buttonAll,
          ),
          textStyle: _font(
            14,
            600,
            height: 1.2,
            color: palette.ink,
          ).copyWith(letterSpacing: 0),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: palette.brand,
          textStyle: _font(14, 600, height: 1.2, color: palette.brand),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: palette.surface,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedItemColor: palette.brand,
        unselectedItemColor: palette.inkMuted,
        selectedLabelStyle: _font(12, 700, height: 1.2, color: palette.brand),
        unselectedLabelStyle: _font(
          12,
          500,
          height: 1.2,
          color: palette.inkMuted,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: palette.action,
        contentTextStyle: _font(14, 500, height: 1.4, color: palette.onAction),
      ),
      dialogTheme: DialogThemeData(backgroundColor: palette.surface),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: palette.surface,
        surfaceTintColor: Colors.transparent,
      ),
      iconTheme: IconThemeData(color: palette.ink),
      // The design system asks for 200–300 ms, ease-out: Material's newer
      // forward transition is exactly that, on both platforms.
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: <TargetPlatform, PageTransitionsBuilder>{
          TargetPlatform.iOS: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
        },
      ),
    );
  }
}
