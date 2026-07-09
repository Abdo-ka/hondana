import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:mihonx/app.dart';
import 'package:mihonx/core/di/di_container.dart';
import 'package:mihonx/core/routing/app_router.dart';
import 'package:mihonx/initialization.dart';

Future<void> main() async {
  await preInitializations();
  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: MihonxApp(router: getIt<AppRouter>()),
    ),
  );
}
