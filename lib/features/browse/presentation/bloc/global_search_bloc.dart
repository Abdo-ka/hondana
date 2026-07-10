import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'package:mihonx/core/error/app_exception.dart';
import 'package:mihonx/core/state/bloc_status.dart';
import 'package:mihonx/features/browse/domain/source/source_manager.dart';
import 'package:mihonx/features/browse/domain/source_preferences.dart';
import 'package:mihonx/features/browse/presentation/bloc/global_search_event.dart';
import 'package:mihonx/features/browse/presentation/bloc/global_search_state.dart';

/// Fans a query out across every enabled source concurrently; each source's
/// section updates as its request resolves.
@injectable
class GlobalSearchBloc extends Bloc<GlobalSearchEvent, GlobalSearchState> {
  GlobalSearchBloc(this._sources, this._prefs)
      : super(const GlobalSearchState()) {
    on<GlobalSearched>(_onSearch, transformer: restartable());
  }

  final SourceManager _sources;
  final SourcePreferences _prefs;

  Future<void> _onSearch(
    GlobalSearched event,
    Emitter<GlobalSearchState> emit,
  ) async {
    final query = event.query.trim();
    if (query.isEmpty) {
      emit(const GlobalSearchState());
      return;
    }
    final sources = _sources
        .getCatalogueSources()
        .where((s) => _prefs.isEnabled(s.id))
        .toList();
    emit(GlobalSearchState(
      query: query,
      results: sources
          .map((s) => SourceSearchResult(sourceId: s.id, sourceName: s.name))
          .toList(),
    ));

    await Future.wait(sources.map((source) async {
      try {
        final page = await source.getSearchManga(1, query, source.getFilterList());
        if (emit.isDone) return;
        emit(state.copyWith(
          results: _replace(
            source.id,
            (r) => r.copyWith(
              status: page.mangas.isEmpty
                  ? const BlocStatus.empty()
                  : const BlocStatus.success(),
              manga: page.mangas,
            ),
          ),
        ));
      } catch (err, st) {
        if (emit.isDone) return;
        emit(state.copyWith(
          results: _replace(
            source.id,
            (r) => r.copyWith(
              status: BlocStatus.failure(AppException.from(err, st)),
            ),
          ),
        ));
      }
    }));
  }

  List<SourceSearchResult> _replace(
    int id,
    SourceSearchResult Function(SourceSearchResult) update,
  ) =>
      state.results.map((r) => r.sourceId == id ? update(r) : r).toList();
}
