// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:hondana/core/config/advanced_preferences.dart' as _i3;
import 'package:hondana/core/config/app_settings.dart' as _i763;
import 'package:hondana/core/database/app_database.dart' as _i306;
import 'package:hondana/core/di/di_container.dart' as _i854;
import 'package:hondana/core/network/app_http.dart' as _i301;
import 'package:hondana/core/routing/app_router.dart' as _i84;
import 'package:hondana/features/browse/data/extensions_index_repository.dart'
    as _i768;
import 'package:hondana/features/browse/data/source/builtin_source_manager.dart'
    as _i1001;
import 'package:hondana/features/browse/domain/source/model/s_manga.dart'
    as _i444;
import 'package:hondana/features/browse/domain/source/source_manager.dart'
    as _i893;
import 'package:hondana/features/browse/domain/source_preferences.dart' as _i82;
import 'package:hondana/features/browse/presentation/bloc/extensions_bloc.dart'
    as _i372;
import 'package:hondana/features/browse/presentation/bloc/global_search_bloc.dart'
    as _i674;
import 'package:hondana/features/browse/presentation/bloc/source_catalogue_bloc.dart'
    as _i915;
import 'package:hondana/features/downloads/domain/download_preferences.dart'
    as _i638;
import 'package:hondana/features/downloads/domain/download_queue_store.dart'
    as _i536;
import 'package:hondana/features/downloads/domain/download_service.dart'
    as _i170;
import 'package:hondana/features/downloads/domain/live_activity_service.dart'
    as _i264;
import 'package:hondana/features/downloads/presentation/bloc/downloads_bloc.dart'
    as _i778;
import 'package:hondana/features/history/data/data_sources/history_local_datasource.dart'
    as _i232;
import 'package:hondana/features/history/data/repositories/history_repository_imp.dart'
    as _i377;
import 'package:hondana/features/history/domain/repositories/history_repository.dart'
    as _i7;
import 'package:hondana/features/history/presentation/state/bloc/history_bloc.dart'
    as _i1060;
import 'package:hondana/features/library/data/library_repository_impl.dart'
    as _i417;
import 'package:hondana/features/library/data/library_update_service.dart'
    as _i901;
import 'package:hondana/features/library/domain/library_preferences.dart'
    as _i791;
import 'package:hondana/features/library/domain/library_repository.dart'
    as _i161;
import 'package:hondana/features/library/presentation/bloc/categories_bloc.dart'
    as _i608;
import 'package:hondana/features/library/presentation/bloc/library_bloc.dart'
    as _i900;
import 'package:hondana/features/manga/data/manga_repository_impl.dart'
    as _i153;
import 'package:hondana/features/manga/domain/manga_repository.dart' as _i944;
import 'package:hondana/features/manga/presentation/bloc/manga_details_bloc.dart'
    as _i672;
import 'package:hondana/features/more/domain/security_preferences.dart' as _i14;
import 'package:hondana/features/reader/domain/reader_preferences.dart'
    as _i959;
import 'package:hondana/features/reader/presentation/bloc/reader_bloc.dart'
    as _i425;
import 'package:hondana/features/updates/data/data_sources/updates_local_datasource.dart'
    as _i135;
import 'package:hondana/features/updates/data/repositories/updates_repository_imp.dart'
    as _i534;
import 'package:hondana/features/updates/domain/repositories/updates_repository.dart'
    as _i478;
import 'package:hondana/features/updates/presentation/state/bloc/updates_bloc.dart'
    as _i85;
