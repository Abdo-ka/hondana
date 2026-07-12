import 'package:hondana/core/database/app_database.dart';
import 'package:hondana/features/browse/domain/source/model/s_chapter.dart';
import 'package:hondana/features/browse/domain/source/model/s_manga.dart';
import 'package:hondana/features/library/domain/manga.dart';

/// Persistence for a single manga: caches browsed source manga, toggles the
/// library flag, and syncs its chapters. Streams so the details screen and the
/// library stay in lock-step. Implemented in the data layer by
/// `MangaRepositoryImp`.
abstract interface class MangaRepository {
  /// Upserts the source manga and returns its local row id (favorite untouched).
  Future<int> resolveManga(int sourceId, SManga sManga);

  /// Streams the persisted manga row; null until [resolveManga] has run.
  Stream<Manga?> watchManga(int mangaId);

  /// Streams this manga's chapters, newest first (source order).
  Stream<List<ChapterData>> watchChapters(int mangaId);

  /// Adds/removes the manga from the library.
  Future<void> setFavorite(int mangaId, bool favorite);

  /// Overwrites cached metadata from a fresh source fetch.
  Future<void> updateDetails(int mangaId, SManga details);

  /// Upserts the source chapter list, preserving per-chapter read state.
  Future<void> syncChapters(int mangaId, List<SChapter> chapters);

  /// Marks a chapter read/unread.
  Future<void> setChapterRead(int chapterId, bool read);

  /// One-shot fetch of the manga row.
  Future<MangaData?> getManga(int mangaId);

  /// One-shot fetch of a single chapter row.
  Future<ChapterData?> getChapter(int chapterId);

  /// Chapters for a manga in source order (ascending) — for reader navigation.
  Future<List<ChapterData>> getChaptersForManga(int mangaId);

  /// Persists resume position within a chapter.
  Future<void> setLastPageRead(int chapterId, int page);

  /// Toggles the chapter bookmark flag.
  Future<void> setChapterBookmark(int chapterId, bool bookmark);

  /// Per-series reading mode: 0 = app default, else ReadingMode.index + 1
  /// (Mihon's viewer_flags).
  Future<void> setViewerFlags(int mangaId, int flags);
}
