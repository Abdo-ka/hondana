import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';

/// Which Material text-theme style to pull from `Theme.of(context).textTheme`.
enum _Kind {
  displayLarge,
  displayMedium,
  displaySmall,
  headlineLarge,
  headlineMedium,
  headlineSmall,
  titleLarge,
  titleMedium,
  titleSmall,
  bodyLarge,
  bodyMedium,
  bodySmall,
  labelLarge,
  labelMedium,
  labelSmall,
}

/// Text primitive. Resolves the style from the active [TextTheme] and
/// translates its content via easy_localization (`text.tr()`), so callers pass
/// LocaleKeys. Shared widgets that already receive translated strings still work
/// because `.tr()` returns the input unchanged when it isn't a known key.
class AppText extends StatelessWidget {
  /// Plain text with no preset style; supply [style] or inherit from context.
  const AppText(
    this.text, {
    super.key,
    this.style,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap,
    this.fontWeight,
    this.decoration,
    this.textDirection,
  }) : _kind = null;

  /// Backing constructor for the named style factories; carries the [_Kind].
  const AppText._kind(
    this.text,
    this._kind, {
    this.style,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap,
    this.fontWeight,
    this.decoration,
    this.textDirection,
    super.key,
  });

  /// LocaleKey (or already-translated string) to display; passed through `.tr()`.
  final String text;
  final TextStyle? style;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final bool? softWrap;
  final FontWeight? fontWeight;
  final TextDecoration? decoration;
  final TextDirection? textDirection;

  /// Selected text-theme style, or null for the plain [AppText] constructor.
  final _Kind? _kind;

