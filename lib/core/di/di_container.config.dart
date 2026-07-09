// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:mihonx/core/database/app_database.dart' as _i390;
import 'package:mihonx/core/di/di_container.dart' as _i459;
import 'package:mihonx/core/routing/app_router.dart' as _i636;
import 'package:mihonx/features/browse/data/source/stub_source_manager.dart'
    as _i550;
import 'package:mihonx/features/browse/domain/source/source_manager.dart'
    as _i598;
import 'package:mihonx/features/library/data/library_repository_impl.dart'
    as _i282;
import 'package:mihonx/features/library/data/library_update_service.dart'
    as _i789;
import 'package:mihonx/features/library/domain/library_preferences.dart'
    as _i26;
import 'package:mihonx/features/library/domain/library_repository.dart'
    as _i196;
import 'package:mihonx/features/library/presentation/bloc/library_bloc.dart'
    as _i509;
import 'package:shared_preferences/shared_preferences.dart' as _i460;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final registerModule = _$RegisterModule();
    await gh.factoryAsync<_i460.SharedPreferences>(
      () => registerModule.prefs,
      preResolve: true,
    );
    gh.singleton<_i636.AppRouter>(() => registerModule.router);
    gh.lazySingleton<_i390.AppDatabase>(() => registerModule.database);
    gh.lazySingleton<_i598.SourceManager>(() => _i550.StubSourceManager());
    gh.lazySingleton<_i789.LibraryUpdateService>(
      () => _i789.LibraryUpdateService(
        gh<_i390.AppDatabase>(),
        gh<_i598.SourceManager>(),
      ),
    );
    gh.lazySingleton<_i196.LibraryRepository>(
      () => _i282.LibraryRepositoryImpl(gh<_i390.AppDatabase>()),
    );
    gh.lazySingleton<_i26.LibraryPreferences>(
      () => _i26.LibraryPreferences(gh<_i460.SharedPreferences>()),
    );
    gh.factory<_i509.LibraryBloc>(
      () => _i509.LibraryBloc(
        gh<_i196.LibraryRepository>(),
        gh<_i26.LibraryPreferences>(),
        gh<_i789.LibraryUpdateService>(),
      ),
    );
    return this;
  }
}

class _$RegisterModule extends _i459.RegisterModule {}
