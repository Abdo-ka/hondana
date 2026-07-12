import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';

import 'package:hondana/core/database/app_database.dart';
import 'package:hondana/services/download_service.dart';
import 'package:hondana/features/library/domain/category.dart';
import 'package:hondana/features/library/domain/library_manga.dart';
import 'package:hondana/features/library/domain/library_repository.dart';
import 'package:hondana/features/library/domain/manga.dart';

/// Drift-backed [LibraryRepository]. Keeps all query/joins logic here so the
/// domain layer stays drift-free.
@LazySingleton(as: LibraryRepository)
class LibraryRepositoryImpl implements LibraryRepository {
  LibraryRepositoryImpl(this._db, this._downloads);

  final AppDatabase _db;
  final DownloadService _downloads;

  /// Joins favorites to their chapters to compute the unread count per entry,
  /// then folds in filesystem-derived download counts. The optional
  /// [categoryId] inner-joins the category link table to scope the result.
  @override
  Stream<List<LibraryManga>> watchLibrary({int? categoryId}) {
    final unread = countAll(filter: _db.chapters.read.equals(false));
    final joins = <Join<HasResultSet, dynamic>>[
      leftOuterJoin(
        _db.chapters,
        _db.chapters.mangaId.equalsExp(_db.mangas.id),
      ),
    ];
    if (categoryId != null) {
      joins.add(
        innerJoin(
          _db.mangasCategories,
          _db.mangasCategories.mangaId.equalsExp(_db.mangas.id) &
              _db.mangasCategories.categoryId.equals(categoryId),
          useColumns: false,
        ),
      );
    }
    final query = _db.select(_db.mangas).join(joins)
      ..where(_db.mangas.favorite.equals(true))
      ..groupBy([_db.mangas.id])
      ..addColumns([unread]);
    return query.watch().asyncMap((rows) async {
      final downloadCounts = await _downloadCounts(
        rows.map((r) => r.readTable(_db.mangas).id).toList(),
      );
      return rows
          .map(
            (row) => LibraryManga(
              manga: Manga.fromData(row.readTable(_db.mangas)),
              unreadCount: row.read(unread) ?? 0,
              downloadCount: downloadCounts[row.readTable(_db.mangas).id] ?? 0,
            ),
          )
          .toList();
    });
  }

  /// Downloaded-chapter count per manga, from the filesystem `.done` markers.
  /// Best-effort: storage errors degrade to zero counts (e.g. in unit tests).
  Future<Map<int, int>> _downloadCounts(List<int> mangaIds) async {
    try {
      final ids = await _downloads.scanDownloadedChapterIds();
      if (ids.isEmpty || mangaIds.isEmpty) return const {};
      final chapters =
          await (_db.select(_db.chapters)..where(
                (c) => c.mangaId.isIn(mangaIds) & c.id.isIn(ids.toList()),
              ))
              .get();
      final counts = <int, int>{};
      for (final c in chapters) {
        counts[c.mangaId] = (counts[c.mangaId] ?? 0) + 1;
      }
      return counts;
    } catch (_) {
      return const {};
    }
  }

  @override
  Stream<List<Category>> watchCategories() {
    return (_db.select(_db.categories)
          ..orderBy([(c) => OrderingTerm(expression: c.position)]))
        .watch()
        .map((rows) => rows.map(Category.fromData).toList());
  }

  @override
  Future<int> favoriteCount() async {
    final count = countAll();
    final row =
        await (_db.selectOnly(_db.mangas)
              ..addColumns([count])
              ..where(_db.mangas.favorite.equals(true)))
            .getSingle();
    return row.read(count) ?? 0;
  }

  @override
  Future<void> removeFromLibrary(List<int> mangaIds) async {
    await (_db.update(_db.mangas)..where((m) => m.id.isIn(mangaIds))).write(
      const MangasCompanion(favorite: Value(false)),
    );
  }

  @override
  Future<void> setRead(List<int> mangaIds, bool read) async {
    await (_db.update(_db.chapters)..where((c) => c.mangaId.isIn(mangaIds)))
        .write(ChaptersCompanion(read: Value(read)));
  }

  @override
  Future<void> createCategory(String name) async {
    final maxPos = await (_db.selectOnly(
      _db.categories,
    )..addColumns([_db.categories.position.max()])).getSingle();
    await _db
        .into(_db.categories)
        .insert(
          CategoriesCompanion.insert(
            name: name,
            position: Value(
              (maxPos.read(_db.categories.position.max()) ?? 0) + 1,
            ),
          ),
        );
  }

  @override
  Future<void> renameCategory(int id, String name) async {
    await (_db.update(_db.categories)..where((c) => c.id.equals(id))).write(
      CategoriesCompanion(name: Value(name)),
    );
  }

  @override
  Future<void> deleteCategory(int id) async {
    await (_db.delete(_db.categories)..where((c) => c.id.equals(id))).go();
  }

  @override
  Future<void> setMangaCategories(
    List<int> mangaIds,
    List<int> categoryIds,
  ) async {
    await _db.batch((batch) {
      batch.deleteWhere(_db.mangasCategories, (t) => t.mangaId.isIn(mangaIds));
      batch.insertAll(_db.mangasCategories, [
        for (final m in mangaIds)
          for (final c in categoryIds)
            MangasCategoriesCompanion.insert(mangaId: m, categoryId: c),
      ]);
    });
  }
}
