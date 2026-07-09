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
        final existingUrls = existing.map((e) => e.url).toSet();
        for (var i = 0; i < chapters.length; i++) {
          final ch = chapters[i];
          if (existingUrls.contains(ch.url)) continue;
          await _db.into(_db.chapters).insert(
                ChaptersCompanion.insert(
                  mangaId: m.id,
                  url: ch.url,
                  name: ch.name,
                  scanlator: Value(ch.scanlator),
                  chapterNumber: Value(ch.chapterNumber),
                  dateUpload: Value(ch.dateUpload),
                  dateFetch: Value(DateTime.now()),
                  sourceOrder: Value(i),
                ),
              );
          newChapters++;
        }
      } catch (_) {
        // skip this source for this run
      }
    }
    return newChapters;
  }
}
