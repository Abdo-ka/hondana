import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';

import 'package:mihonx/core/database/app_database.dart';
import 'package:mihonx/features/browse/domain/source/model/s_chapter.dart';
import 'package:mihonx/features/browse/domain/source/model/s_manga.dart';
import 'package:mihonx/features/library/domain/manga.dart';
import 'package:mihonx/features/manga/domain/manga_repository.dart';

@LazySingleton(as: MangaRepository)
class MangaRepositoryImpl implements MangaRepository {
  MangaRepositoryImpl(this._db);

  final AppDatabase _db;

  @override
  Future<int> resolveManga(int sourceId, SManga s) async {
    final existing = await (_db.select(_db.mangas)
          ..where((m) => m.source.equals(sourceId) & m.url.equals(s.url))
          ..limit(1))
        .getSingleOrNull();
    if (existing != null) return existing.id;
    return _db.into(_db.mangas).insert(
          MangasCompanion.insert(
            source: sourceId,
            url: s.url,
            title: s.title,
            author: Value(s.author),
            artist: Value(s.artist),
            description: Value(s.description),
            genre: Value(s.genre.join(', ')),
            status: Value(s.status.index),
            thumbnailUrl: Value(s.thumbnailUrl),
          ),
        );
  }

  @override
  Stream<Manga?> watchManga(int mangaId) {
    return (_db.select(_db.mangas)..where((m) => m.id.equals(mangaId)))
        .watchSingleOrNull()
        .map((d) => d == null ? null : Manga.fromData(d));
  }

  @override
  Stream<List<ChapterData>> watchChapters(int mangaId) {
    return (_db.select(_db.chapters)
          ..where((c) => c.mangaId.equals(mangaId))
          ..orderBy([
            (c) => OrderingTerm(
                  expression: c.sourceOrder,
                  mode: OrderingMode.desc,
                ),
          ]))
        .watch();
  }

  @override
  Future<void> setFavorite(int mangaId, bool favorite) async {
    await (_db.update(_db.mangas)..where((m) => m.id.equals(mangaId))).write(
      MangasCompanion(
        favorite: Value(favorite),
        dateAdded: favorite ? Value(DateTime.now()) : const Value(null),
      ),
    );
  }

  @override
  Future<void> updateDetails(int mangaId, SManga d) async {
    await (_db.update(_db.mangas)..where((m) => m.id.equals(mangaId))).write(
      MangasCompanion(
        title: Value(d.title),
        author: Value(d.author),
        artist: Value(d.artist),
        description: Value(d.description),
        genre: Value(d.genre.join(', ')),
        status: Value(d.status.index),
        thumbnailUrl: Value(d.thumbnailUrl),
      ),
    );
  }

  @override
  Future<void> syncChapters(int mangaId, List<SChapter> chapters) async {
    final existing = await (_db.select(_db.chapters)
          ..where((c) => c.mangaId.equals(mangaId)))
        .get();
    final byUrl = {for (final c in existing) c.url: c};
    await _db.batch((batch) {
      for (var i = 0; i < chapters.length; i++) {
        final ch = chapters[i];
        final prev = byUrl[ch.url];
        if (prev == null) {
          batch.insert(
            _db.chapters,
            ChaptersCompanion.insert(
              mangaId: mangaId,
              url: ch.url,
              name: ch.name,
              scanlator: Value(ch.scanlator),
              chapterNumber: Value(ch.chapterNumber),
              dateUpload: Value(ch.dateUpload),
              dateFetch: Value(DateTime.now()),
              sourceOrder: Value(i),
            ),
          );
        } else {
          batch.update(
            _db.chapters,
            ChaptersCompanion(
              name: Value(ch.name),
              scanlator: Value(ch.scanlator),
              chapterNumber: Value(ch.chapterNumber),
              sourceOrder: Value(i),
            ),
            where: (c) => c.id.equals(prev.id),
          );
        }
      }
    });
  }

  @override
  Future<void> setChapterRead(int chapterId, bool read) async {
    await (_db.update(_db.chapters)..where((c) => c.id.equals(chapterId)))
        .write(ChaptersCompanion(read: Value(read)));
  }

  @override
  Future<MangaData?> getManga(int mangaId) =>
      (_db.select(_db.mangas)..where((m) => m.id.equals(mangaId)))
          .getSingleOrNull();

  @override
  Future<ChapterData?> getChapter(int chapterId) =>
      (_db.select(_db.chapters)..where((c) => c.id.equals(chapterId)))
          .getSingleOrNull();

  @override
  Future<List<ChapterData>> getChaptersForManga(int mangaId) =>
      (_db.select(_db.chapters)
            ..where((c) => c.mangaId.equals(mangaId))
            ..orderBy([(c) => OrderingTerm(expression: c.sourceOrder)]))
          .get();

  @override
  Future<void> setLastPageRead(int chapterId, int page) async {
    await (_db.update(_db.chapters)..where((c) => c.id.equals(chapterId)))
        .write(ChaptersCompanion(lastPageRead: Value(page)));
  }
}

