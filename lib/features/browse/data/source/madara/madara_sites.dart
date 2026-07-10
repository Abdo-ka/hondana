import 'package:mihonx/features/browse/data/source/madara/madara_source.dart';

/// Concrete Madara sites, live-verified 2026-07. Source ids are the keiyoushi
/// index ids so the extensions catalog marks these as installed and future
/// Mihon migrations line up. Add more sites by copying this shape.
class _MadaraSite extends MadaraSource {
  _MadaraSite({
    required this.id,
    required this.name,
    required this.lang,
    required this.defaultBaseUrl,
    this.mangaSubString = 'manga',
    this.useLoadMoreRequest = false,
  });

  @override
  final int id;
  @override
  final String name;
  @override
  final String lang;
  @override
  final String defaultBaseUrl;
  @override
  final String mangaSubString;
  @override
  final bool useLoadMoreRequest;
}

/// English. Kept for test fixtures + as the sample en Madara site.
class ManhuausSource extends MadaraSource {
  @override
  int get id => 4005973248538140146;
  @override
  String get name => 'Manhuaus';
  @override
  String get lang => 'en';
  @override
  String get defaultBaseUrl => 'https://manhuaus.com';
}

/// All registered Madara sources.
List<MadaraSource> madaraSources() => [
  ManhuausSource(),
  // Arabic.
  _MadaraSite(
    id: 1073624495230267708,
    name: 'manga alashek',
    lang: 'ar',
    defaultBaseUrl: 'https://3asq.online',
  ),
  _MadaraSite(
    id: 918460697583900080,
    name: 'mangalek ',
    lang: 'ar',
    // lek-manga.net 301s here; the redirect drops POST bodies → HTTP 400.
    defaultBaseUrl: 'https://mangalik.net',
    useLoadMoreRequest: true,
  ),
  _MadaraSite(
    id: 3568795724496898351,
    name: 'mangalink',
    lang: 'ar',
    defaultBaseUrl: 'https://link-manga.net',
    useLoadMoreRequest: true,
  ),
  _MadaraSite(
    id: 2436176998646301840,
    name: 'MangaSpark',
    lang: 'ar',
    defaultBaseUrl: 'https://manga-spark.net',
  ),
  _MadaraSite(
    id: 6058166507489091982,
    name: 'Manga Starz',
    lang: 'ar',
    defaultBaseUrl: 'https://manga-starz.net',
  ),
  _MadaraSite(
    id: 2589550143244611118,
    name: 'MangaLionz',
    lang: 'ar',
    defaultBaseUrl: 'https://manga-lionz.org',
  ),
  _MadaraSite(
    id: 4177563748162518441,
    name: 'Hizo Manga',
    lang: 'ar',
    defaultBaseUrl: 'https://hizomanga.net',
    mangaSubString: 'serie',
    useLoadMoreRequest: true,
  ),
  _MadaraSite(
    id: 3301038340499911137,
    name: 'Rocks Manga',
    lang: 'ar',
    defaultBaseUrl: 'https://rocksmanga.com',
  ),
  _MadaraSite(
    id: 2056490261402651047,
    name: 'Anyone Manga',
    lang: 'ar',
    defaultBaseUrl: 'https://anyonemanga.com',
  ),
  _MadaraSite(
    id: 5702082694566979718,
    name: 'manga conan',
    lang: 'ar',
    defaultBaseUrl: 'https://manga.detectiveconanar.com',
  ),
];
