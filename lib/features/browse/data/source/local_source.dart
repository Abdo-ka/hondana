import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'package:hondana/features/browse/domain/source/model/filter.dart';
import 'package:hondana/features/browse/domain/source/model/manga_page.dart';
import 'package:hondana/features/browse/domain/source/model/mangas_page.dart';
import 'package:hondana/features/browse/domain/source/model/s_chapter.dart';
import 'package:hondana/features/browse/domain/source/model/s_manga.dart';
import 'package:hondana/features/browse/domain/source/source.dart';

/// A real, network-free source reading manga from `<appDocuments>/local/`.
///
/// Layout: `local/<Title>/` is a manga. If it has subfolders, each is a chapter;
/// otherwise the folder itself is a single chapter. Cover = `cover.*` or the
/// first image found. This lets the library/reader/downloads be exercised in
/// phase 1 with no extension runtime.
class LocalSource implements CatalogueSource {
  /// Fixed source id `0` — Mihon reserves id 0 for the built-in local source.
  static const int localSourceId = 0;

  @override
  int get id => localSourceId;
  @override
  String get name => 'Local source';
  @override
  String get lang => 'local';
  @override
  bool get supportsLatest => true;

  static const _imageExts = {
    '.jpg',
    '.jpeg',
    '.png',
    '.webp',
    '.gif',
    '.avif',
    '.bmp',
  };

  Directory? _baseDir;

  Future<Directory> _base() async {
    if (_baseDir != null) return _baseDir!;
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(docs.path, 'local'));
    if (!dir.existsSync()) dir.createSync(recursive: true);
    return _baseDir = dir;
  }

  bool _isImage(FileSystemEntity e) =>
      e is File && _imageExts.contains(p.extension(e.path).toLowerCase());

  String? _findCover(Directory mangaDir) {
    final entries = mangaDir.listSync();
    final cover = entries
        .whereType<File>()
        .where(
          (f) => p.basenameWithoutExtension(f.path).toLowerCase() == 'cover',
        )
        .firstOrNull;
    if (cover != null) return cover.path;
    // else first image anywhere one level down
    for (final e in entries) {
      if (_isImage(e)) return e.path;
      if (e is Directory) {
        final img = e.listSync().where(_isImage).firstOrNull;
        if (img != null) return img.path;
      }
    }
    return null;
  }

  Future<List<SManga>> _listManga() async {
    final base = await _base();
    return base
        .listSync()
        .whereType<Directory>()
        .map(
          (d) => SManga(
            url: p.basename(d.path),
            title: p.basename(d.path),
            thumbnailUrl: _findCover(d),
            initialized: true,
          ),
        )
        .toList();
  }

  Directory _mangaDir(String url) => Directory(p.join(_baseDir!.path, url));

  @override
  Future<MangasPage> getPopularManga(int page) async {
    final list = await _listManga()
      ..sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
    return MangasPage(mangas: list);
  }

  @override
  Future<MangasPage> getLatestUpdates(int page) async {
    await _base();
    final list = await _listManga()
      ..sort(
        (a, b) => _mangaDir(
          b.url,
        ).statSync().modified.compareTo(_mangaDir(a.url).statSync().modified),
      );
    return MangasPage(mangas: list);
  }

  @override
  Future<MangasPage> getSearchManga(
    int page,
    String query,
    FilterList filters,
  ) async {
    final q = query.toLowerCase();
    final list = (await _listManga())
        .where((m) => m.title.toLowerCase().contains(q))
        .toList();
    return MangasPage(mangas: list);
  }

  @override
  FilterList getFilterList() => [];

  @override
  Future<SManga> getMangaDetails(SManga manga) async {
    await _base();
    return manga.copyWith(
      thumbnailUrl: manga.thumbnailUrl ?? _findCover(_mangaDir(manga.url)),
      initialized: true,
    );
  }

  @override
  Future<List<SChapter>> getChapterList(SManga manga) async {
    await _base();
    final dir = _mangaDir(manga.url);
    final subDirs = dir.listSync().whereType<Directory>().toList();
    if (subDirs.isEmpty) {
      // The manga folder itself is the only chapter.
      return [SChapter(url: '', name: manga.title, chapterNumber: 1)];
    }
    subDirs.sort((a, b) => p.basename(a.path).compareTo(p.basename(b.path)));
    // ponytail: lexicographic order; add natural numeric sort when titles like
    // "Chapter 2" vs "Chapter 10" appear in the wild.
    return subDirs
        .map((d) => SChapter(url: p.basename(d.path), name: p.basename(d.path)))
        .toList();
  }

  @override
  Future<List<MangaPage>> getPageList(SChapter chapter) async {
    await _base();
    // chapter.url is empty for single-chapter manga → handled by caller passing
    // the manga folder; here we resolve relative to base when a subfolder.
    final chapterPath = chapter.url.isEmpty
        ? _baseDir!.path
        : p.join(_baseDir!.path, chapter.url);
    final dir = Directory(chapterPath);
    if (!dir.existsSync()) return const [];
    final images = dir.listSync().where(_isImage).map((e) => e.path).toList()
      ..sort();
    return List.generate(
      images.length,
      (i) => MangaPage(index: i, imageUrl: images[i]),
    );
  }
}
