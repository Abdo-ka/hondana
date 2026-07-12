import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'package:hondana/core/config/app_settings.dart';
import 'package:hondana/core/error/app_exception.dart';
import 'package:hondana/core/state/bloc_status.dart';
import 'package:hondana/features/browse/domain/source/model/manga_status.dart';
import 'package:hondana/services/library_update_service.dart';
import 'package:hondana/features/library/domain/library_manga.dart';
import 'package:hondana/features/library/domain/library_preferences.dart';
import 'package:hondana/features/library/domain/library_repository.dart';
import 'package:hondana/features/library/presentation/bloc/library_event.dart';
import 'package:hondana/features/library/presentation/bloc/library_state.dart';

/// Drives the library screen: streams persisted manga, applies the filter+sort
/// [_pipeline], and owns view options, multi-select and global refresh.
///
/// Initial view options (display/sort/filters) are seeded from
/// [LibraryPreferences] and written back whenever the user changes them.
/// The global downloaded-only toggle in [AppSettings] is observed live and
/// re-runs the pipeline via [LibraryFiltersRefreshed].
@injectable
class LibraryBloc extends Bloc<LibraryEvent, LibraryState> {
  LibraryBloc(
    this._repo,
    LibraryPreferences prefs,
    this._updater,
    this._settings,
  ) : _prefs = prefs,
      super(
        LibraryState(
          displayMode: prefs.displayMode,
          sortMode: prefs.sortMode,
          sortAscending: prefs.sortAscending,
          filterUnread: prefs.filterUnread,
          filterCompleted: prefs.filterCompleted,
          filterDownloaded: prefs.filterDownloaded,
        ),
      ) {
    on<LibraryCategoriesSubscribed>(_onCategories, transformer: restartable());
    on<LibrarySubscribed>(_onSubscribe, transformer: restartable());
    on<LibraryCategorySelected>(_onCategorySelected);
    on<LibraryDisplayModeChanged>(_onDisplayMode);
    on<LibrarySortChanged>(_onSort);
    on<LibrarySearchChanged>(_onSearch);
    on<LibraryFilterCycled>(_onFilterCycled);
    on<LibraryFiltersRefreshed>(
      (e, emit) => emit(state.copyWith(manga: _pipeline(_raw, state))),
    );
    on<LibraryItemSelectionToggled>(_onToggle);
    on<LibrarySelectionCleared>(
      (e, emit) => emit(state.copyWith(selectedIds: const {})),
    );
    on<LibrarySelectAllToggled>(_onSelectAll);
    on<LibrarySelectedRemoved>(_onRemove);
    on<LibrarySelectedMarkedRead>(_onMarkRead);
    on<LibrarySelectedSetCategories>(_onSetCategories);
    on<LibraryRefreshRequested>(_onRefresh, transformer: droppable());
    _settings.downloadedOnlyNotifier.addListener(_onDownloadedOnlyChanged);
  }

  final LibraryRepository _repo;
  final LibraryPreferences _prefs;
  final LibraryUpdateService _updater;
  final AppSettings _settings;

  /// Unfiltered library as last emitted by the repository stream.
  List<LibraryManga> _raw = const [];

  /// Re-runs the pipeline when the app-wide downloaded-only setting flips.
  void _onDownloadedOnlyChanged() => add(const LibraryFiltersRefreshed());

  @override
  Future<void> close() {
    _settings.downloadedOnlyNotifier.removeListener(_onDownloadedOnlyChanged);
    return super.close();
  }

  Future<void> _onCategories(
    LibraryCategoriesSubscribed event,
    Emitter<LibraryState> emit,
  ) {
    return emit.forEach(
      _repo.watchCategories(),
      onData: (categories) => state.copyWith(categories: categories),
    );
  }

  /// Streams the library for the active category, running each emission
  /// through [_pipeline] and caching the raw list in [_raw] for later re-filters.
  Future<void> _onSubscribe(
    LibrarySubscribed event,
    Emitter<LibraryState> emit,
  ) async {
    emit(state.copyWith(loadStatus: const BlocStatus.loading()));
    await emit.forEach(
      _repo.watchLibrary(categoryId: state.selectedCategoryId),
      onData: (list) {
        _raw = list;
        final visible = _pipeline(list, state);
        return state.copyWith(
          manga: visible,
          loadStatus: list.isEmpty
              ? const BlocStatus.empty()
              : const BlocStatus.success(),
        );
      },
      onError: (err, st) => state.copyWith(
        loadStatus: BlocStatus.failure(AppException.from(err, st)),
      ),
    );
  }

  /// Switches category, clears any selection, then restarts the library stream.
  void _onCategorySelected(
    LibraryCategorySelected event,
    Emitter<LibraryState> emit,
  ) {
    emit(
      state.copyWith(
        selectedCategoryId: event.categoryId,
        selectedIds: const {},
      ),
    );
    add(const LibrarySubscribed());
  }

  Future<void> _onDisplayMode(
    LibraryDisplayModeChanged event,
    Emitter<LibraryState> emit,
  ) async {
    await _prefs.setDisplayMode(event.mode);
    emit(state.copyWith(displayMode: event.mode));
  }

  Future<void> _onSort(
    LibrarySortChanged event,
    Emitter<LibraryState> emit,
  ) async {
    await _prefs.setSortMode(event.mode);
    await _prefs.setSortAscending(event.ascending);
    final next = state.copyWith(
      sortMode: event.mode,
      sortAscending: event.ascending,
    );
    emit(next.copyWith(manga: _pipeline(_raw, next)));
  }

