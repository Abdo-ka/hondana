import 'dart:convert';

import 'package:html/dom.dart';
import 'package:html/parser.dart' as html_parser;

import 'package:mihonx/features/browse/data/source/http_source_base.dart';
import 'package:mihonx/features/browse/domain/source/model/filter.dart';
import 'package:mihonx/features/browse/domain/source/model/manga_page.dart';
import 'package:mihonx/features/browse/domain/source/model/manga_status.dart';
import 'package:mihonx/features/browse/domain/source/model/mangas_page.dart';
import 'package:mihonx/features/browse/domain/source/model/s_chapter.dart';
import 'package:mihonx/features/browse/domain/source/model/s_manga.dart';

/// Dart port of keiyoushi's `MangaThemesia` multisrc theme (formerly
/// WPMangaStream / WPMangaReader) — the WordPress theme behind many Arabic
/// scanlation sites. A concrete source subclasses this with `id`, `name`,
/// `lang`, `baseUrl` and optional selector overrides.
///
/// Listings and search share one endpoint:
/// `GET {base}{mangaUrlDirectory}/?title=query&page=N&order=popular|update`.
/// Pages come from `div#readerarea img` with a fallback to the
/// `ts_reader.run({... "images": [...]})` script JSON.
abstract class ThemesiaSource extends HttpSourceBase {
  /// Path of the manga archive (`/manga` on most installs).
  String get mangaUrlDirectory => '/manga';

  @override
  bool get supportsLatest => true;

  @override
  FilterList getFilterList() => [];

  @override
  Map<String, String> get imageHeaders => {'Referer': '$baseUrl/'};

  // ── Catalogue ──────────────────────────────────────────────────────────────

  /// keiyoushi: `searchMangaSelector()`.
  String get searchMangaSelector =>
      '.utao .uta .imgu, .listupd .bs .bsx, .listo .bs .bsx';

  /// keiyoushi: `searchMangaNextPageSelector()`.
  String get searchMangaNextPageSelector => 'div.pagination .next, div.hpage .r';

  Future<MangasPage> _listing(int page, {String order = '', String query = ''}) async {
    final res = await client.get<String>(
      '$baseUrl$mangaUrlDirectory/',
      queryParameters: {
        'title': query,
        'page': '$page',
        if (order.isNotEmpty) 'order': order,
      },
    );
    return parseListing(res.data ?? '');
  }

  @override
  Future<MangasPage> getPopularManga(int page) => _listing(page, order: 'popular');

  @override
  Future<MangasPage> getLatestUpdates(int page) => _listing(page, order: 'update');

  @override
  Future<MangasPage> getSearchManga(int page, String query, FilterList _) =>
      _listing(page, query: query);

  /// Parses a listing/search page. Exposed for testing.
  MangasPage parseListing(String htmlBody) {
    final doc = html_parser.parse(htmlBody);
    final mangas = doc
        .querySelectorAll(searchMangaSelector)
        .map(searchMangaFromElement)
        .nonNulls
        .toList();
    final hasNext = doc.querySelector(searchMangaNextPageSelector) != null;
    return MangasPage(mangas: mangas, hasNextPage: hasNext);
  }

  /// Convenience: listing items only. Exposed for testing.
  List<SManga> parsePopular(String htmlBody) => parseListing(htmlBody).mangas;

  SManga? searchMangaFromElement(Element el) {
    final a = _selfOrChild(el, 'a');
    final href = a?.attributes['href'];
    if (href == null) return null;
    final title = listItemTitle(el, a!);
    if (title.isEmpty) return null;
    return SManga(
      url: _relative(href),
      title: title,
      thumbnailUrl: imgSrc(el.querySelector('img')),
    );
  }

  /// Base theme puts the title in the anchor's `title` attribute; skins that
  /// drop it (kenmanga/lava "manga-card" skins) override this.
  String listItemTitle(Element el, Element a) =>
      a.attributes['title']?.trim() ?? a.text.trim();

  // ── Details ────────────────────────────────────────────────────────────────

  String get seriesDetailsSelector =>
      'div.bigcontent, div.animefull, div.main-info, div.postbody';
  String get seriesTitleSelector =>
      'h1.entry-title, .ts-breadcrumb li:last-child span';
  String get seriesDescriptionSelector =>
      '.desc, .entry-content[itemprop=description]';
  String get seriesGenreSelector => 'div.gnr a, .mgen a, .seriestugenre a';
  String get seriesThumbnailSelector =>
      '.infomanga > div[itemprop=image] img, .thumb img';

  /// Labels for the `:contains(%s)` info-row selectors of the Kotlin theme.
  List<String> get seriesStatusKeywords =>
      const ['status', 'الحالة', 'حالة العمل'];
  List<String> get seriesAuthorKeywords =>
      const ['author', 'autor', 'المؤلف', 'mangaka', 'yazar'];
  List<String> get seriesArtistKeywords => const ['artist', 'الرسام', 'الناشر'];

