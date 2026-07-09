import 'package:flutter/material.dart';

/// App theming. Seed-generated Material 3 schemes — a single seed produces the
/// full token set, so we don't hand-maintain 50 colors. Multiple selectable
/// themes are a Settings-phase concern; this is the default ("Tako"-ish blue).
class AppTheme {
  const AppTheme._();

  static const Color _seed = Color(0xFF2979FF);

  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: brightness,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      brightness: brightness,
      scaffoldBackgroundColor: scheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
    );
  }
}
