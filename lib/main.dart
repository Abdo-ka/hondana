import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:hondana/app.dart';
import 'package:hondana/core/config/app_settings.dart';
import 'package:hondana/core/di/di_container.dart';
import 'package:hondana/core/routing/app_router.dart';
import 'package:hondana/initialization.dart';

/// App entry point.
///
/// Runs [preInitializations] (bindings, DI, localization, network) to
/// completion before the first frame, then mounts [HondanaApp] under
/// [EasyLocalization]. The router and settings are pulled from the ready
/// [getIt] container rather than constructed here.
Future<void> main() async {
  await preInitializations();
  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: HondanaApp(
        router: getIt<AppRouter>(),
        settings: getIt<AppSettings>(),
      ),
    ),
  );
}
