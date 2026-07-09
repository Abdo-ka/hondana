import 'package:mihonx/features/browse/domain/source/model/filter.dart';
import 'package:mihonx/features/browse/domain/source/model/manga_page.dart';
import 'package:mihonx/features/browse/domain/source/model/mangas_page.dart';
import 'package:mihonx/features/browse/domain/source/model/s_chapter.dart';
import 'package:mihonx/features/browse/domain/source/model/s_manga.dart';

/// The seam the whole app codes against. Concrete remote implementations arrive
/// with the extension runtime (iOS phase); phase 1 ships [LocalSource].
abstract interface class Source {
  int get id;
  String get name;
  String get lang;

  Future<SManga> getMangaDetails(SManga manga);
  Future<List<SChapter>> getChapterList(SManga manga);
  Future<List<MangaPage>> getPageList(SChapter chapter);
}

/// A browsable source: catalogue listings + search.
abstract interface class CatalogueSource implements Source {
  bool get supportsLatest;

  Future<MangasPage> getPopularManga(int page);
  Future<MangasPage> getLatestUpdates(int page);
  Future<MangasPage> getSearchManga(int page, String query, FilterList filters);

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
