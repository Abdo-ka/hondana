import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';

import 'package:hondana/core/database/app_database.dart';
import 'package:hondana/features/history/domain/entities/history_item.dart';

/// Local (drift) data source for reading history — one row per chapter, joined
/// to chapter + manga for the feed.
@injectable
class HistoryLocalDataSource {
  HistoryLocalDataSource(this._db);

  final AppDatabase _db;

  /// Bumps the existing row's `lastRead` to now, or inserts a new one so a
  /// chapter is never duplicated in history.
  Future<void> upsert(int chapterId) async {
    final existing =
        await (_db.select(_db.historyEntries)
              ..where((h) => h.chapterId.equals(chapterId))
              ..limit(1))
            .getSingleOrNull();
    final now = DateTime.now();
    if (existing != null) {
      await (_db.update(_db.historyEntries)
            ..where((h) => h.id.equals(existing.id)))
          .write(HistoryEntriesCompanion(lastRead: Value(now)));
    } else {
      await _db
          .into(_db.historyEntries)
          .insert(
            HistoryEntriesCompanion.insert(
              chapterId: chapterId,
              lastRead: Value(now),
            ),
          );
    }
  }

  /// Streams history entries joined with their chapter + manga, ordered by
  /// most-recently-read first.
  Stream<List<HistoryItem>> watchHistory() {
    final query =
        _db.select(_db.historyEntries).join([
          innerJoin(
            _db.chapters,
            _db.chapters.id.equalsExp(_db.historyEntries.chapterId),
          ),
          innerJoin(_db.mangas, _db.mangas.id.equalsExp(_db.chapters.mangaId)),
        ])..orderBy([
          OrderingTerm(
            expression: _db.historyEntries.lastRead,
            mode: OrderingMode.desc,
          ),
        ]);
    return query.watch().map(
      (rows) => rows.map((row) {
        final h = row.readTable(_db.historyEntries);
        final c = row.readTable(_db.chapters);
        final m = row.readTable(_db.mangas);
        return HistoryItem(
          historyId: h.id,
          chapterId: c.id,
          mangaId: m.id,
          sourceId: m.source,
          mangaTitle: m.title,
          chapterName: c.name,
          mangaUrl: m.url,
          thumbnailUrl: m.thumbnailUrl,
          lastRead: h.lastRead,
        );
      }).toList(),
    );
  }

  /// Deletes a single history entry by its row id.
  Future<void> remove(int historyId) async {
    await (_db.delete(
      _db.historyEntries,
    )..where((h) => h.id.equals(historyId))).go();
  }

  /// Wipes all reading history.
  Future<void> clear() async {
    await _db.delete(_db.historyEntries).go();
  }
}
