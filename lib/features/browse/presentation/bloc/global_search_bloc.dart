import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'package:mihonx/core/database/app_database.dart';
import 'package:mihonx/core/di/di_container.dart';
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
    // Fetched once per search; each source's results filter against it.
    final libraryKeys = await _favoriteKeys();
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
        final mangas = libraryKeys.isEmpty
            ? page.mangas
            : page.mangas
                .where((m) => !libraryKeys.contains('${source.id}|${m.url}'))
                .toList();
        emit(state.copyWith(
          results: _replace(
            source.id,
            (r) => r.copyWith(
              status: mangas.isEmpty
                  ? const BlocStatus.empty()
                  : const BlocStatus.success(),
              manga: mangas,
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

  /// Favorited `'$sourceId|$url'` keys for the hide-in-library setting — one
  /// DB query per search, empty set when off. Read via getIt because this
  /// bloc's DI constructor is fixed (generated config).
  Future<Set<String>> _favoriteKeys() async {
    if (!_prefs.hideInLibrary) return const {};
    final db = getIt<AppDatabase>();
    final rows = await (db.select(db.mangas)
          ..where((m) => m.favorite.equals(true)))
        .get();
    return rows.map((r) => '${r.source}|${r.url}').toSet();
  }

  List<SourceSearchResult> _replace(
    int id,
    SourceSearchResult Function(SourceSearchResult) update,
  ) =>
      state.results.map((r) => r.sourceId == id ? update(r) : r).toList();
}
