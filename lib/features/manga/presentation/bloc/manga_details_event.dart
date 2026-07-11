/// Base type for [MangaDetailsBloc] events.
sealed class MangaDetailsEvent {
  const MangaDetailsEvent();
}

/// Screen opened: resolve the manga and start syncing details + chapters.
final class MangaDetailsStarted extends MangaDetailsEvent {
  const MangaDetailsStarted();
}

/// Internal: subscribe to the persisted manga row.
final class MangaWatchRequested extends MangaDetailsEvent {
  const MangaWatchRequested(this.mangaId);
  final int mangaId;
}

/// Internal: subscribe to the persisted chapter list.
final class ChaptersWatchRequested extends MangaDetailsEvent {
  const ChaptersWatchRequested(this.mangaId);
  final int mangaId;
}

/// User tapped the library button: add/remove this manga from the library.
final class MangaFavoriteToggled extends MangaDetailsEvent {
  const MangaFavoriteToggled();
}

/// Long-press on a chapter row: set its read state.
final class MangaChapterReadToggled extends MangaDetailsEvent {
  const MangaChapterReadToggled(this.chapterId, this.read);
  final int chapterId;
  final bool read;
}

/// Refresh action / pull-to-refresh: re-fetch chapters from the source.
final class MangaChaptersRefreshed extends MangaDetailsEvent {
  const MangaChaptersRefreshed();
}

/// Sort button: flip the chapter list between ascending and descending.
final class MangaChapterSortToggled extends MangaDetailsEvent {
  const MangaChapterSortToggled();
}
