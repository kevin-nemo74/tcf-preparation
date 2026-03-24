import 'package:flutter/material.dart';

class AppTheme {
  static const Color _seedTeal = Color(0xFF0E6B72);
  static const Color _accentAmber = Color(0xFFE7A537);
  static const Color _lightBg = Color(0xFFF5F7F8);
  static const Color _darkBg = Color(0xFF0E1419);

  static ThemeData light() {
    final baseScheme = ColorScheme.fromSeed(
      seedColor: _seedTeal,
      brightness: Brightness.light,
    );
    final scheme = baseScheme.copyWith(
      secondary: _accentAmber,
      onSecondary: const Color(0xFF1C1508),
      tertiary: const Color(0xFF5F8F95),
      surface: const Color(0xFFFFFDFA),
    );

    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: scheme,
      splashFactory: InkSparkle.splashFactory,
      pageTransitionsTheme: _pageTransitions,
    );

    return base.copyWith(
      scaffoldBackgroundColor: _lightBg,
      cardTheme: CardThemeData(
        color: scheme.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.35)),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          fontSize: 21,
          fontWeight: FontWeight.w800,
          color: scheme.onSurface,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
      ),
      textTheme: _textTheme(base.textTheme, scheme.onSurface),
    );
  }

  static ThemeData dark() {
    final baseScheme = ColorScheme.fromSeed(
      seedColor: _seedTeal,
      brightness: Brightness.dark,
    );
    final scheme = baseScheme.copyWith(
      secondary: _accentAmber,
      onSecondary: const Color(0xFF1C1508),
      surface: const Color(0xFF131C24),
    );

    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      splashFactory: InkSparkle.splashFactory,
      pageTransitionsTheme: _pageTransitions,
    );

    return base.copyWith(
      scaffoldBackgroundColor: _darkBg,
      cardTheme: CardThemeData(
        color: scheme.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.35)),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          fontSize: 21,
          fontWeight: FontWeight.w800,
          color: scheme.onSurface,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
      ),
      textTheme: _textTheme(base.textTheme, scheme.onSurface),
    );
  }

  static final PageTransitionsTheme _pageTransitions = PageTransitionsTheme(
    builders: {
      TargetPlatform.android: const FadeUpwardsPageTransitionsBuilder(),
      TargetPlatform.iOS: const CupertinoPageTransitionsBuilder(),
      TargetPlatform.macOS: const CupertinoPageTransitionsBuilder(),
      TargetPlatform.linux: const FadeUpwardsPageTransitionsBuilder(),
      TargetPlatform.windows: const FadeUpwardsPageTransitionsBuilder(),
      TargetPlatform.fuchsia: const FadeUpwardsPageTransitionsBuilder(),
    },
  );

  static TextTheme _textTheme(TextTheme base, Color onSurface) {
    return base.copyWith(
      headlineSmall: base.headlineSmall?.copyWith(
        fontWeight: FontWeight.w800,
        letterSpacing: -0.3,
        height: 1.2,
      ),
      titleLarge: base.titleLarge?.copyWith(fontWeight: FontWeight.w800),
      titleMedium: base.titleMedium?.copyWith(fontWeight: FontWeight.w700),
      bodyLarge: base.bodyLarge?.copyWith(
        fontSize: 16,
        height: 1.45,
        fontWeight: FontWeight.w500,
        color: onSurface.withValues(alpha: 0.92),
      ),
      bodyMedium: base.bodyMedium?.copyWith(
        height: 1.42,
        fontWeight: FontWeight.w500,
        color: onSurface.withValues(alpha: 0.88),
      ),
    );
  }
}