  void _onSearch(LibrarySearchChanged event, Emitter<LibraryState> emit) {
    final next = state.copyWith(query: event.query);
    emit(next.copyWith(manga: _pipeline(_raw, next)));
  }

  /// Advances the targeted tri-state filter one step, persists all three, then
  /// re-runs the pipeline.
  Future<void> _onFilterCycled(
    LibraryFilterCycled event,
    Emitter<LibraryState> emit,
  ) async {
    final next = switch (event.kind) {
      LibraryFilterKind.unread => state.copyWith(
        filterUnread: state.filterUnread.next,
      ),
      LibraryFilterKind.completed => state.copyWith(
        filterCompleted: state.filterCompleted.next,
      ),
      LibraryFilterKind.downloaded => state.copyWith(
        filterDownloaded: state.filterDownloaded.next,
      ),
    };
    await _prefs.setFilterUnread(next.filterUnread);
    await _prefs.setFilterCompleted(next.filterCompleted);
    await _prefs.setFilterDownloaded(next.filterDownloaded);
    emit(next.copyWith(manga: _pipeline(_raw, next)));
  }

  /// Adds the manga to the selection if absent, removes it if present.
  void _onToggle(
    LibraryItemSelectionToggled event,
    Emitter<LibraryState> emit,
  ) {
    final next = Set<int>.from(state.selectedIds);
    if (!next.remove(event.mangaId)) next.add(event.mangaId);
    emit(state.copyWith(selectedIds: next));
  }

  /// Selects every visible manga, or clears the selection if already all-selected.
  void _onSelectAll(LibrarySelectAllToggled event, Emitter<LibraryState> emit) {
    if (state.allSelected) {
      emit(state.copyWith(selectedIds: const {}));
    } else {
      emit(
        state.copyWith(selectedIds: state.manga.map((m) => m.manga.id).toSet()),
      );
    }
  }

  Future<void> _onRemove(
    LibrarySelectedRemoved event,
    Emitter<LibraryState> emit,
  ) async {
    await _repo.removeFromLibrary(state.selectedIds.toList());
    emit(state.copyWith(selectedIds: const {}));
  }

  Future<void> _onMarkRead(
    LibrarySelectedMarkedRead event,
    Emitter<LibraryState> emit,
  ) async {
    await _repo.setRead(state.selectedIds.toList(), event.read);
    emit(state.copyWith(selectedIds: const {}));
  }

  Future<void> _onSetCategories(
    LibrarySelectedSetCategories event,
    Emitter<LibraryState> emit,
  ) async {
    await _repo.setMangaCategories(
      state.selectedIds.toList(),
      event.categoryIds,
    );
    emit(state.copyWith(selectedIds: const {}));
  }

  /// Runs a global library update, surfacing progress via [state.refreshStatus].
  /// Registered with `droppable()`, so overlapping refresh taps are ignored.
  Future<void> _onRefresh(
    LibraryRefreshRequested event,
    Emitter<LibraryState> emit,
  ) async {
    emit(state.copyWith(refreshStatus: const BlocStatus.loading()));
    try {
      await _updater.refreshAll();
      emit(state.copyWith(refreshStatus: const BlocStatus.success()));
    } catch (err, st) {
      emit(
        state.copyWith(
          refreshStatus: BlocStatus.failure(AppException.from(err, st)),
        ),
      );
    }
  }

  // ── Filter + sort pipeline ─────────────────────────────────────────────────

  /// Applies the search query and the three tri-state filters, then sorts.
  ///
  /// A [TriFilter] is: `ignore` keeps everything, `include` keeps only matches,
  /// `exclude` keeps only non-matches. The app-wide downloaded-only setting is
  /// an additional hard filter layered on top of the per-column filters.
  List<LibraryManga> _pipeline(List<LibraryManga> list, LibraryState s) {
    bool tri(TriFilter f, bool matches) => switch (f) {
      TriFilter.ignore => true,
      TriFilter.include => matches,
      TriFilter.exclude => !matches,
    };
    final q = s.query.trim().toLowerCase();
    final filtered = list.where((m) {
      if (q.isNotEmpty && !m.manga.title.toLowerCase().contains(q)) {
        return false;
      }
      if (!tri(s.filterUnread, m.unreadCount > 0)) return false;
      if (!tri(s.filterCompleted, m.manga.status == MangaStatus.completed)) {
        return false;
      }
      if (!tri(s.filterDownloaded, m.downloadCount > 0)) return false;
      if (_settings.downloadedOnly && m.downloadCount == 0) return false;
      return true;
    }).toList();
    return _sort(filtered, s.sortMode, s.sortAscending);
  }

  /// Returns a new list sorted by [mode]; [ascending] flips the comparator.
  List<LibraryManga> _sort(
    List<LibraryManga> list,
    LibrarySortMode mode,
    bool ascending,
  ) {
    final sorted = [...list];
    int compare(LibraryManga a, LibraryManga b) {
      switch (mode) {
        case LibrarySortMode.alphabetical:
          return a.manga.title.toLowerCase().compareTo(
            b.manga.title.toLowerCase(),
          );
        case LibrarySortMode.unread:
          return a.unreadCount.compareTo(b.unreadCount);
        case LibrarySortMode.dateAdded:
          return (a.manga.dateAdded ?? DateTime(0)).compareTo(
            b.manga.dateAdded ?? DateTime(0),
          );
        case LibrarySortMode.lastUpdate:
          return (a.manga.lastUpdate ?? DateTime(0)).compareTo(
            b.manga.lastUpdate ?? DateTime(0),
          );
      }
    }

    sorted.sort((a, b) => ascending ? compare(a, b) : compare(b, a));
    return sorted;
  }
}
