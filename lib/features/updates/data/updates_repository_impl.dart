import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';

import 'package:mihonx/core/database/app_database.dart';
import 'package:mihonx/features/updates/domain/updates_repository.dart';

@LazySingleton(as: UpdatesRepository)
class UpdatesRepositoryImpl implements UpdatesRepository {
  UpdatesRepositoryImpl(this._db);

  final AppDatabase _db;

  @override
  Stream<List<UpdateItem>> watchUpdates() {
    final query = _db.select(_db.chapters).join([
      innerJoin(_db.mangas, _db.mangas.id.equalsExp(_db.chapters.mangaId)),
    ])
      ..where(_db.mangas.favorite.equals(true))
      ..orderBy([
        OrderingTerm(
          expression: _db.chapters.dateUpload,
          mode: OrderingMode.desc,
        ),
      ])
      ..limit(300);
    return query.watch().map((rows) => rows.map((row) {
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
        }).toList());
  }
}
