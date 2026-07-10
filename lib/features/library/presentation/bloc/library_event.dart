import 'package:mihonx/features/library/domain/library_preferences.dart';

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

final class LibraryCategorySelected extends LibraryEvent {
  const LibraryCategorySelected(this.categoryId);
  final int? categoryId;
}

final class LibraryDisplayModeChanged extends LibraryEvent {
  const LibraryDisplayModeChanged(this.mode);
  final LibraryDisplayMode mode;
}

final class LibrarySortChanged extends LibraryEvent {
  const LibrarySortChanged(this.mode, this.ascending);
  final LibrarySortMode mode;
  final bool ascending;
}

final class LibraryItemSelectionToggled extends LibraryEvent {
  const LibraryItemSelectionToggled(this.mangaId);
  final int mangaId;
}

final class LibrarySelectionCleared extends LibraryEvent {
  const LibrarySelectionCleared();
}

final class LibrarySelectAllToggled extends LibraryEvent {
  const LibrarySelectAllToggled();
}

final class LibrarySelectedRemoved extends LibraryEvent {
  const LibrarySelectedRemoved();
}

final class LibrarySelectedMarkedRead extends LibraryEvent {
  const LibrarySelectedMarkedRead(this.read);
  final bool read;
}

final class LibraryRefreshRequested extends LibraryEvent {
  const LibraryRefreshRequested();
}

final class LibrarySelectedSetCategories extends LibraryEvent {
  const LibrarySelectedSetCategories(this.categoryIds);
  final List<int> categoryIds;
}

final class LibrarySearchChanged extends LibraryEvent {
  const LibrarySearchChanged(this.query);
  final String query;
}

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