  @override
  Future<SManga> getMangaDetails(SManga manga) async {
    final res = await client.get<String>('$baseUrl${manga.url}');
    return parseDetails(res.data ?? '', manga);
  }

  /// Parses a series page. Exposed for testing.
  SManga parseDetails(String htmlBody, SManga base) {
    final doc = html_parser.parse(htmlBody);
    final details = doc.querySelector(seriesDetailsSelector);
    if (details == null) return base;
    final title = details.querySelector(seriesTitleSelector)?.text.trim();
    final description = details
        .querySelectorAll(seriesDescriptionSelector)
        .map((e) => e.text.trim())
        .where((t) => t.isNotEmpty)
        .join('\n');
    final genres = details
        .querySelectorAll(seriesGenreSelector)
        .map((e) => e.text.trim())
        .where((t) => t.isNotEmpty)
        .toList();
    return base.copyWith(
      title: (title == null || title.isEmpty) ? base.title : title,
      author: _placeholderToNull(infoValue(details, seriesAuthorKeywords)),
      artist: _placeholderToNull(infoValue(details, seriesArtistKeywords)),
      description: description.isEmpty ? base.description : description,
      genre: genres,
      status: parseStatus(infoValue(details, seriesStatusKeywords)),
      thumbnailUrl:
          imgSrc(details.querySelector(seriesThumbnailSelector)) ??
              base.thumbnailUrl,
      initialized: true,
    );
  }

  /// Replicates the theme's `:contains(label)` info rows, which package:html
  /// selectors can't express: `.infotable tr`, `.tsinfo .imptdt`, `.fmed b+span`.
  String? infoValue(Element root, List<String> keys) {
    bool hasKey(String text) {
      final lower = text.toLowerCase();
      return keys.any((k) => lower.contains(k.toLowerCase()));
    }

    for (final tr in root.querySelectorAll('.infotable tr')) {
      if (!hasKey(tr.text)) continue;
      final tds = tr.querySelectorAll('td');
      if (tds.isNotEmpty) return tds.last.text.trim();
    }
    for (final row in root.querySelectorAll('.tsinfo .imptdt')) {
      if (!hasKey(row.text)) continue;
      final value = row.querySelector('i') ?? row.querySelector('a');
      if (value != null) return value.text.trim();
    }
    for (final b in root.querySelectorAll('.fmed b')) {
      if (!hasKey(b.text)) continue;
      final sibling = b.nextElementSibling;
      if (sibling?.localName == 'span') return sibling!.text.trim();
    }
    return null;
  }

  String? _placeholderToNull(String? value) {
    if (value == null) return null;
    const placeholders = {'', '-', 'N/A', 'n/a', 'Unknown'};
    return placeholders.contains(value) ? null : value;
  }

  /// Status keyword sets from the Kotlin theme (Arabic + English subset).
  MangaStatus parseStatus(String? s) {
    if (s == null) return MangaStatus.unknown;
    final t = s.toLowerCase();
    bool any(List<String> words) => words.any(t.contains);
    if (any(const ['مستمر', 'ongoing', 'on going', 'publishing', 'updating'])) {
      return MangaStatus.ongoing;
    }
    if (any(const ['مكتمل', 'completed', 'finished', 'one-shot'])) {
      return MangaStatus.completed;
    }
    if (any(const ['canceled', 'cancelled', 'dropped', 'discontinued', 'ملغي'])) {
      return MangaStatus.cancelled;
    }
    if (any(const ['hiatus', 'on hold', 'متوقف'])) return MangaStatus.onHiatus;
    return MangaStatus.unknown;
  }

  // ── Chapters ───────────────────────────────────────────────────────────────

  /// keiyoushi selector minus the `ul li:has(div.chbox):has(div.eph-num)`
  /// branch, which package:html cannot parse — see [parseChapters].
  String get chapterListSelector => 'div.bxcl li, div.cl li, #chapterlist li';

  @override
  Future<List<SChapter>> getChapterList(SManga manga) async {
    final res = await client.get<String>('$baseUrl${manga.url}');
    return parseChapters(res.data ?? '');
  }

  /// Parses the chapter list on a series page. Exposed for testing.
  List<SChapter> parseChapters(String htmlBody) {
    final doc = html_parser.parse(htmlBody);
    var items = doc.querySelectorAll(chapterListSelector);
    if (items.isEmpty) {
      // `ul li:has(div.chbox):has(div.eph-num)` fallback, done by hand.
      items = doc
          .querySelectorAll('ul li')
          .where((li) =>
              li.querySelector('div.chbox') != null &&
              li.querySelector('div.eph-num') != null)
          .toList();
    }
    return items.map(chapterFromElement).nonNulls.toList();
  }

