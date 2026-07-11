import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:hondana/core/database/app_database.dart';
import 'package:hondana/core/di/di_container.config.dart';
import 'package:hondana/core/routing/app_router.dart';

/// Global service locator; resolve dependencies with `getIt<T>()`.
final GetIt getIt = GetIt.instance;

/// Boots the service locator. Feature bindings are discovered from
/// `@injectable`/`@LazySingleton` annotations by code generation.
@InjectableInit()
Future<void> configureDependencies() async => getIt.init();

/// Injectable module registering third-party/manually-constructed singletons
/// that can't be annotated at their own definition site.
@module
abstract class RegisterModule {
  /// The auto_route navigation router, kept alive for the app's lifetime.
  @singleton
  AppRouter get router => AppRouter();

  /// The Drift [AppDatabase], opened lazily on first use.
  @lazySingleton
  AppDatabase get database => AppDatabase();

  /// [SharedPreferences] resolved before init completes so sync deps can use it.
  @preResolve
  Future<SharedPreferences> get prefs => SharedPreferences.getInstance();
}
