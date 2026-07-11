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
import 'package:mihonx/core/config/advanced_preferences.dart' as _i62;
import 'package:mihonx/core/config/app_settings.dart' as _i826;
import 'package:mihonx/core/database/app_database.dart' as _i390;
import 'package:mihonx/core/di/di_container.dart' as _i459;
import 'package:mihonx/core/network/app_http.dart' as _i475;
import 'package:mihonx/core/routing/app_router.dart' as _i636;
import 'package:mihonx/features/browse/data/extensions_index_repository.dart'
    as _i448;
import 'package:mihonx/features/browse/data/source/builtin_source_manager.dart'
    as _i999;
import 'package:mihonx/features/browse/domain/source/model/s_manga.dart'
    as _i664;
import 'package:mihonx/features/browse/domain/source/source_manager.dart'
    as _i598;
import 'package:mihonx/features/browse/domain/source_preferences.dart' as _i733;
import 'package:mihonx/features/browse/presentation/bloc/extensions_bloc.dart'
    as _i652;
import 'package:mihonx/features/browse/presentation/bloc/global_search_bloc.dart'
    as _i919;
import 'package:mihonx/features/browse/presentation/bloc/source_catalogue_bloc.dart'
    as _i14;
import 'package:mihonx/features/downloads/domain/download_preferences.dart'
    as _i978;
import 'package:mihonx/features/downloads/domain/download_queue_store.dart'
    as _i755;
import 'package:mihonx/features/downloads/domain/download_service.dart'
    as _i158;
import 'package:mihonx/features/downloads/domain/live_activity_service.dart'
    as _i817;
import 'package:mihonx/features/downloads/presentation/bloc/downloads_bloc.dart'
    as _i409;
import 'package:mihonx/features/history/data/history_repository_impl.dart'
    as _i640;
import 'package:mihonx/features/history/domain/history_repository.dart'
    as _i286;
import 'package:mihonx/features/history/presentation/bloc/history_bloc.dart'
    as _i270;
import 'package:mihonx/features/library/data/library_repository_impl.dart'
    as _i282;
import 'package:mihonx/features/library/data/library_update_service.dart'
    as _i789;
import 'package:mihonx/features/library/domain/library_preferences.dart'
    as _i26;
import 'package:mihonx/features/library/domain/library_repository.dart'
    as _i196;
import 'package:mihonx/features/library/presentation/bloc/categories_bloc.dart'
    as _i1046;
import 'package:mihonx/features/library/presentation/bloc/library_bloc.dart'
    as _i509;
import 'package:mihonx/features/manga/data/manga_repository_impl.dart'
    as _i1026;
import 'package:mihonx/features/manga/domain/manga_repository.dart' as _i484;
import 'package:mihonx/features/manga/presentation/bloc/manga_details_bloc.dart'
    as _i862;
import 'package:mihonx/features/more/domain/security_preferences.dart'
    as _i1039;
import 'package:mihonx/features/reader/domain/reader_preferences.dart' as _i334;
import 'package:mihonx/features/reader/presentation/bloc/reader_bloc.dart'
    as _i934;
import 'package:mihonx/features/updates/data/updates_repository_impl.dart'
    as _i245;
import 'package:mihonx/features/updates/domain/updates_repository.dart'
    as _i404;
