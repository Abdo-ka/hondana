import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:hondana/core/config/app_settings.dart';
import 'package:hondana/core/routing/app_router.dart';
import 'package:hondana/core/theme/app_theme.dart';
import 'package:hondana/core/widgets/app_lock_gate.dart';

/// Root widget: wires [ScreenUtilInit], [MaterialApp.router] and the
/// [AppLockGate] into a single tree.
///
/// Reactive theme (light/dark + pure-black OLED) is driven by [AppSettings]
/// notifiers so a preference change rebuilds only the affected subtree, not
/// the whole app.
class HondanaApp extends StatelessWidget {
  const HondanaApp({required this.router, required this.settings, super.key});

  /// The generated auto_route router providing [routerConfig].
  final AppRouter router;

  /// Source of the reactive theme mode / pure-black notifiers.
  final AppSettings settings;

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 800),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) => ValueListenableBuilder<ThemeMode>(
        valueListenable: settings.themeModeNotifier,
        builder: (context, mode, _) => ValueListenableBuilder<bool>(
          valueListenable: settings.pureBlackNotifier,
          builder: (context, pureBlack, _) => MaterialApp.router(
            title: 'Hondana',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark(pureBlack: pureBlack),
            themeMode: mode,
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            routerConfig: router.config(),
            // Wrap every routed page in the biometric/PIN lock gate so it
            // covers navigation performed after startup, not just the first
            // screen.
            builder: (context, child) =>
                AppLockGate(child: child ?? const SizedBox.shrink()),
          ),
        ),
      ),
    );
  }
}
