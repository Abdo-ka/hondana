import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'package:mihonx/core/error/app_exception.dart';
import 'package:mihonx/core/state/bloc_status.dart';
import 'package:mihonx/features/browse/domain/source/model/mangas_page.dart';
import 'package:mihonx/features/browse/domain/source/source.dart';
import 'package:mihonx/features/browse/domain/source/source_manager.dart';
import 'package:mihonx/features/browse/presentation/bloc/source_catalogue_event.dart';
import 'package:mihonx/features/browse/presentation/bloc/source_catalogue_state.dart';

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

  CatalogueSource? get _source => _sources.getCatalogueSource(sourceId);

  Future<void> _onLoad(
    CatalogueStarted event,
    Emitter<SourceCatalogueState> emit,
  ) async {
    final source = _source;
    if (source == null) {
      emit(state.copyWith(
        loadStatus: const BlocStatus.failure(
          AppException(message: 'Source unavailable'),
        ),
      ));
      return;
    }
    emit(state.copyWith(loadStatus: const BlocStatus.loading()));
    try {
      final result = await _fetch(source, state.mode, state.query, 1);
      emit(state.copyWith(
        loadStatus: result.mangas.isEmpty
            ? const BlocStatus.empty()
            : const BlocStatus.success(),
        manga: result.mangas,
        page: 1,
        hasNext: result.hasNextPage,
      ));
    } catch (e, st) {
      emit(state.copyWith(
        loadStatus: BlocStatus.failure(AppException.from(e, st)),
      ));
    }
  }

  void _onModeChanged(
    CatalogueModeChanged event,
    Emitter<SourceCatalogueState> emit,
  ) {
    emit(state.copyWith(
      mode: event.mode,
      query: event.mode == CatalogueMode.search ? state.query : '',
    ));
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
      emit(state.copyWith(
        manga: [...state.manga, ...result.mangas],
        page: next,
        hasNext: result.hasNextPage,
        loadMoreStatus: const BlocStatus.success(),
      ));
    } catch (e, st) {
      emit(state.copyWith(
        loadMoreStatus: BlocStatus.failure(AppException.from(e, st)),
      ));
    }
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
      CatalogueMode.search =>
        source.getSearchManga(page, query, source.getFilterList()),
    };
  }
}