import 'package:injectable/injectable.dart' as _i526;
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
    gh.singleton<_i84.AppRouter>(() => registerModule.router);
    gh.lazySingleton<_i306.AppDatabase>(() => registerModule.database);
    gh.lazySingleton<_i768.ExtensionsIndexRepository>(
      () => _i768.ExtensionsIndexRepository(),
    );
    gh.lazySingleton<_i170.DownloadService>(() => _i170.DownloadService());
    gh.lazySingleton<_i264.LiveActivityService>(
      () => _i264.LiveActivityService(),
    );
    gh.factory<_i232.HistoryLocalDataSource>(
      () => _i232.HistoryLocalDataSource(gh<_i306.AppDatabase>()),
    );
    gh.factory<_i135.UpdatesLocalDataSource>(
      () => _i135.UpdatesLocalDataSource(gh<_i306.AppDatabase>()),
    );
    gh.lazySingleton<_i944.MangaRepository>(
      () => _i153.MangaRepositoryImpl(gh<_i306.AppDatabase>()),
    );
    gh.lazySingleton<_i893.SourceManager>(() => _i1001.BuiltinSourceManager());
    gh.lazySingleton<_i478.UpdatesRepository>(
      () => _i534.UpdatesRepositoryImp(gh<_i135.UpdatesLocalDataSource>()),
    );
    gh.factoryParam<_i672.MangaDetailsBloc, int, _i444.SManga>(
      (sourceId, initial) => _i672.MangaDetailsBloc(
        gh<_i944.MangaRepository>(),
        gh<_i893.SourceManager>(),
        sourceId,
        initial,
      ),
    );
    gh.lazySingleton<_i3.AdvancedPreferences>(
      () => _i3.AdvancedPreferences(gh<_i460.SharedPreferences>()),
    );
    gh.lazySingleton<_i763.AppSettings>(
      () => _i763.AppSettings(gh<_i460.SharedPreferences>()),
    );
    gh.lazySingleton<_i301.WebCookieStore>(
      () => _i301.WebCookieStore(gh<_i460.SharedPreferences>()),
    );
    gh.lazySingleton<_i82.SourcePreferences>(
      () => _i82.SourcePreferences(gh<_i460.SharedPreferences>()),
    );
    gh.lazySingleton<_i638.DownloadPreferences>(
      () => _i638.DownloadPreferences(gh<_i460.SharedPreferences>()),
    );
    gh.lazySingleton<_i536.DownloadQueueStore>(
      () => _i536.DownloadQueueStore(gh<_i460.SharedPreferences>()),
    );
    gh.lazySingleton<_i791.LibraryPreferences>(
      () => _i791.LibraryPreferences(gh<_i460.SharedPreferences>()),
    );
    gh.lazySingleton<_i14.SecurityPreferences>(
      () => _i14.SecurityPreferences(gh<_i460.SharedPreferences>()),
    );
    gh.lazySingleton<_i959.ReaderPreferences>(
      () => _i959.ReaderPreferences(gh<_i460.SharedPreferences>()),
    );
    gh.lazySingleton<_i161.LibraryRepository>(
      () => _i417.LibraryRepositoryImpl(
        gh<_i306.AppDatabase>(),
        gh<_i170.DownloadService>(),
      ),
    );
    gh.lazySingleton<_i7.HistoryRepository>(
      () => _i377.HistoryRepositoryImp(gh<_i232.HistoryLocalDataSource>()),
    );
    gh.factory<_i674.GlobalSearchBloc>(
      () => _i674.GlobalSearchBloc(
        gh<_i893.SourceManager>(),
        gh<_i82.SourcePreferences>(),
      ),
    );
    gh.factoryParam<_i425.ReaderBloc, int, dynamic>(
      (_chapterId, _) => _i425.ReaderBloc(
        gh<_i944.MangaRepository>(),
        gh<_i893.SourceManager>(),
        gh<_i7.HistoryRepository>(),
        gh<_i170.DownloadService>(),
        gh<_i763.AppSettings>(),
        gh<_i959.ReaderPreferences>(),
        _chapterId,
      ),
    );
    gh.factory<_i372.ExtensionsBloc>(
      () => _i372.ExtensionsBloc(
        gh<_i768.ExtensionsIndexRepository>(),
        gh<_i893.SourceManager>(),
      ),
    );
    gh.lazySingleton<_i778.DownloadsBloc>(
      () => _i778.DownloadsBloc(
        gh<_i170.DownloadService>(),
        gh<_i944.MangaRepository>(),
        gh<_i893.SourceManager>(),
        gh<_i536.DownloadQueueStore>(),
        gh<_i638.DownloadPreferences>(),
        gh<_i14.SecurityPreferences>(),
        gh<_i264.LiveActivityService>(),
      ),
    );
    gh.factoryParam<_i915.SourceCatalogueBloc, int, dynamic>(
      (sourceId, _) =>
          _i915.SourceCatalogueBloc(gh<_i893.SourceManager>(), sourceId),
    );
    gh.lazySingleton<_i901.LibraryUpdateService>(
      () => _i901.LibraryUpdateService(
        gh<_i306.AppDatabase>(),
        gh<_i893.SourceManager>(),
      ),
    );
    gh.factory<_i608.CategoriesBloc>(
      () => _i608.CategoriesBloc(gh<_i161.LibraryRepository>()),
    );
    gh.factory<_i900.LibraryBloc>(
      () => _i900.LibraryBloc(
        gh<_i161.LibraryRepository>(),
        gh<_i791.LibraryPreferences>(),
        gh<_i901.LibraryUpdateService>(),
        gh<_i763.AppSettings>(),
      ),
    );
    gh.factory<_i1060.HistoryBloc>(
      () => _i1060.HistoryBloc(gh<_i7.HistoryRepository>()),
    );
    gh.factory<_i85.UpdatesBloc>(
      () => _i85.UpdatesBloc(
        gh<_i478.UpdatesRepository>(),
        gh<_i901.LibraryUpdateService>(),
      ),
    );
    return this;
  }
}

class _$RegisterModule extends _i854.RegisterModule {}
