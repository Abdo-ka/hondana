import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';

import 'package:hondana/core/database/app_database.dart';
import 'package:hondana/features/updates/domain/entities/update_item.dart';

/// Local (drift) data source for the Updates feed — the newest chapters of
/// favorited manga.
@injectable
class UpdatesLocalDataSource {
  UpdatesLocalDataSource(this._db);

  final AppDatabase _db;

  /// Watches chapters joined to their favorited manga, newest upload first,
  /// capped at 300 rows to bound the query. Mihon behavior: the Updates feed
  /// only surfaces library (favorited) entries.
  Stream<List<UpdateItem>> watchUpdates() {
    final query =
        _db.select(_db.chapters).join([
            innerJoin(
              _db.mangas,
              _db.mangas.id.equalsExp(_db.chapters.mangaId),
            ),
          ])
          ..where(_db.mangas.favorite.equals(true))
          ..orderBy([
            OrderingTerm(
              expression: _db.chapters.dateUpload,
              mode: OrderingMode.desc,
            ),
          ])
          ..limit(300);
    return query.watch().map(
      (rows) => rows.map((row) {
        final c = row.readTable(_db.chapters);
        final m = row.readTable(_db.mangas);
        return UpdateItem(
          chapterId: c.id,
          mangaId: m.id,
          sourceId: m.source,
          mangaTitle: m.title,
          chapterName: c.name,
          read: c.read,
          thumbnailUrl: m.thumbnailUrl,
          dateUpload: c.dateUpload,
        );
      }).toList(),
    );
  }
}
