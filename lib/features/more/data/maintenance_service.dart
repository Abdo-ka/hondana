import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'package:hondana/core/config/advanced_preferences.dart';
import 'package:hondana/core/database/app_database.dart';
import 'package:hondana/core/network/app_http.dart';
import 'package:hondana/features/browse/domain/source/model/s_manga.dart';
import 'package:hondana/features/browse/domain/source/source_manager.dart';
import 'package:hondana/features/downloads/domain/download_service.dart';

/// Disk/database/network housekeeping behind Settings > Data and storage and
/// Settings > Advanced. Plain class — pages construct it with deps from getIt.
class MaintenanceService {
  MaintenanceService({
    required this.downloads,
    required this.db,
    required this.cookies,
    required this.sources,
    required this.advanced,
  });

  final DownloadService downloads;
  final AppDatabase db;
  final WebCookieStore cookies;
  final SourceManager sources;
  final AdvancedPreferences advanced;

  /// Total bytes + entry/chapter counts under the downloads directory.
  Future<({int totalBytes, int mangaCount, int chapterCount})>
  downloadsUsage() async {
    final root = await downloads.root();
    var bytes = 0;
    var mangas = 0;
    var chapters = 0;
    for (final mangaDir in root.listSync().whereType<Directory>()) {
      mangas++;
      for (final chapterDir in mangaDir.listSync().whereType<Directory>()) {
        chapters++;
        bytes += _dirBytes(chapterDir);
      }
    }
    return (totalBytes: bytes, mangaCount: mangas, chapterCount: chapters);
  }

  /// Current size of the chapter-image cache on disk.
  Future<int> chapterCacheBytes() async {
    final tmp = await getTemporaryDirectory();
    final dir = Directory(
      p.join(tmp.path, AppImageCache.manager.config.cacheKey),
    );
    if (!dir.existsSync()) return 0;
    return _dirBytes(dir);
  }

  int _dirBytes(Directory dir) {
    var bytes = 0;
    try {
      for (final f in dir.listSync(recursive: true).whereType<File>()) {
        try {
          bytes += f.lengthSync();
        } on FileSystemException {
          // Deleted mid-scan — skip.
        }
      }
    } on FileSystemException {
      // Directory vanished mid-scan.
    }
    return bytes;
  }

  /// Clears the disk image cache and Flutter's in-memory decode cache.
  Future<void> clearChapterCache() async {
    await AppImageCache.manager.emptyCache();
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
  }

  /// Wipes every downloaded chapter (the caller rescans via DownloadsStarted).
  Future<void> deleteAllDownloads() async {
    final root = await downloads.root();
    for (final entry in root.listSync()) {
      try {
        await entry.delete(recursive: true);
      } on FileSystemException {
        // Already gone.
      }
    }
  }

  /// Deletes non-favorite entries and their chapters/history/category links.
  /// Children are removed explicitly — SQLite FK cascades only fire when the
  /// `foreign_keys` pragma is on, which the app database does not enable.
  /// Returns the number of entries deleted.
  Future<int> clearDatabase() {
    return db.transaction(() async {
      final rows = await (db.select(
        db.mangas,
      )..where((m) => m.favorite.equals(false))).get();
      if (rows.isEmpty) return 0;
      final ids = rows.map((m) => m.id).toList();
      final chapterIds = (await (db.select(
        db.chapters,
      )..where((c) => c.mangaId.isIn(ids))).get()).map((c) => c.id).toList();
      if (chapterIds.isNotEmpty) {
        await (db.delete(
          db.historyEntries,
        )..where((h) => h.chapterId.isIn(chapterIds))).go();
      }
      await (db.delete(db.chapters)..where((c) => c.mangaId.isIn(ids))).go();
      await (db.delete(
        db.mangasCategories,
      )..where((mc) => mc.mangaId.isIn(ids))).go();
      return (db.delete(db.mangas)..where((m) => m.id.isIn(ids))).go();
    });
  }

  /// Mihon's ResetViewerFlags: every entry falls back to the default reader
  /// settings. Returns the number of entries touched.
  Future<int> resetViewerFlags() => (db.update(
    db.mangas,
  )).write(const MangasCompanion(viewerFlags: Value(0)));

  /// Clears cookies replayed onto Dio/image requests and the WebView's own jar.
  Future<void> clearCookies() async {
    await cookies.clear();
    try {
      await CookieManager.instance().deleteAllCookies();
    } on Exception {
      // Native WebView unavailable (tests/simulator without plugin).
    }
  }

  /// Clears WebView cache + website data (WKWebsiteDataStore on iOS/macOS).
  Future<void> clearWebViewData() async {
    try {
      await InAppWebViewController.clearAllCache();
      if (Platform.isAndroid) {
        await WebStorageManager.instance().deleteAllData();
      } else {
        await WebStorageManager.instance().removeDataModifiedSince(
          dataTypes: WebsiteDataType.values,
          date: DateTime.fromMillisecondsSinceEpoch(0),
        );
      }
    } on Exception {
      // Native WebView unavailable.
    }
  }

  /// Mihon's MetadataUpdateJob: re-fetches details for every library entry,
  /// refreshing covers and metadata (titles too when the Advanced pref is on).
  /// Returns how many entries were refreshed; per-entry errors are skipped.
  Future<int> refreshLibraryCovers() async {
    final favorites = await (db.select(
      db.mangas,
    )..where((m) => m.favorite.equals(true))).get();
    final renameTitles = advanced.updateTitlesFromSource;
    var updated = 0;
    for (final m in favorites) {
      final source = sources.get(m.source);
      if (source == null) continue;
      try {
        final details = await source.getMangaDetails(
          SManga(url: m.url, title: m.title),
        );
        await (db.update(db.mangas)..where((r) => r.id.equals(m.id))).write(
          MangasCompanion(
            title: renameTitles && details.title.isNotEmpty
                ? Value(details.title)
                : const Value.absent(),
            artist: Value(details.artist ?? m.artist),
            author: Value(details.author ?? m.author),
            description: Value(details.description ?? m.description),
            genre: details.genre.isEmpty
                ? const Value.absent()
                : Value(details.genre.join(', ')),
            status: Value(details.status.index),
            thumbnailUrl: Value(details.thumbnailUrl ?? m.thumbnailUrl),
          ),
        );
        updated++;
      } on Exception {
        // One broken source must not abort the run.
      }
    }
    return updated;
  }
}
