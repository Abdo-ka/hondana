import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mihonx/core/database/app_database.dart';
import 'package:mihonx/core/di/di_container.config.dart';
import 'package:mihonx/core/routing/app_router.dart';

final GetIt getIt = GetIt.instance;

/// Boots the service locator. Feature bindings are discovered from
/// `@injectable`/`@LazySingleton` annotations by code generation.
@InjectableInit()
Future<void> configureDependencies() async => getIt.init();

/// App-level singletons that aren't plain annotated classes.
@module
abstract class RegisterModule {
  @singleton
  AppRouter get router => AppRouter();

  @lazySingleton
  AppDatabase get database => AppDatabase();

  @preResolve
  Future<SharedPreferences> get prefs => SharedPreferences.getInstance();
}
