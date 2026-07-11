import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:mihonx/core/config/app_settings.dart';
import 'package:mihonx/core/routing/app_router.dart';
import 'package:mihonx/core/theme/app_theme.dart';
import 'package:mihonx/core/widgets/app_lock_gate.dart';

class MihonxApp extends StatelessWidget {
  const MihonxApp({required this.router, required this.settings, super.key});

  final AppRouter router;
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
            title: 'Mihonx',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark(pureBlack: pureBlack),
            themeMode: mode,
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            routerConfig: router.config(),
            builder: (context, child) =>
                AppLockGate(child: child ?? const SizedBox.shrink()),
          ),
        ),
      ),
    );
  }
}
