import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'package:mihonx/core/error/app_exception.dart';
import 'package:mihonx/core/state/bloc_status.dart';
import 'package:mihonx/features/library/data/library_update_service.dart';
import 'package:mihonx/features/library/domain/library_manga.dart';
import 'package:mihonx/features/library/domain/library_preferences.dart';
import 'package:mihonx/features/library/domain/library_repository.dart';
import 'package:mihonx/features/library/presentation/bloc/library_event.dart';
import 'package:mihonx/features/library/presentation/bloc/library_state.dart';

@injectable
class LibraryBloc extends Bloc<LibraryEvent, LibraryState> {
  LibraryBloc(this._repo, LibraryPreferences prefs, this._updater)
      : _prefs = prefs,
        super(LibraryState(
          displayMode: prefs.displayMode,
          sortMode: prefs.sortMode,
          sortAscending: prefs.sortAscending,
        )) {
    on<LibraryCategoriesSubscribed>(_onCategories, transformer: restartable());
    on<LibrarySubscribed>(_onSubscribe, transformer: restartable());
    on<LibraryCategorySelected>(_onCategorySelected);
    on<LibraryDisplayModeChanged>(_onDisplayMode);
    on<LibrarySortChanged>(_onSort);
    on<LibraryItemSelectionToggled>(_onToggle);
    on<LibrarySelectionCleared>(
      (e, emit) => emit(state.copyWith(selectedIds: const {})),
    );
    on<LibrarySelectAllToggled>(_onSelectAll);
    on<LibrarySelectedRemoved>(_onRemove);
    on<LibrarySelectedMarkedRead>(_onMarkRead);
    on<LibraryRefreshRequested>(_onRefresh, transformer: droppable());
  }

  final LibraryRepository _repo;
  final LibraryPreferences _prefs;
  final LibraryUpdateService _updater;

  Future<void> _onCategories(
    LibraryCategoriesSubscribed event,
    Emitter<LibraryState> emit,
  ) {
    return emit.forEach(
      _repo.watchCategories(),
      onData: (categories) => state.copyWith(categories: categories),
    );
  }

  Future<void> _onSubscribe(
    LibrarySubscribed event,
    Emitter<LibraryState> emit,
  ) async {
    if (kDebugMode) await _repo.seedDevDataIfEmpty();
    emit(state.copyWith(loadStatus: const BlocStatus.loading()));
    await emit.forEach(
      _repo.watchLibrary(categoryId: state.selectedCategoryId),
      onData: (list) {
        final sorted = _sort(list, state.sortMode, state.sortAscending);
        return state.copyWith(
          manga: sorted,
          loadStatus: sorted.isEmpty
              ? const BlocStatus.empty()
              : const BlocStatus.success(),
        );
      },
      onError: (err, st) => state.copyWith(
        loadStatus: BlocStatus.failure(AppException.from(err, st)),
      ),
    );
  }

  void _onCategorySelected(
    LibraryCategorySelected event,
    Emitter<LibraryState> emit,
  ) {
    emit(state.copyWith(
      selectedCategoryId: event.categoryId,
      selectedIds: const {},
    ));
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
    emit(state.copyWith(
      sortMode: event.mode,
      sortAscending: event.ascending,
      manga: _sort(state.manga, event.mode, event.ascending),
    ));
  }

  void _onToggle(
    LibraryItemSelectionToggled event,
    Emitter<LibraryState> emit,
  ) {
    final next = Set<int>.from(state.selectedIds);
    if (!next.remove(event.mangaId)) next.add(event.mangaId);
    emit(state.copyWith(selectedIds: next));
  }

  void _onSelectAll(
    LibrarySelectAllToggled event,
    Emitter<LibraryState> emit,
  ) {
    if (state.allSelected) {
      emit(state.copyWith(selectedIds: const {}));
    } else {
      emit(state.copyWith(
        selectedIds: state.manga.map((m) => m.manga.id).toSet(),
      ));
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

  Future<void> _onRefresh(
    LibraryRefreshRequested event,
    Emitter<LibraryState> emit,
  ) async {
    emit(state.copyWith(refreshStatus: const BlocStatus.loading()));
    try {
      await _updater.refreshAll();
      emit(state.copyWith(refreshStatus: const BlocStatus.success()));
    } catch (err, st) {
      emit(state.copyWith(
        refreshStatus: BlocStatus.failure(AppException.from(err, st)),
      ));
    }
  }

  List<LibraryManga> _sort(
    List<LibraryManga> list,
    LibrarySortMode mode,
    bool ascending,
  ) {
    final sorted = [...list];
    int compare(LibraryManga a, LibraryManga b) {
      switch (mode) {
        case LibrarySortMode.alphabetical:
          return a.manga.title
              .toLowerCase()
              .compareTo(b.manga.title.toLowerCase());
        case LibrarySortMode.unread:
          return a.unreadCount.compareTo(b.unreadCount);
        case LibrarySortMode.dateAdded:
          return (a.manga.dateAdded ?? DateTime(0))
              .compareTo(b.manga.dateAdded ?? DateTime(0));
        case LibrarySortMode.lastUpdate:
          return (a.manga.lastUpdate ?? DateTime(0))
              .compareTo(b.manga.lastUpdate ?? DateTime(0));
      }
    }

    sorted.sort((a, b) => ascending ? compare(a, b) : compare(b, a));
    return sorted;
  }
}
