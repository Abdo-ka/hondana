import 'package:injectable/injectable.dart';

import 'package:hondana/core/database/app_database.dart';
import 'package:hondana/features/browse/domain/source/model/s_chapter.dart';
import 'package:hondana/features/browse/domain/source/model/s_manga.dart';
import 'package:hondana/features/library/domain/manga.dart';
import 'package:hondana/features/manga/data/data_sources/manga_local_datasource.dart';
import 'package:hondana/features/manga/domain/repositories/manga_repository.dart';

/// Default [MangaRepository] — delegates to the local (drift) data source. The
/// details bloc handles source (network) fetches; persistence stays local.
@LazySingleton(as: MangaRepository)
class MangaRepositoryImp implements MangaRepository {
  MangaRepositoryImp(this._local);

  final MangaLocalDataSource _local;

  @override
  Future<int> resolveManga(int sourceId, SManga sManga) =>
      _local.resolveManga(sourceId, sManga);

  @override
  Stream<Manga?> watchManga(int mangaId) => _local.watchManga(mangaId);

  @override
  Stream<List<ChapterData>> watchChapters(int mangaId) =>
      _local.watchChapters(mangaId);

  @override
  Future<void> setFavorite(int mangaId, bool favorite) =>
      _local.setFavorite(mangaId, favorite);

  @override
  Future<void> updateDetails(int mangaId, SManga details) =>
      _local.updateDetails(mangaId, details);

  @override
  Future<void> syncChapters(int mangaId, List<SChapter> chapters) =>
      _local.syncChapters(mangaId, chapters);

  @override
  Future<void> setChapterRead(int chapterId, bool read) =>
      _local.setChapterRead(chapterId, read);

  @override
  Future<MangaData?> getManga(int mangaId) => _local.getManga(mangaId);

  @override
  Future<ChapterData?> getChapter(int chapterId) =>
      _local.getChapter(chapterId);

  @override
  Future<List<ChapterData>> getChaptersForManga(int mangaId) =>
      _local.getChaptersForManga(mangaId);

  @override
  Future<void> setLastPageRead(int chapterId, int page) =>
      _local.setLastPageRead(chapterId, page);

  @override
  Future<void> setChapterBookmark(int chapterId, bool bookmark) =>
      _local.setChapterBookmark(chapterId, bookmark);

  @override
  Future<void> setViewerFlags(int mangaId, int flags) =>
      _local.setViewerFlags(mangaId, flags);
}