  // Named constructors, one per Material text-theme style. Each forwards to
  // [AppText._kind] so the matching [TextTheme] style is resolved at build.
  const AppText.displayLarge(
    String text, {
    Key? key,
    TextStyle? style,
    Color? color,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
    bool? softWrap,
    FontWeight? fontWeight,
    TextDecoration? decoration,
    TextDirection? textDirection,
  }) : this._kind(
         text,
         _Kind.displayLarge,
         key: key,
         style: style,
         color: color,
         textAlign: textAlign,
         maxLines: maxLines,
         overflow: overflow,
         softWrap: softWrap,
         fontWeight: fontWeight,
         decoration: decoration,
         textDirection: textDirection,
       );
  const AppText.displayMedium(
    String text, {
    Key? key,
    TextStyle? style,
    Color? color,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
    bool? softWrap,
    FontWeight? fontWeight,
    TextDecoration? decoration,
    TextDirection? textDirection,
  }) : this._kind(
         text,
         _Kind.displayMedium,
         key: key,
         style: style,
         color: color,
         textAlign: textAlign,
         maxLines: maxLines,
         overflow: overflow,
         softWrap: softWrap,
         fontWeight: fontWeight,
         decoration: decoration,
         textDirection: textDirection,
       );
  const AppText.displaySmall(
    String text, {
    Key? key,
    TextStyle? style,
    Color? color,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
    bool? softWrap,
    FontWeight? fontWeight,
    TextDecoration? decoration,
    TextDirection? textDirection,
  }) : this._kind(
         text,
         _Kind.displaySmall,
         key: key,
         style: style,
         color: color,
         textAlign: textAlign,
         maxLines: maxLines,
         overflow: overflow,
         softWrap: softWrap,
         fontWeight: fontWeight,
         decoration: decoration,
         textDirection: textDirection,
       );
  const AppText.headlineLarge(
    String text, {
    Key? key,
    TextStyle? style,
    Color? color,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
    bool? softWrap,
    FontWeight? fontWeight,
    TextDecoration? decoration,
    TextDirection? textDirection,
  }) : this._kind(
         text,
         _Kind.headlineLarge,
         key: key,
         style: style,
         color: color,
         textAlign: textAlign,
         maxLines: maxLines,
         overflow: overflow,
         softWrap: softWrap,
         fontWeight: fontWeight,
         decoration: decoration,
         textDirection: textDirection,
       );
  const AppText.headlineMedium(
    String text, {
    Key? key,
    TextStyle? style,
    Color? color,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
    bool? softWrap,
    FontWeight? fontWeight,
    TextDecoration? decoration,
    TextDirection? textDirection,
  }) : this._kind(
         text,
         _Kind.headlineMedium,
         key: key,
         style: style,
         color: color,
         textAlign: textAlign,
         maxLines: maxLines,
         overflow: overflow,
         softWrap: softWrap,
         fontWeight: fontWeight,
         decoration: decoration,
         textDirection: textDirection,
       );
  const AppText.headlineSmall(
    String text, {
    Key? key,
    TextStyle? style,
    Color? color,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
    bool? softWrap,
    FontWeight? fontWeight,
    TextDecoration? decoration,
    TextDirection? textDirection,
  }) : this._kind(
         text,
         _Kind.headlineSmall,
         key: key,
         style: style,
         color: color,
         textAlign: textAlign,
         maxLines: maxLines,
         overflow: overflow,
         softWrap: softWrap,
         fontWeight: fontWeight,
         decoration: decoration,
         textDirection: textDirection,
       );
  const AppText.titleLarge(
    String text, {
    Key? key,
    TextStyle? style,
    Color? color,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
    bool? softWrap,
    FontWeight? fontWeight,
    TextDecoration? decoration,
    TextDirection? textDirection,
  }) : this._kind(
         text,
         _Kind.titleLarge,
         key: key,
         style: style,
         color: color,
         textAlign: textAlign,
         maxLines: maxLines,
         overflow: overflow,
         softWrap: softWrap,
         fontWeight: fontWeight,
         decoration: decoration,
         textDirection: textDirection,
       );
  const AppText.titleMedium(
    String text, {
    Key? key,
    TextStyle? style,
    Color? color,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
    bool? softWrap,
    FontWeight? fontWeight,
    TextDecoration? decoration,
    TextDirection? textDirection,
  }) : this._kind(
         text,
         _Kind.titleMedium,
         key: key,
         style: style,
         color: color,
         textAlign: textAlign,
         maxLines: maxLines,
         overflow: overflow,
         softWrap: softWrap,
         fontWeight: fontWeight,
         decoration: decoration,
         textDirection: textDirection,
       );
  const AppText.titleSmall(
    String text, {
    Key? key,
    TextStyle? style,
    Color? color,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
    bool? softWrap,
    FontWeight? fontWeight,
    TextDecoration? decoration,
    TextDirection? textDirection,
  }) : this._kind(
         text,
         _Kind.titleSmall,
         key: key,
         style: style,
         color: color,
         textAlign: textAlign,
         maxLines: maxLines,
         overflow: overflow,
         softWrap: softWrap,
         fontWeight: fontWeight,
         decoration: decoration,
         textDirection: textDirection,
       );
  const AppText.bodyLarge(
    String text, {
    Key? key,
    TextStyle? style,
    Color? color,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
    bool? softWrap,
    FontWeight? fontWeight,
    TextDecoration? decoration,
    TextDirection? textDirection,
  }) : this._kind(
         text,
         _Kind.bodyLarge,
         key: key,
         style: style,
         color: color,
         textAlign: textAlign,
         maxLines: maxLines,
         overflow: overflow,
         softWrap: softWrap,
         fontWeight: fontWeight,
         decoration: decoration,
         textDirection: textDirection,
       );
  const AppText.bodyMedium(
    String text, {
    Key? key,
    TextStyle? style,
    Color? color,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
    bool? softWrap,
    FontWeight? fontWeight,
    TextDecoration? decoration,
    TextDirection? textDirection,
  }) : this._kind(
         text,
         _Kind.bodyMedium,
         key: key,
         style: style,
         color: color,
         textAlign: textAlign,
         maxLines: maxLines,
         overflow: overflow,
         softWrap: softWrap,
         fontWeight: fontWeight,
         decoration: decoration,
         textDirection: textDirection,
       );
  const AppText.bodySmall(
    String text, {
    Key? key,
    TextStyle? style,
    Color? color,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
    bool? softWrap,
    FontWeight? fontWeight,
    TextDecoration? decoration,
    TextDirection? textDirection,
  }) : this._kind(
         text,
         _Kind.bodySmall,
         key: key,
         style: style,
         color: color,
         textAlign: textAlign,
         maxLines: maxLines,
         overflow: overflow,
         softWrap: softWrap,
         fontWeight: fontWeight,
         decoration: decoration,
         textDirection: textDirection,
       );
  const AppText.labelLarge(
    String text, {
    Key? key,
    TextStyle? style,
    Color? color,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
    bool? softWrap,
    FontWeight? fontWeight,
    TextDecoration? decoration,
    TextDirection? textDirection,
  }) : this._kind(
         text,
         _Kind.labelLarge,
         key: key,
         style: style,
         color: color,
         textAlign: textAlign,
         maxLines: maxLines,
         overflow: overflow,
         softWrap: softWrap,
         fontWeight: fontWeight,
         decoration: decoration,
         textDirection: textDirection,
       );
  const AppText.labelMedium(
    String text, {
    Key? key,
    TextStyle? style,
    Color? color,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
    bool? softWrap,
    FontWeight? fontWeight,
    TextDecoration? decoration,
    TextDirection? textDirection,
  }) : this._kind(
         text,
         _Kind.labelMedium,
         key: key,
         style: style,
         color: color,
         textAlign: textAlign,
         maxLines: maxLines,
         overflow: overflow,
         softWrap: softWrap,
         fontWeight: fontWeight,
         decoration: decoration,
         textDirection: textDirection,
       );
  const AppText.labelSmall(
    String text, {
    Key? key,
    TextStyle? style,
    Color? color,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
    bool? softWrap,
    FontWeight? fontWeight,
    TextDecoration? decoration,
    TextDirection? textDirection,
  }) : this._kind(
         text,
         _Kind.labelSmall,
         key: key,
         style: style,
         color: color,
         textAlign: textAlign,
         maxLines: maxLines,
         overflow: overflow,
         softWrap: softWrap,
         fontWeight: fontWeight,
         decoration: decoration,
         textDirection: textDirection,
       );

  TextStyle? _resolve(TextTheme t) => switch (_kind) {
    null => null,
    _Kind.displayLarge => t.displayLarge,
    _Kind.displayMedium => t.displayMedium,
    _Kind.displaySmall => t.displaySmall,
    _Kind.headlineLarge => t.headlineLarge,
    _Kind.headlineMedium => t.headlineMedium,
    _Kind.headlineSmall => t.headlineSmall,
    _Kind.titleLarge => t.titleLarge,
    _Kind.titleMedium => t.titleMedium,
    _Kind.titleSmall => t.titleSmall,
    _Kind.bodyLarge => t.bodyLarge,
    _Kind.bodyMedium => t.bodyMedium,
    _Kind.bodySmall => t.bodySmall,
    _Kind.labelLarge => t.labelLarge,
    _Kind.labelMedium => t.labelMedium,
    _Kind.labelSmall => t.labelSmall,
  };

  @override
  Widget build(BuildContext context) {
    return Text(
      text.tr(),
      style: (_resolve(Theme.of(context).textTheme) ?? const TextStyle())
          .merge(style)
          .copyWith(
            color: color,
            fontWeight: fontWeight,
            decoration: decoration,
          ),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      softWrap: softWrap,
      textDirection: textDirection,
    );
  }
}