import 'package:mihonx/features/updates/presentation/bloc/updates_bloc.dart'
    as _i101;
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
    gh.lazySingleton<_i448.ExtensionsIndexRepository>(
      () => _i448.ExtensionsIndexRepository(),
    );
    gh.lazySingleton<_i158.DownloadService>(() => _i158.DownloadService());
    gh.lazySingleton<_i817.LiveActivityService>(
      () => _i817.LiveActivityService(),
    );
    gh.lazySingleton<_i598.SourceManager>(() => _i999.BuiltinSourceManager());
    gh.lazySingleton<_i196.LibraryRepository>(
      () => _i282.LibraryRepositoryImpl(
        gh<_i390.AppDatabase>(),
        gh<_i158.DownloadService>(),
      ),
    );
    gh.lazySingleton<_i484.MangaRepository>(
      () => _i1026.MangaRepositoryImpl(gh<_i390.AppDatabase>()),
    );
    gh.lazySingleton<_i62.AdvancedPreferences>(
      () => _i62.AdvancedPreferences(gh<_i460.SharedPreferences>()),
    );
    gh.lazySingleton<_i826.AppSettings>(
      () => _i826.AppSettings(gh<_i460.SharedPreferences>()),
    );
    gh.lazySingleton<_i475.WebCookieStore>(
      () => _i475.WebCookieStore(gh<_i460.SharedPreferences>()),
    );
    gh.lazySingleton<_i733.SourcePreferences>(
      () => _i733.SourcePreferences(gh<_i460.SharedPreferences>()),
    );
    gh.lazySingleton<_i978.DownloadPreferences>(
      () => _i978.DownloadPreferences(gh<_i460.SharedPreferences>()),
    );
    gh.lazySingleton<_i755.DownloadQueueStore>(
      () => _i755.DownloadQueueStore(gh<_i460.SharedPreferences>()),
    );
    gh.lazySingleton<_i26.LibraryPreferences>(
      () => _i26.LibraryPreferences(gh<_i460.SharedPreferences>()),
    );
    gh.lazySingleton<_i1039.SecurityPreferences>(
      () => _i1039.SecurityPreferences(gh<_i460.SharedPreferences>()),
    );
    gh.lazySingleton<_i334.ReaderPreferences>(
      () => _i334.ReaderPreferences(gh<_i460.SharedPreferences>()),
    );
    gh.lazySingleton<_i286.HistoryRepository>(
      () => _i640.HistoryRepositoryImpl(gh<_i390.AppDatabase>()),
    );
    gh.factory<_i270.HistoryBloc>(
      () => _i270.HistoryBloc(gh<_i286.HistoryRepository>()),
    );
    gh.factory<_i919.GlobalSearchBloc>(
      () => _i919.GlobalSearchBloc(
        gh<_i598.SourceManager>(),
        gh<_i733.SourcePreferences>(),
      ),
    );
    gh.lazySingleton<_i404.UpdatesRepository>(
      () => _i245.UpdatesRepositoryImpl(gh<_i390.AppDatabase>()),
    );
    gh.factory<_i652.ExtensionsBloc>(
      () => _i652.ExtensionsBloc(
        gh<_i448.ExtensionsIndexRepository>(),
        gh<_i598.SourceManager>(),
      ),
    );
    gh.factoryParam<_i14.SourceCatalogueBloc, int, dynamic>(
      (sourceId, _) =>
          _i14.SourceCatalogueBloc(gh<_i598.SourceManager>(), sourceId),
    );
    gh.factory<_i1046.CategoriesBloc>(
      () => _i1046.CategoriesBloc(gh<_i196.LibraryRepository>()),
    );
    gh.lazySingleton<_i789.LibraryUpdateService>(
      () => _i789.LibraryUpdateService(
        gh<_i390.AppDatabase>(),
        gh<_i598.SourceManager>(),
      ),
    );
    gh.lazySingleton<_i409.DownloadsBloc>(
      () => _i409.DownloadsBloc(
        gh<_i158.DownloadService>(),
        gh<_i484.MangaRepository>(),
        gh<_i598.SourceManager>(),
        gh<_i755.DownloadQueueStore>(),
        gh<_i978.DownloadPreferences>(),
        gh<_i1039.SecurityPreferences>(),
        gh<_i817.LiveActivityService>(),
      ),
    );
    gh.factoryParam<_i862.MangaDetailsBloc, int, _i664.SManga>(
      (sourceId, initial) => _i862.MangaDetailsBloc(
        gh<_i484.MangaRepository>(),
        gh<_i598.SourceManager>(),
        sourceId,
        initial,
      ),
    );
    gh.factory<_i509.LibraryBloc>(
      () => _i509.LibraryBloc(
        gh<_i196.LibraryRepository>(),
        gh<_i26.LibraryPreferences>(),
        gh<_i789.LibraryUpdateService>(),
        gh<_i826.AppSettings>(),
      ),
    );
    gh.factoryParam<_i934.ReaderBloc, int, dynamic>(
      (_chapterId, _) => _i934.ReaderBloc(
        gh<_i484.MangaRepository>(),
        gh<_i598.SourceManager>(),
        gh<_i286.HistoryRepository>(),
        gh<_i158.DownloadService>(),
        gh<_i826.AppSettings>(),
        gh<_i334.ReaderPreferences>(),
        _chapterId,
      ),
    );
    gh.factory<_i101.UpdatesBloc>(
      () => _i101.UpdatesBloc(
        gh<_i404.UpdatesRepository>(),
        gh<_i789.LibraryUpdateService>(),
      ),
    );
    return this;
  }
}

class _$RegisterModule extends _i459.RegisterModule {}
