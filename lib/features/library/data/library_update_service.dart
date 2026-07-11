import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';

import 'package:mihonx/core/database/app_database.dart';
import 'package:mihonx/features/browse/domain/source/model/s_manga.dart';
import 'package:mihonx/features/browse/domain/source/source_manager.dart';

/// Refreshes chapter lists for every favorite via its [Source]. Returns the
/// number of newly-inserted chapters. Source errors are swallowed per-manga so
/// one broken source doesn't abort the whole run.
@lazySingleton
class LibraryUpdateService {
  LibraryUpdateService(this._db, this._sources);

  final AppDatabase _db;
  final SourceManager _sources;

  Future<int> refreshAll() async {
    final favorites = await (_db.select(_db.mangas)
          ..where((m) => m.favorite.equals(true)))
        .get();
    var newChapters = 0;
    for (final m in favorites) {
      final source = _sources.get(m.source);
      if (source == null) continue;
      try {
        final chapters =
            await source.getChapterList(SManga(url: m.url, title: m.title));
        final existing = await (_db.select(_db.chapters)
              ..where((c) => c.mangaId.equals(m.id)))
            .get();
        final byUrl = {for (final c in existing) c.url: c};
        final now = DateTime.now();
        var added = 0;
        // Re-sync sourceOrder for EVERY chapter to its position in the freshly
        // fetched list (0 = newest). Inserting new chapters with a bare index
        // would collide with existing rows' orders and break the ordering
        // invariant the reader/details sort depend on — so update in place too.
        await _db.batch((batch) {
          for (var i = 0; i < chapters.length; i++) {
            final ch = chapters[i];
            final prev = byUrl[ch.url];
            if (prev == null) {
              batch.insert(
                _db.chapters,
                ChaptersCompanion.insert(
                  mangaId: m.id,
                  url: ch.url,
                  name: ch.name,
                  scanlator: Value(ch.scanlator),
                  chapterNumber: Value(ch.chapterNumber),
                  dateUpload: Value(ch.dateUpload),
                  dateFetch: Value(now),
                  sourceOrder: Value(i),
                ),
              );
              added++;
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
        if (added > 0) {
          // Stamp lastUpdate so the library's "last updated" sort works
          // (the column was otherwise never written).
          await (_db.update(_db.mangas)..where((row) => row.id.equals(m.id)))
              .write(MangasCompanion(lastUpdate: Value(now)));
        }
        newChapters += added;
      } catch (_) {
        // skip this source for this run
      }
    }
    return newChapters;
  }
}
