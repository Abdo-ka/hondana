import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mihonx/features/downloads/presentation/bloc/downloads_state.dart';

/// Persists the pending download queue (Mihon's DownloadStore): order and
/// identity of chapters still to download, so the queue survives app restarts
/// and OS kills. In-flight page progress is recovered separately from the
/// native downloader's task database.
@lazySingleton
class DownloadQueueStore {
  DownloadQueueStore(this._prefs);

  final SharedPreferences _prefs;
  static const _kQueue = 'downloads.queue';
  static const _kPaused = 'downloads.paused';

  List<DownloadTask> load() {
    final raw = _prefs.getString(_kQueue);
    if (raw == null) return const [];
    try {
      final list = jsonDecode(raw) as List;
      return list
          .whereType<Map<String, dynamic>>()
          .map(
            (e) => DownloadTask(
              chapterId: e['chapterId'] as int,
              mangaId: e['mangaId'] as int,
              mangaTitle: e['mangaTitle'] as String? ?? '',
              chapterName: e['chapterName'] as String? ?? '',
            ),
          )
          .toList();
    } on Exception {
      return const [];
    }
  }

  /// Stores only chapters that still need work; downloading collapses back to
  /// queued because a restart restarts the chapter.
  Future<void> save(List<DownloadTask> queue) => _prefs.setString(
        _kQueue,
        jsonEncode([
          for (final t in queue.where((t) => t.isActive))
            {
              'chapterId': t.chapterId,
              'mangaId': t.mangaId,
              'mangaTitle': t.mangaTitle,
              'chapterName': t.chapterName,
            },
        ]),
      );

  bool get paused => _prefs.getBool(_kPaused) ?? false;

  Future<void> setPaused(bool value) => _prefs.setBool(_kPaused, value);
}
