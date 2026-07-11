import 'package:hondana/features/browse/domain/source/model/filter.dart';
import 'package:hondana/features/browse/domain/source/model/manga_page.dart';
import 'package:hondana/features/browse/domain/source/model/mangas_page.dart';
import 'package:hondana/features/browse/domain/source/model/s_chapter.dart';
import 'package:hondana/features/browse/domain/source/model/s_manga.dart';

/// The seam the whole app codes against. Concrete remote implementations arrive
/// with the extension runtime (iOS phase); phase 1 ships [LocalSource].
abstract interface class Source {
  /// Stable Tachiyomi source id (persisted with library rows).
  int get id;
  String get name;

  /// Content language code (e.g. `en`, `all`).
  String get lang;

  /// Fills in a manga's full metadata (called when [SManga.initialized] is false).
  Future<SManga> getMangaDetails(SManga manga);

  /// Lists the manga's chapters, newest-first per Mihon convention.
  Future<List<SChapter>> getChapterList(SManga manga);

  /// Lists a chapter's pages in reading order.
  Future<List<MangaPage>> getPageList(SChapter chapter);
}

/// A browsable source: catalogue listings + search.
abstract interface class CatalogueSource implements Source {
  /// Whether [getLatestUpdates] is meaningful for this source.
  bool get supportsLatest;

  Future<MangasPage> getPopularManga(int page);
  Future<MangasPage> getLatestUpdates(int page);

  /// Searches the catalogue, applying free-text [query] and [filters].
  Future<MangasPage> getSearchManga(int page, String query, FilterList filters);

  /// The filters this source exposes in the search sheet.
  FilterList getFilterList();
}

/// Base for network sources. Implementation (Dio wiring, image resolution) is
/// deferred to the extension runtime; declared here so the seam is explicit.
abstract class HttpSource implements CatalogueSource {
  String get baseUrl;

  /// Resolves a page's [MangaPage.url] to a direct image URL. Direct-URL pages
  /// return [MangaPage.imageUrl] unchanged.
  Future<String> getImageUrl(MangaPage page);
}