  SChapter? chapterFromElement(Element el) {
    final a = _selfOrChild(el, 'a');
    final href = a?.attributes['href'];
    if (href == null) return null;
    var name = el.querySelector('.lch a, .chapternum')?.text.trim() ?? '';
    if (name.isEmpty) name = a!.text.trim();
    name = name.replaceAll(RegExp(r'\s+'), ' ');
    if (name.isEmpty) return null;
    return SChapter(
      url: _relative(href),
      name: name,
      dateUpload: parseChapterDate(chapterDateText(el)),
      chapterNumber: _chapterNumber(name),
    );
  }

  /// Where the chapter date lives; skin subclasses override.
  String? chapterDateText(Element el) =>
      el.querySelector('.chapterdate')?.text.trim();

  // ── Pages ──────────────────────────────────────────────────────────────────

  String get pageSelector => 'div#readerarea img';

  static final _imageListRegex =
      RegExp(r'"images"\s*:\s*(\[.*?\])', dotAll: true);

  @override
  Future<List<MangaPage>> getPageList(SChapter chapter) async {
    final res = await client.get<String>('$baseUrl${chapter.url}');
    return parsePages(res.data ?? '');
  }

  /// Parses reader pages: DOM images first, then the `ts_reader.run` script
  /// JSON (`"images": [...]`). Exposed for testing.
  List<MangaPage> parsePages(String htmlBody) {
    final doc = html_parser.parse(htmlBody);
    final urls = doc
        .querySelectorAll(pageSelector)
        .map(imgSrc)
        .nonNulls
        .where((u) => u.isNotEmpty)
        .toList();
    if (urls.isEmpty) {
      final json = _imageListRegex.firstMatch(htmlBody)?.group(1);
      if (json != null) {
        try {
          urls.addAll((jsonDecode(json) as List).whereType<String>());
        } on FormatException {
          // Malformed script blob — fall through to an empty list.
        }
      }
    }
    return List.generate(urls.length, (i) {
      return MangaPage(index: i, imageUrl: _absolute(urls[i]));
    });
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  Element? _selfOrChild(Element el, String tag) =>
      el.localName == tag ? el : el.querySelector(tag);

  String _relative(String url) =>
      url.startsWith(baseUrl) ? url.substring(baseUrl.length) : url;

  /// Some installs emit relative image paths (keiyoushi DespairManga override).
  String _absolute(String url) => url.startsWith('/') ? '$baseUrl$url' : url;

  String? imgSrc(Element? img) {
    if (img == null) return null;
    for (final attr in ['data-lazy-src', 'data-src', 'data-cfsrc', 'src']) {
      final v = img.attributes[attr]?.trim();
      if (v != null && v.isNotEmpty && !v.startsWith('data:')) {
        return v.split(' ').first;
      }
    }
    return null;
  }

  double _chapterNumber(String name) {
    final match = RegExp(r'(\d+(?:\.\d+)?)').firstMatch(name);
    return match == null ? -1 : (double.tryParse(match.group(1)!) ?? -1);
  }

  static const _months = {
    'january': 1, 'february': 2, 'march': 3, 'april': 4, 'may': 5,
    'june': 6, 'july': 7, 'august': 8, 'september': 9, 'october': 10,
    'november': 11, 'december': 12,
    'يناير': 1, 'فبراير': 2, 'مارس': 3, 'أبريل': 4, 'ابريل': 4, 'مايو': 5,
    'يونيو': 6, 'يوليو': 7, 'أغسطس': 8, 'اغسطس': 8, 'سبتمبر': 9,
    'أكتوبر': 10, 'اكتوبر': 10, 'نوفمبر': 11, 'ديسمبر': 12,
  };

  /// Sites emit "July 9, 2026", "9 يوليو، 2026" or numeric "2025/11/19"
  /// (kenmanga/lava skins). Exposed for testing.
  DateTime? parseChapterDate(String? text) {
    if (text == null || text.isEmpty) return null;
    final iso = DateTime.tryParse(text);
    if (iso != null) return iso;

    final ymd = RegExp(r'^(\d{4})/(\d{1,2})/(\d{1,2})$').firstMatch(text);
    if (ymd != null) {
      return DateTime(
        int.parse(ymd.group(1)!),
        int.parse(ymd.group(2)!),
        int.parse(ymd.group(3)!),
      );
    }

    final lower = text.toLowerCase();
    final numbers = RegExp(r'\d+')
        .allMatches(lower)
        .map((m) => int.parse(m.group(0)!))
        .toList();
    for (final entry in _months.entries) {
      if (!lower.contains(entry.key)) continue;
      final year = numbers.where((n) => n > 1900).firstOrNull;
      final day = numbers.where((n) => n <= 31).firstOrNull;
      if (year != null && day != null) {
        return DateTime(year, entry.value, day);
      }
    }
    return null;
  }
}
