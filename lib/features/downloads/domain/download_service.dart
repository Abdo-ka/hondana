import 'dart:io';

import 'package:injectable/injectable.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Filesystem store for downloaded chapters:
/// `<appDocuments>/downloads/<mangaId>/<chapterId>/pNNNN.<ext>` plus a `.done`
/// marker written after the last page. The marker is the source of truth for
/// "downloaded" — a partial download without it is treated as absent.
@lazySingleton
class DownloadService {
  Directory? _root;

  Future<Directory> root() async {
    if (_root != null) return _root!;
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(docs.path, 'downloads'));
    if (!dir.existsSync()) dir.createSync(recursive: true);
    return _root = dir;
  }

  Future<Directory> chapterDir(int mangaId, int chapterId) async {
    final base = await root();
    return Directory(p.join(base.path, '$mangaId', '$chapterId'));
  }

  /// Chapter directory relative to the app documents root — the `directory`
  /// value background download tasks must use so files land in the same
  /// layout as [chapterDir].
  String relativeChapterDir(int mangaId, int chapterId) =>
      p.join('downloads', '$mangaId', '$chapterId');

  Future<bool> isDownloaded(int mangaId, int chapterId) async {
    final dir = await chapterDir(mangaId, chapterId);
    return File(p.join(dir.path, '.done')).existsSync();
  }

  /// Sorted local page paths, or null when the chapter isn't fully downloaded.
  Future<List<String>?> localPages(int mangaId, int chapterId) async {
    final dir = await chapterDir(mangaId, chapterId);
    if (!File(p.join(dir.path, '.done')).existsSync()) return null;
    final pages = dir
        .listSync()
        .whereType<File>()
        .where((f) => p.basename(f.path) != '.done')
        .map((f) => f.path)
        .toList()
      ..sort();
    return pages;
  }

  Future<void> markDone(int mangaId, int chapterId) async {
    final dir = await chapterDir(mangaId, chapterId);
    await File(p.join(dir.path, '.done')).create(recursive: true);
  }

  Future<void> delete(int mangaId, int chapterId) async {
    final dir = await chapterDir(mangaId, chapterId);
    if (dir.existsSync()) await dir.delete(recursive: true);
  }

  /// Chapter ids with a `.done` marker — restores badges after app restart.
  Future<Set<int>> scanDownloadedChapterIds() async {
    final base = await root();
    final ids = <int>{};
    for (final mangaDir in base.listSync().whereType<Directory>()) {
      for (final chapterDir in mangaDir.listSync().whereType<Directory>()) {
        if (File(p.join(chapterDir.path, '.done')).existsSync()) {
          final id = int.tryParse(p.basename(chapterDir.path));
          if (id != null) ids.add(id);
        }
      }
    }
    return ids;
  }
}
