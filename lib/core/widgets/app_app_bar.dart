import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:hondana/core/widgets/app_text.dart';

/// App bar wrapper. [title] is a LocaleKey (translated by [AppText]); the
/// RTL-aware back chevron is provided by auto_route's [AutoLeadingButton].
class AppAppBar extends StatelessWidget implements PreferredSizeWidget {
  const AppAppBar({
    required this.title,
    this.actions,
    this.leading,
    this.showDefaultBackButton = true,
    this.bottom,
    this.centerTitle = false,
    super.key,
  });

  /// LocaleKey for the app bar title; rendered through [AppText.titleLarge].
  final String title;

  /// Trailing action buttons.
  final List<Widget>? actions;

  /// Custom leading widget; overrides the default auto_route back button.
  final Widget? leading;

  /// Whether to show the RTL-aware [AutoLeadingButton] when no [leading] is set.
  final bool showDefaultBackButton;

  /// Optional widget (e.g. a [TabBar]) shown below the app bar.
  final PreferredSizeWidget? bottom;

  final bool centerTitle;

  /// Total height including any [bottom] widget, so layout reserves space.
  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0));

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: AppText.titleLarge(title),
      centerTitle: centerTitle,
      leading:
          leading ?? (showDefaultBackButton ? const AutoLeadingButton() : null),
      automaticallyImplyLeading: showDefaultBackButton,
      actions: actions,
      bottom: bottom,
    );
  }
}
