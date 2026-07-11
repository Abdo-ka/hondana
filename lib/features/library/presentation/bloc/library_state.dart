import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart' show immutable;

import 'package:hondana/core/state/bloc_status.dart';
import 'package:hondana/features/library/domain/category.dart';
import 'package:hondana/features/library/domain/library_manga.dart';
import 'package:hondana/features/library/domain/library_preferences.dart';

/// Sentinel distinguishing "argument omitted" from an explicit `null` in
/// [LibraryState.copyWith], so `selectedCategoryId` can be cleared to `null`.
const Object _undefined = Object();

/// Immutable state of the library screen: content, view options, filters and
/// multi-select. [manga] is the finished, filtered-and-sorted list to render.
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
    this.query = '',
    this.filterUnread = TriFilter.ignore,
    this.filterCompleted = TriFilter.ignore,
    this.filterDownloaded = TriFilter.ignore,
  });

  /// Status of the library content stream (loading / empty / success / failure).
  final BlocStatus loadStatus;

  /// Status of the last global refresh request (drives the refresh spinner).
  final BlocStatus refreshStatus;
  final List<Category> categories;

  /// Active category tab; `null` is the "all" pseudo-category.
  final int? selectedCategoryId;

  /// Already filtered + sorted by the bloc.
  final List<LibraryManga> manga;

  /// IDs of manga chosen in multi-select mode.
  final Set<int> selectedIds;
  final LibraryDisplayMode displayMode;
  final LibrarySortMode sortMode;
  final bool sortAscending;

  /// Case-insensitive title search substring.
  final String query;

  /// Tri-state filter: keep only unread / only fully-read / ignore.
  final TriFilter filterUnread;

  /// Tri-state filter on completed publication status.
  final TriFilter filterCompleted;

  /// Tri-state filter on whether the manga has downloaded chapters.
  final TriFilter filterDownloaded;

  /// True while any manga is selected (multi-select mode is active).
  bool get isSelecting => selectedIds.isNotEmpty;

  /// True when every visible manga is selected.
  bool get allSelected =>
      manga.isNotEmpty && selectedIds.length == manga.length;

  /// True when any tri-state filter is set (used to highlight the filter icon).
  bool get hasActiveFilters =>
      filterUnread != TriFilter.ignore ||
      filterCompleted != TriFilter.ignore ||
      filterDownloaded != TriFilter.ignore;

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
    String? query,
    TriFilter? filterUnread,
    TriFilter? filterCompleted,
    TriFilter? filterDownloaded,
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
      query: query ?? this.query,
      filterUnread: filterUnread ?? this.filterUnread,
      filterCompleted: filterCompleted ?? this.filterCompleted,
      filterDownloaded: filterDownloaded ?? this.filterDownloaded,
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
    query,
    filterUnread,
    filterCompleted,
    filterDownloaded,
  ];
}
