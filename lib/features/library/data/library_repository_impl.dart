import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';

import 'package:mihonx/core/database/app_database.dart';
import 'package:mihonx/features/browse/data/source/local_source.dart';
import 'package:mihonx/features/library/domain/category.dart';
import 'package:mihonx/features/library/domain/library_manga.dart';
import 'package:mihonx/features/library/domain/library_repository.dart';
import 'package:mihonx/features/library/domain/manga.dart';

@LazySingleton(as: LibraryRepository)
class LibraryRepositoryImpl implements LibraryRepository {
  LibraryRepositoryImpl(this._db);

  final AppDatabase _db;

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
      joins.add(innerJoin(
        _db.mangasCategories,
        _db.mangasCategories.mangaId.equalsExp(_db.mangas.id) &
            _db.mangasCategories.categoryId.equals(categoryId),
        useColumns: false,
      ));
    }
    final query = _db.select(_db.mangas).join(joins)
      ..where(_db.mangas.favorite.equals(true))
      ..groupBy([_db.mangas.id])
      ..addColumns([unread]);
    return query.watch().map(
          (rows) => rows
              .map((row) => LibraryManga(
                    manga: Manga.fromData(row.readTable(_db.mangas)),
                    unreadCount: row.read(unread) ?? 0,
                  ))
              .toList(),
        );
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
    final row = await (_db.selectOnly(_db.mangas)
          ..addColumns([count])
          ..where(_db.mangas.favorite.equals(true)))
        .getSingle();
    return row.read(count) ?? 0;
  }

  @override
  Future<void> removeFromLibrary(List<int> mangaIds) async {
    await (_db.update(_db.mangas)..where((m) => m.id.isIn(mangaIds)))
        .write(const MangasCompanion(favorite: Value(false)));
  }

  @override
  Future<void> setRead(List<int> mangaIds, bool read) async {
    await (_db.update(_db.chapters)..where((c) => c.mangaId.isIn(mangaIds)))
        .write(ChaptersCompanion(read: Value(read)));
  }

  /// Test seam: set false to skip seeding (keeps widget tests free of network
  /// covers, whose cache manager leaves a pending timer).
  static bool devSeedEnabled = true;

  @override
  Future<void> seedDevDataIfEmpty() async {
    if (!devSeedEnabled) return;
    if (await favoriteCount() > 0) return;
    final now = DateTime.now();
    for (var i = 0; i < _seedTitles.length; i++) {
      final mangaId = await _db.into(_db.mangas).insert(
            MangasCompanion.insert(
              source: LocalSource.localSourceId,
              url: 'seed/$i',
              title: _seedTitles[i],
              author: Value('Author ${i + 1}'),
              description: Value('Sample entry for "${_seedTitles[i]}".'),
              genre: const Value('Action, Adventure'),
              status: Value(i.isEven ? 1 : 2),
              thumbnailUrl:
                  Value('https://picsum.photos/seed/mihonx$i/300/450'),
              favorite: const Value(true),
              dateAdded: Value(now),
              lastUpdate: Value(now.subtract(Duration(hours: i))),
            ),
          );
      final chapterCount = 8 + i;
      final readUpTo = i * 2;
      for (var c = 0; c < chapterCount; c++) {
        await _db.into(_db.chapters).insert(
              ChaptersCompanion.insert(
                mangaId: mangaId,
                url: 'seed/$i/ch/$c',
                name: 'Chapter ${c + 1}',
                read: Value(c < readUpTo),
                chapterNumber: Value((c + 1).toDouble()),
                dateUpload: Value(now.subtract(Duration(days: chapterCount - c))),
                sourceOrder: Value(c),
              ),
            );
      }
    }
  }

  static const _seedTitles = [
    'Solo Leveling',
    'One Piece',
    'Berserk',
    'Vinland Saga',
    'Chainsaw Man',
    'Vagabond',
  ];
}
