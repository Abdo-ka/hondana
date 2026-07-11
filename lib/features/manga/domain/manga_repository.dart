import 'package:mihonx/core/database/app_database.dart';
import 'package:mihonx/features/browse/domain/source/model/s_chapter.dart';
import 'package:mihonx/features/browse/domain/source/model/s_manga.dart';
import 'package:mihonx/features/library/domain/manga.dart';

/// Persistence for a single manga: caches browsed source manga, toggles the
/// library flag, and syncs its chapters. Streams so the details screen and the
/// library stay in lock-step.
abstract interface class MangaRepository {
  /// Upserts the source manga and returns its local row id (favorite untouched).
  Future<int> resolveManga(int sourceId, SManga sManga);

  Stream<Manga?> watchManga(int mangaId);

  Stream<List<ChapterData>> watchChapters(int mangaId);

  Future<void> setFavorite(int mangaId, bool favorite);

  Future<void> updateDetails(int mangaId, SManga details);

  Future<void> syncChapters(int mangaId, List<SChapter> chapters);

  Future<void> setChapterRead(int chapterId, bool read);

  Future<MangaData?> getManga(int mangaId);

  Future<ChapterData?> getChapter(int chapterId);

  /// Chapters for a manga in source order (ascending) — for reader navigation.
  Future<List<ChapterData>> getChaptersForManga(int mangaId);

  Future<void> setLastPageRead(int chapterId, int page);

  Future<void> setChapterBookmark(int chapterId, bool bookmark);

  /// Per-series reading mode: 0 = app default, else ReadingMode.index + 1
  /// (Mihon's viewer_flags).
  Future<void> setViewerFlags(int mangaId, int flags);
}
