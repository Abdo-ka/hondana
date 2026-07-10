import 'package:bloc/bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';

import 'package:mihonx/core/di/di_container.dart';
import 'package:mihonx/core/network/app_http.dart';
import 'package:mihonx/core/utils/app_bloc_observer.dart';

/// Ordered startup invoked by `main()` before the first frame.
Future<void> preInitializations() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  // Dynamic text (titles, counts, source names) flows through AppText.tr();
  // silence the "key not found" noise — tr() returns the raw string anyway.
  EasyLocalization.logger.enableLevels = [];
  await configureDependencies();
  cookieStoreResolver = () => getIt<WebCookieStore>();
  Bloc.observer = const AppBlocObserver();
}
