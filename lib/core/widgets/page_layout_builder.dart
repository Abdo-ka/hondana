import 'package:flutter/material.dart';

/// Page wrapper. Phone-first: renders [mobile]; [desktop] kicks in past 900px
/// when provided. Keeps a simple `PageLayoutBuilder(mobile: …)` shape without
/// pulling in a responsive package.
class PageLayoutBuilder extends StatelessWidget {
  const PageLayoutBuilder({required this.mobile, this.desktop, super.key});

  /// Phone-and-default layout; always the fallback.
  final WidgetBuilder mobile;

  /// Wide layout used when width >= 900px; falls back to [mobile] when null.
  final WidgetBuilder? desktop;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (desktop != null && constraints.maxWidth >= 900) {
          return desktop!(context);
        }
        return mobile(context);
      },
    );
  }
}
