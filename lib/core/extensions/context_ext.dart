import 'package:flutter/material.dart';

/// Ambient theme/media accessors used across the app per the widget rules —
/// inline `context.colorScheme` / `context.width` inside returned trees.
extension ContextX on BuildContext {
  /// The active [ThemeData].
  ThemeData get theme => Theme.of(this);

  /// The active [ColorScheme] (Material 3 tokens).
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  /// The active [TextTheme].
  TextTheme get textTheme => Theme.of(this).textTheme;

  /// Screen width — used in place of `double.infinity` for full-width sizing.
  double get width => MediaQuery.sizeOf(this).width;

  /// Screen height — used in place of `double.infinity` for full-height sizing.
  double get height => MediaQuery.sizeOf(this).height;

  /// Whether the current theme brightness is dark.
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  /// Whether the ambient text direction is right-to-left.
  bool get isRtl => Directionality.of(this) == TextDirection.rtl;
}
