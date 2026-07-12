import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';

import 'package:hondana/core/config/advanced_preferences.dart';
import 'package:hondana/core/database/app_database.dart';
import 'package:hondana/core/di/di_container.dart';
import 'package:hondana/features/browse/data/source/local_source.dart';
import 'package:hondana/features/browse/domain/source/model/manga_status.dart';
import 'package:hondana/features/browse/domain/source/model/s_manga.dart';
import 'package:hondana/features/browse/domain/source/source_manager.dart';
import 'package:hondana/features/downloads/domain/download_preferences.dart';
import 'package:hondana/features/downloads/presentation/bloc/downloads_bloc.dart';
import 'package:hondana/features/downloads/presentation/bloc/downloads_event.dart';
import 'package:hondana/features/library/domain/library_preferences.dart';

/// Refreshes chapter lists for every favorite via its [Source], honoring the
/// Settings > Library global-update knobs (category include/exclude, smart
/// skips, metadata refresh) plus auto-download of new chapters. Returns the
/// number of newly-inserted chapters. Source errors are swallowed per-manga so
/// one broken source doesn't abort the whole run.
@lazySingleton
class LibraryUpdateService {
  LibraryUpdateService(this._db, this._sources);

  final AppDatabase _db;
  final SourceManager _sources;

  /// Runs one global-update pass over all favorites and returns the total
  /// count of newly-inserted chapters. See the class doc for the honored knobs.
  Future<int> refreshAll() async {
    final libPrefs = getIt<LibraryPreferences>();
    final dlPrefs = getIt<DownloadPreferences>();
    final advPrefs = getIt<AdvancedPreferences>();

    final include = libPrefs.updateIncludeCategoryIds;
    final exclude = libPrefs.updateExcludeCategoryIds;
    final refreshMetadata = libPrefs.autoRefreshMetadata;
    final refreshTitles = advPrefs.updateTitlesFromSource;
    final downloadNew = dlPrefs.downloadNewChapters;
    final dlInclude = dlPrefs.downloadNewIncludeCategoryIds;
    final dlExclude = dlPrefs.downloadNewExcludeCategoryIds;

    final favorites = await (_db.select(
      _db.mangas,
    )..where((m) => m.favorite.equals(true))).get();
    final categoriesOf = await _mangaCategories();

    var newChapters = 0;
    for (final m in favorites) {
      final cats = categoriesOf[m.id] ?? const <int>{};
      if (!_passesCategories(cats, include, exclude)) continue;
      // Smart update: skip completed entries (Mihon ENTRY_NON_COMPLETED).
      if (libPrefs.skipUpdateCompleted &&
          m.status == MangaStatus.completed.index) {
        continue;
      }
      final source = _sources.get(m.source);
      if (source == null) continue;
      try {
        final existing = await (_db.select(
          _db.chapters,
        )..where((c) => c.mangaId.equals(m.id))).get();
        // Smart update: unread / unstarted skips only apply once the entry
        // has chapters — an empty entry still needs its initial fetch.
        if (existing.isNotEmpty) {
          final unread = existing.where((c) => !c.read).length;
          if (libPrefs.skipUpdateWithUnread && unread > 0) continue;
          if (libPrefs.skipUpdateUnstarted && unread == existing.length) {
            continue;
          }
        }

        final sManga = SManga(url: m.url, title: m.title);
        final chapters = await source.getChapterList(sManga);
        final byUrl = {for (final c in existing) c.url: c};
        final now = DateTime.now();
        // Re-sync sourceOrder for EVERY chapter to its position in the freshly
        // fetched list (0 = newest). Inserting new chapters with a bare index
        // would collide with existing rows' orders and break the ordering
        // invariant the reader/details sort depend on — so update in place too.
        // New rows are inserted individually so their generated ids are known
        // (needed to enqueue auto-downloads); updates stay batched.
        final added = <({int id, String name, int order})>[];
        final updates = <(int id, int order, dynamic ch)>[];
        for (var i = 0; i < chapters.length; i++) {
          final ch = chapters[i];
          final prev = byUrl[ch.url];
          if (prev == null) {
            final id = await _db
                .into(_db.chapters)
                .insert(
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
            added.add((id: id, name: ch.name, order: i));
          } else {
            updates.add((prev.id, i, ch));
          }
        }
        await _db.batch((batch) {
          for (final (id, order, ch) in updates) {
            batch.update(
              _db.chapters,
              ChaptersCompanion(
                name: Value(ch.name as String),
                scanlator: Value(ch.scanlator as String?),
                chapterNumber: Value(ch.chapterNumber as double),
                sourceOrder: Value(order),
              ),
              where: (c) => c.id.equals(id),
            );
          }
        });
        if (added.isNotEmpty) {
          // Stamp lastUpdate so the library's "last updated" sort works
          // (the column was otherwise never written).
          await (_db.update(_db.mangas)..where((row) => row.id.equals(m.id)))
              .write(MangasCompanion(lastUpdate: Value(now)));
          newChapters += added.length;

          // Auto-download new chapters (Settings > Downloads), respecting its
          // own category include/exclude sets. Local-source entries have
          // nothing to download.
          if (downloadNew &&
              m.source != LocalSource.localSourceId &&
              _passesCategories(cats, dlInclude, dlExclude)) {
            final downloads = getIt<DownloadsBloc>();
            // Enqueue in reading order (chapter 1 first — Mihon behavior).
            added.sort((a, b) => b.order.compareTo(a.order));
            for (final c in added) {
              downloads.add(
                DownloadEnqueued(
                  chapterId: c.id,
                  mangaId: m.id,
                  mangaTitle: m.title,
                  chapterName: c.name,
                ),
              );
            }
          }
        }

        // "Automatically refresh metadata" and Advanced > "Update titles from
        // source" — one details fetch covers both; each flag only writes the
        // columns it owns.
        if (refreshMetadata || refreshTitles) {
          final details = await source.getMangaDetails(sManga);
          await (_db.update(
            _db.mangas,
          )..where((row) => row.id.equals(m.id))).write(
            MangasCompanion(
              title: refreshTitles && details.title.isNotEmpty
                  ? Value(details.title)
                  : const Value.absent(),
              author: refreshMetadata
                  ? Value(details.author)
                  : const Value.absent(),
              artist: refreshMetadata
                  ? Value(details.artist)
                  : const Value.absent(),
              description: refreshMetadata
                  ? Value(details.description)
                  : const Value.absent(),
              genre: refreshMetadata
                  ? Value(details.genre.join(', '))
                  : const Value.absent(),
              status: refreshMetadata
                  ? Value(details.status.index)
                  : const Value.absent(),
              thumbnailUrl: refreshMetadata
                  ? Value(details.thumbnailUrl)
                  : const Value.absent(),
            ),
          );
        }
      } catch (_) {
        // skip this source for this run
      }
    }
    return newChapters;
  }

  /// Tri-state category gate: any excluded category loses; a non-empty
  /// include set requires at least one match (empty include = all).
  bool _passesCategories(Set<int> cats, Set<int> include, Set<int> exclude) {
    if (cats.any(exclude.contains)) return false;
    if (include.isNotEmpty && !cats.any(include.contains)) return false;
    return true;
  }

  Future<Map<int, Set<int>>> _mangaCategories() async {
    final rows = await _db.select(_db.mangasCategories).get();
    final map = <int, Set<int>>{};
    for (final row in rows) {
      map.putIfAbsent(row.mangaId, () => <int>{}).add(row.categoryId);
    }
    return map;
  }
}
