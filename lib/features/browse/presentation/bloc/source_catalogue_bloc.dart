import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:drift/drift.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:hondana/core/database/app_database.dart';
import 'package:hondana/core/di/di_container.dart';
import 'package:hondana/core/error/app_exception.dart';
import 'package:hondana/core/state/bloc_status.dart';
import 'package:hondana/features/browse/domain/source/model/mangas_page.dart';
import 'package:hondana/features/browse/domain/source/model/s_manga.dart';
import 'package:hondana/features/browse/domain/source/source.dart';
import 'package:hondana/features/browse/domain/source/source_manager.dart';
import 'package:hondana/features/browse/domain/source_preferences.dart';
import 'package:hondana/features/browse/presentation/bloc/source_catalogue_event.dart';
import 'package:hondana/features/browse/presentation/bloc/source_catalogue_state.dart';

/// Drives one source's browse grid: paginated popular / latest / search
/// listings with hide-in-library filtering.
///
/// Concurrency: loads and searches use `restartable()` so a new request cancels
/// the in-flight one; load-more uses `droppable()` so rapid scroll events don't
/// stack duplicate page fetches.
@injectable
class SourceCatalogueBloc
    extends Bloc<SourceCatalogueEvent, SourceCatalogueState> {
  SourceCatalogueBloc(this._sources, @factoryParam this.sourceId)
    : super(const SourceCatalogueState()) {
    on<CatalogueStarted>(_onLoad, transformer: restartable());
    on<CatalogueModeChanged>(_onModeChanged);
    on<CatalogueSearched>(_onSearched, transformer: restartable());
    on<CatalogueLoadMore>(_onLoadMore, transformer: droppable());
  }

  final SourceManager _sources;
  final int sourceId;

  /// Favorited entry urls for this source — refreshed once per load when
  /// "Hide entries already in library" is on, reused across load-more pages.
  Set<String> _libraryUrls = const {};

  CatalogueSource? get _source => _sources.getCatalogueSource(sourceId);

  Future<void> _onLoad(
    CatalogueStarted event,
    Emitter<SourceCatalogueState> emit,
  ) async {
    final source = _source;
    if (source == null) {
      emit(
        state.copyWith(
          loadStatus: const BlocStatus.failure(
            AppException(message: 'Source unavailable'),
          ),
        ),
      );
      return;
    }
    emit(state.copyWith(loadStatus: const BlocStatus.loading()));
    try {
      _libraryUrls = await _favoriteUrls();
      var page = 1;
      var result = await _fetch(source, state.mode, state.query, page);
      var mangas = _visible(result.mangas);
      // A fully-favorited first page would leave the grid blank with nothing
      // to scroll (load-more is scroll-driven) — keep paging, bounded, until
      // something is visible.
      while (mangas.isEmpty && result.hasNextPage && page < 5) {
        page++;
        result = await _fetch(source, state.mode, state.query, page);
        mangas = _visible(result.mangas);
      }
      emit(
        state.copyWith(
          loadStatus: mangas.isEmpty
              ? const BlocStatus.empty()
              : const BlocStatus.success(),
          manga: mangas,
          page: page,
          hasNext: result.hasNextPage,
        ),
      );
    } catch (e, st) {
      emit(
        state.copyWith(
          loadStatus: BlocStatus.failure(AppException.from(e, st)),
        ),
      );
    }
  }

  void _onModeChanged(
    CatalogueModeChanged event,
    Emitter<SourceCatalogueState> emit,
  ) {
    emit(
      state.copyWith(
        mode: event.mode,
        query: event.mode == CatalogueMode.search ? state.query : '',
      ),
    );
    add(const CatalogueStarted());
  }

  Future<void> _onSearched(
    CatalogueSearched event,
    Emitter<SourceCatalogueState> emit,
  ) async {
    emit(state.copyWith(mode: CatalogueMode.search, query: event.query));
    await _onLoad(const CatalogueStarted(), emit);
  }

  Future<void> _onLoadMore(
    CatalogueLoadMore event,
    Emitter<SourceCatalogueState> emit,
  ) async {
    if (!state.hasNext || state.loadMoreStatus.isLoading()) return;
    final source = _source;
    if (source == null) return;
    emit(state.copyWith(loadMoreStatus: const BlocStatus.loading()));
    try {
      final next = state.page + 1;
      final result = await _fetch(source, state.mode, state.query, next);
      emit(
        state.copyWith(
          manga: [...state.manga, ..._visible(result.mangas)],
          page: next,
          hasNext: result.hasNextPage,
          loadMoreStatus: const BlocStatus.success(),
        ),
      );
    } catch (e, st) {
      emit(
        state.copyWith(
          loadMoreStatus: BlocStatus.failure(AppException.from(e, st)),
        ),
      );
    }
  }

  List<SManga> _visible(List<SManga> mangas) => _libraryUrls.isEmpty
      ? mangas
      : mangas.where((m) => !_libraryUrls.contains(m.url)).toList();

  /// Favorite lookup for the hide-in-library setting — one cheap indexed DB
  /// query per load, empty set when the setting is off. Read via getIt because
  /// this bloc's DI constructor is fixed (generated config).
  Future<Set<String>> _favoriteUrls() async {
    if (!getIt<SourcePreferences>().hideInLibrary) return const {};
    final db = getIt<AppDatabase>();
    final rows = await (db.select(
      db.mangas,
    )..where((m) => m.favorite.equals(true) & m.source.equals(sourceId))).get();
    return rows.map((r) => r.url).toSet();
  }

  Future<MangasPage> _fetch(
    CatalogueSource source,
    CatalogueMode mode,
    String query,
    int page,
  ) {
    return switch (mode) {
      CatalogueMode.popular => source.getPopularManga(page),
      CatalogueMode.latest => source.getLatestUpdates(page),
      CatalogueMode.search => source.getSearchManga(
        page,
        query,
        source.getFilterList(),
      ),
    };
  }
}
