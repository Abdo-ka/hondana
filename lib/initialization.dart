import 'package:bloc/bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';

import 'package:hondana/core/config/advanced_preferences.dart';
import 'package:hondana/core/di/di_container.dart';
import 'package:hondana/core/network/app_http.dart';
import 'package:hondana/core/utils/app_bloc_observer.dart';
import 'package:hondana/features/browse/data/source/http_source_base.dart';
import 'package:hondana/features/downloads/presentation/bloc/downloads_bloc.dart';

/// Ordered startup invoked by `main()` before the first frame.
///
/// Runs each step to completion in dependency order: Flutter bindings and
/// localization first, then DI ([configureDependencies]), then post-DI wiring
/// that reads resolved services — cookie-store resolver, [Bloc] observer,
/// advanced preferences (user-agent override, optional cache clear) and eager
/// construction of [DownloadsBloc].
Future<void> preInitializations() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  // Dynamic text (titles, counts, source names) flows through AppText.tr();
  // silence the "key not found" noise — tr() returns the raw string anyway.
  EasyLocalization.logger.enableLevels = [];
  await configureDependencies();
  cookieStoreResolver = () => getIt<WebCookieStore>();
  Bloc.observer = const AppBlocObserver();
  // Settings > Advanced: UA override (sources bake it into their Dio at
  // construction — restart-required, like Mihon) and cache-clear-on-launch.
  final advanced = getIt<AdvancedPreferences>();
  final userAgent = advanced.userAgent;
  if (userAgent != null) HttpSourceBase.userAgent = userAgent;
  if (advanced.clearCacheOnLaunch) {
    await AppImageCache.manager.emptyCache();
  }
  // Eager: reconciles native download tasks and resumes the persisted queue
  // on every launch — including iOS background relaunches — without waiting
  // for a downloads-aware page to be opened.
  getIt<DownloadsBloc>();
}
