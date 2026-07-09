import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart' show immutable;

import 'package:mihonx/core/state/bloc_status.dart';
import 'package:mihonx/features/library/domain/category.dart';
import 'package:mihonx/features/library/domain/library_manga.dart';
import 'package:mihonx/features/library/domain/library_preferences.dart';

const Object _undefined = Object();

@immutable
class LibraryState extends Equatable {
  const LibraryState({
    this.loadStatus = const BlocStatus.initial(),
    this.refreshStatus = const BlocStatus.initial(),
    this.categories = const [],
    this.selectedCategoryId,
    this.manga = const [],
    this.selectedIds = const {},
    this.displayMode = LibraryDisplayMode.comfortableGrid,
    this.sortMode = LibrarySortMode.alphabetical,
    this.sortAscending = true,
  });

  final BlocStatus loadStatus;
  final BlocStatus refreshStatus;
  final List<Category> categories;
  final int? selectedCategoryId;
  final List<LibraryManga> manga;
  final Set<int> selectedIds;
  final LibraryDisplayMode displayMode;
  final LibrarySortMode sortMode;
  final bool sortAscending;

  bool get isSelecting => selectedIds.isNotEmpty;
  bool get allSelected =>
      manga.isNotEmpty && selectedIds.length == manga.length;

  LibraryState copyWith({
    BlocStatus? loadStatus,
    BlocStatus? refreshStatus,
    List<Category>? categories,
    Object? selectedCategoryId = _undefined,
    List<LibraryManga>? manga,
    Set<int>? selectedIds,
    LibraryDisplayMode? displayMode,
    LibrarySortMode? sortMode,
    bool? sortAscending,
  }) {
    return LibraryState(
      loadStatus: loadStatus ?? this.loadStatus,
      refreshStatus: refreshStatus ?? this.refreshStatus,
      categories: categories ?? this.categories,
      selectedCategoryId: identical(selectedCategoryId, _undefined)
          ? this.selectedCategoryId
          : selectedCategoryId as int?,
      manga: manga ?? this.manga,
      selectedIds: selectedIds ?? this.selectedIds,
      displayMode: displayMode ?? this.displayMode,
      sortMode: sortMode ?? this.sortMode,
      sortAscending: sortAscending ?? this.sortAscending,
    );
  }

  @override
  List<Object?> get props => [
        loadStatus,
        refreshStatus,
        categories,
        selectedCategoryId,
        manga,
        selectedIds,
        displayMode,
        sortMode,
        sortAscending,
      ];
}
