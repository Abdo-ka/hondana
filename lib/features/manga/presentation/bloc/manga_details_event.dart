sealed class MangaDetailsEvent {
  const MangaDetailsEvent();
}

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

final class MangaFavoriteToggled extends MangaDetailsEvent {
  const MangaFavoriteToggled();
}

final class MangaChapterReadToggled extends MangaDetailsEvent {
  const MangaChapterReadToggled(this.chapterId, this.read);
  final int chapterId;
  final bool read;
}

final class MangaChaptersRefreshed extends MangaDetailsEvent {
  const MangaChaptersRefreshed();
}

final class MangaChapterSortToggled extends MangaDetailsEvent {
  const MangaChapterSortToggled();
}
