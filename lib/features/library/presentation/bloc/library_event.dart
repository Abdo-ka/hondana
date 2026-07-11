import 'package:hondana/features/library/domain/library_preferences.dart';

/// Base type for [LibraryBloc] events.
sealed class LibraryEvent {
  const LibraryEvent();
}

/// Start watching the category list.
final class LibraryCategoriesSubscribed extends LibraryEvent {
  const LibraryCategoriesSubscribed();
}

/// Start (or restart) watching library manga for the active category.
final class LibrarySubscribed extends LibraryEvent {
  const LibrarySubscribed();
}

/// Switch the active category tab; `null` means the "all" pseudo-category.
final class LibraryCategorySelected extends LibraryEvent {
  const LibraryCategorySelected(this.categoryId);
  final int? categoryId;
}

/// Change the grid/list display mode (also persisted to preferences).
final class LibraryDisplayModeChanged extends LibraryEvent {
  const LibraryDisplayModeChanged(this.mode);
  final LibraryDisplayMode mode;
}

/// Change the sort mode and direction (also persisted to preferences).
final class LibrarySortChanged extends LibraryEvent {
  const LibrarySortChanged(this.mode, this.ascending);
  final LibrarySortMode mode;
  final bool ascending;
}

/// Toggle selection of one manga in multi-select mode.
final class LibraryItemSelectionToggled extends LibraryEvent {
  const LibraryItemSelectionToggled(this.mangaId);
  final int mangaId;
}

/// Exit multi-select mode by clearing the selection.
final class LibrarySelectionCleared extends LibraryEvent {
  const LibrarySelectionCleared();
}

/// Select all currently-visible manga, or clear if already all-selected.
final class LibrarySelectAllToggled extends LibraryEvent {
  const LibrarySelectAllToggled();
}

/// Remove the selected manga from the library.
final class LibrarySelectedRemoved extends LibraryEvent {
  const LibrarySelectedRemoved();
}

/// Mark the selected manga's chapters read/unread.
final class LibrarySelectedMarkedRead extends LibraryEvent {
  const LibrarySelectedMarkedRead(this.read);
  final bool read;
}

/// Trigger a global library update (refresh chapters for all manga).
final class LibraryRefreshRequested extends LibraryEvent {
  const LibraryRefreshRequested();
}

/// Set the category membership of the selected manga.
final class LibrarySelectedSetCategories extends LibraryEvent {
  const LibrarySelectedSetCategories(this.categoryIds);
  final List<int> categoryIds;
}

/// Update the title search query; re-runs the filter pipeline.
final class LibrarySearchChanged extends LibraryEvent {
  const LibrarySearchChanged(this.query);
  final String query;
}

/// Which tri-state filter a [LibraryFilterCycled] event targets.
enum LibraryFilterKind { unread, completed, downloaded }

/// Cycles the given tri-state filter (ignore → include → exclude).
final class LibraryFilterCycled extends LibraryEvent {
  const LibraryFilterCycled(this.kind);
  final LibraryFilterKind kind;
}

/// Internal: re-evaluate filters (e.g. the global downloaded-only toggle).
final class LibraryFiltersRefreshed extends LibraryEvent {
  const LibraryFiltersRefreshed();
}
