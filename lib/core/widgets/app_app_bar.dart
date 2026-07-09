import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:mihonx/core/widgets/app_text.dart';

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

  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showDefaultBackButton;
  final PreferredSizeWidget? bottom;
  final bool centerTitle;

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0));

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: AppText.titleLarge(title),
      centerTitle: centerTitle,
      leading: leading ??
          (showDefaultBackButton ? const AutoLeadingButton() : null),
      automaticallyImplyLeading: showDefaultBackButton,
      actions: actions,
      bottom: bottom,
    );
  }
}
