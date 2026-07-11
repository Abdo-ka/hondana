import 'dart:convert';

import 'package:html/dom.dart';
import 'package:html/parser.dart' as html_parser;

import 'package:hondana/features/browse/data/source/http_source_base.dart';
import 'package:hondana/features/browse/domain/source/model/filter.dart';
import 'package:hondana/features/browse/domain/source/model/manga_page.dart';
import 'package:hondana/features/browse/domain/source/model/manga_status.dart';
import 'package:hondana/features/browse/domain/source/model/mangas_page.dart';
import 'package:hondana/features/browse/domain/source/model/s_chapter.dart';
import 'package:hondana/features/browse/domain/source/model/s_manga.dart';

/// Dart port of keiyoushi's `ZeistManga` multisrc theme — Blogger/Blogspot
/// manga blogs driven by the Blogger JSON feed API
/// (`{base}/feeds/posts/default/-/{label}?alt=json`). Series and chapters are
/// both feed posts distinguished by labels ([mangaCategory] /
/// [chapterCategory]); details and reader pages are scraped from post HTML.
abstract class ZeistSource extends HttpSourceBase {
  static const int maxMangaResults = 20;
  static const int maxChapterResults = 150;

  @override
  bool get supportsLatest => true;

  @override
  FilterList getFilterList() => [];

  @override
  Map<String, String> get imageHeaders => {'Referer': '$baseUrl/'};

  /// Blogger label marking series posts.
  String get mangaCategory => 'Series';

  /// Blogger label marking chapter posts.
  String get chapterCategory => 'Chapter';

  /// Blogger labels to drop from series listings (e.g. anime cross-posts).
  List<String> get excludedCategories => const ['Anime'];

  /// Sites without a homepage "popular" widget list latest instead
  /// (keiyoushi Murim / XSanoManga overrides).
  bool get useLatestForPopular => false;

  /// keiyoushi `preferChapterUpdatedDate` (Yokai).
  bool get preferChapterUpdatedDate => false;

  String _feedUrl(String label) =>
      '$baseUrl/feeds/posts/default/-/${Uri.encodeComponent(label)}';

  // ── Popular (homepage widget) ─────────────────────────────────────────────

  /// Homepage popular-widget item selector.
  String get popularMangaSelector => 'div.PopularPosts div.grid > figure';

  /// Title anchor within a [popularMangaSelector] item.
  String get popularMangaSelectorTitle => 'figcaption > a';

  @override
  Future<MangasPage> getPopularManga(int page) async {
    if (useLatestForPopular) return getLatestUpdates(page);
    final res = await client.get<String>(baseUrl);
    return parsePopularPage(res.data ?? '');
  }

  /// Parses the homepage popular widget. Exposed for testing.
  MangasPage parsePopularPage(String htmlBody) {
    final doc = html_parser.parse(htmlBody);
    final mangas = doc
        .querySelectorAll(popularMangaSelector)
        .map((el) {
          final a = el.querySelector(popularMangaSelectorTitle);
          final href = a?.attributes['href'];
          final title = a?.text.trim() ?? '';
          if (href == null || title.isEmpty) return null;
          return SManga(
            url: _relative(href),
            title: title,
            thumbnailUrl: el.querySelector('img')?.attributes['src'],
          );
        })
        .nonNulls
        .toList();
    return MangasPage(mangas: mangas);
  }

  // ── Latest + search (Blogger feed) ────────────────────────────────────────

  @override
  Future<MangasPage> getLatestUpdates(int page) async {
    final startIndex = maxMangaResults * (page - 1) + 1;
    final res = await client.get<String>(
      _feedUrl(mangaCategory),
      queryParameters: {
        'alt': 'json',
        'orderby': 'published',
        'max-results': '${maxMangaResults + 1}',
        'start-index': '$startIndex',
      },
    );
    return parseMangaFeed(res.data ?? '');
  }

  @override
  Future<MangasPage> getSearchManga(
    int page,
    String query,
    FilterList _,
  ) async {
    if (query.trim().isEmpty) return getLatestUpdates(page);
    final startIndex = maxMangaResults * (page - 1) + 1;
    // Blogger full-text search restricted to the series label:
    // `q=label:Series+<query>` — built by hand because the `+` is literal.
    final url =
        '${_feedUrl(mangaCategory)}?alt=json'
        '&max-results=${maxMangaResults + 1}&start-index=$startIndex'
        '&q=label:${Uri.encodeQueryComponent(mangaCategory)}'
        '+${Uri.encodeQueryComponent(query)}';
    final res = await client.get<String>(url);
    return parseMangaFeed(res.data ?? '');
  }

  /// Parses a Blogger series feed into a catalogue page. Exposed for testing.
  MangasPage parseMangaFeed(String jsonBody) {
    final mangas = _feedEntries(jsonBody)
        .where((e) {
          final categories = _entryCategories(e);
          return categories.contains(mangaCategory) &&
              !categories.any(excludedCategories.contains);
        })
        .map(_entryToManga)
        .nonNulls
        .toList();
    if (mangas.length == maxMangaResults + 1) {
      return MangasPage(
        mangas: mangas.sublist(0, mangas.length - 1),
        hasNextPage: true,
      );
    }
    return MangasPage(mangas: mangas);
  }

  SManga? _entryToManga(Map<String, dynamic> entry) {
    final title = _blogText(entry['title']);
    final href = _alternateLink(entry);
    if (title == null || title.isEmpty || href == null) return null;
    return SManga(
      url: _relative(href),
      title: title,
      thumbnailUrl: _entryThumbnail(entry),
    );
  }

  String? _entryThumbnail(Map<String, dynamic> entry) {
    final media = entry[r'media$thumbnail'];
    if (media is Map && media['url'] is String) {
      return upscaleThumbnail(media['url'] as String);
    }
    final content = _blogText(entry['content']);
    if (content == null) return null;
    return html_parser.parse(content).querySelector('img')?.attributes['src'];
  }

  /// Blogger serves 72x72 (`/s72-c/`, `=s72-c`) thumbs; request 600px wide.
  String upscaleThumbnail(String url) => url
      .replaceFirst(RegExp(r'/s.+?-c/'), '/w600/')
      .replaceFirst(RegExp(r'=s(?!.*=s).+?-c$'), '=w600');

  // ── Details ────────────────────────────────────────────────────────────────

  /// Root of the series-detail profile block; skins override this and the
  /// selectors below to match their markup.
  String get mangaDetailsSelector => '.grid.gtc-235fr';
  String get mangaDetailsSelectorDescription => '#synopsis';
  String get mangaDetailsSelectorGenres => 'div.mt-15 > a[rel=tag]';
  String get mangaDetailsSelectorAuthor => 'span#author';
  String get mangaDetailsSelectorArtist => 'span#artist';
  String get mangaDetailsSelectorStatus => 'span[data-status]';

  /// Container of the label/value info rows scanned via [statusKeywords] etc.
  String get mangaDetailsSelectorInfo => '.y6x11p';
  String get mangaDetailsSelectorInfoTitle => 'strong';
  String get mangaDetailsSelectorInfoDescription => 'span.dt';

  /// Info-row labels identifying the status / author / artist values.
  List<String> get statusKeywords => const ['Status', 'الحالة'];
  List<String> get authorKeywords => const ['Author', 'الكاتب', 'المؤلف'];
  List<String> get artistKeywords => const ['Artist', 'الرسام'];

  @override
  Future<SManga> getMangaDetails(SManga manga) async {
    final res = await client.get<String>('$baseUrl${manga.url}');
    return parseDetails(res.data ?? '', manga);
  }

  /// Parses a series post page. Exposed for testing.
  SManga parseDetails(String htmlBody, SManga base) {
    final doc = html_parser.parse(htmlBody);
    final profile = doc.querySelector(mangaDetailsSelector);
    if (profile == null) return base;

    var author = profile.querySelector(mangaDetailsSelectorAuthor)?.text.trim();
    var artist = profile.querySelector(mangaDetailsSelectorArtist)?.text.trim();
    var status = parseStatus(
      profile.querySelector(mangaDetailsSelectorStatus)?.text,
    );

    for (final info in profile.querySelectorAll(mangaDetailsSelectorInfo)) {
      var label = _ownText(info);
      if (label.isEmpty) {
        label =
            info.querySelector(mangaDetailsSelectorInfoTitle)?.text.trim() ??
            '';
      }
      final value =
          info
              .querySelector(mangaDetailsSelectorInfoDescription)
              ?.text
              .trim() ??
          '';
      if (value.isEmpty) continue;
      if (statusKeywords.any(label.contains)) {
        status = parseStatus(value);
      } else if (authorKeywords.any(label.contains)) {
        author = value;
      } else if (artistKeywords.any(label.contains)) {
        artist = value;
      }
    }

    final description = profile
        .querySelector(mangaDetailsSelectorDescription)
        ?.text
        .trim();
    final genres = profile
        .querySelectorAll(mangaDetailsSelectorGenres)
        .map((e) => e.text.trim())
        .where((t) => t.isNotEmpty)
        .toList();
    return base.copyWith(
      author: author,
      artist: artist,
      status: status,
      description: description,
      genre: genres,
      thumbnailUrl:
          profile.querySelector('img')?.attributes['src'] ?? base.thumbnailUrl,
      initialized: true,
    );
  }

  /// keiyoushi status lists (exact match on the lowercased trimmed value).
  MangaStatus parseStatus(String? raw) {
    final value = (raw ?? '').toLowerCase().trim();
    if (const ['ongoing', 'مستمر', 'مستمرة'].contains(value)) {
      return MangaStatus.ongoing;
    }
    if (const ['completed', 'مكتمل', 'مكتملة'].contains(value)) {
      return MangaStatus.completed;
    }
    if (const ['hiatus', 'متوقف'].contains(value)) return MangaStatus.onHiatus;
    if (const ['cancelled', 'dropped'].contains(value)) {
      return MangaStatus.cancelled;
    }
    return MangaStatus.unknown;
  }

  // ── Chapters ───────────────────────────────────────────────────────────────

  static final _clwdRegex = RegExp(r'''clwd\.run\(["'](.*?)["']\)''');
  static final _newFeedRegex = RegExp(r"label\s*=\s*'([^']+)'");

  @override
  Future<List<SChapter>> getChapterList(SManga manga) async {
    final res = await client.get<String>('$baseUrl${manga.url}');
    final htmlBody = res.data ?? '';
    final feedUrl = getChapterFeedUrl(htmlBody);

    final entries = <Map<String, dynamic>>[];
    final probe = await _fetchChapterFeed(feedUrl, 1, 0);
    final total =
        int.tryParse(
          _blogText(probe[r'openSearch$totalResults']) ??
              _blogText(
                (probe['feed']
                    as Map<String, dynamic>?)?[r'openSearch$totalResults'],
              ) ??
              '',
        ) ??
        maxChapterResults;

    var startIndex = 1;
    while (entries.length < total) {
      final result = await _fetchChapterFeed(
        feedUrl,
        startIndex,
        maxChapterResults,
      );
      final page =
          ((result['feed'] as Map<String, dynamic>?)?['entry'] as List?)
              ?.cast<Map<String, dynamic>>() ??
          const [];
      if (page.isEmpty) break;
      entries.addAll(page);
      startIndex += page.length;
    }

    final chapters = parseChapterEntries(entries);
    return postProcessChapters(htmlBody, chapters);
  }

  Future<Map<String, dynamic>> _fetchChapterFeed(
    String feedUrl,
    int startIndex,
    int maxResults,
  ) async {
    final uri = Uri.parse(feedUrl);
    final url = uri.replace(
      queryParameters: {
        ...uri.queryParameters,
        'start-index': '$startIndex',
        'max-results': '$maxResults',
      },
    );
    final res = await client.get<String>(url.toString());
    return jsonDecode(res.data ?? '{}') as Map<String, dynamic>;
  }

  /// Locates the chapter feed for a series page, mirroring keiyoushi's three
  /// theme generations. Exposed for testing (returns an absolute URL).
  String getChapterFeedUrl(String htmlBody) {
    final doc = html_parser.parse(htmlBody);

    // Current theme: `<div id="clwd"><script>clwd.run('Label')</script>`.
    final clwd = doc.querySelector('#clwd > script');
    if (clwd != null) {
      final label = _clwdRegex.firstMatch(clwd.text)?.group(1);
      if (label == null) throw StateError('Failed to find chapter feed');
      return '${_feedUrl(chapterCategory)}/${Uri.encodeComponent(label)}'
          '?alt=json';
    }

    // Old theme: `<ul id="myUL"><script src="/feeds/posts/default/-/X?...">`.
    final old = doc.querySelector('#myUL > script')?.attributes['src'];
    if (old != null && old.isNotEmpty) {
      return '$baseUrl${old.split('?').first}?alt=json';
    }

    // New theme: `<div id="latest"><script>... label = 'X' ...</script>`.
    final latest = doc.querySelector('#latest > script');
    if (latest != null) {
      final label = _newFeedRegex.firstMatch(latest.text)?.group(1);
      if (label != null) {
        return '$baseUrl/feeds/posts/default/-/${Uri.encodeComponent(label)}'
            '?alt=json';
      }
    }
    throw StateError('Failed to find chapter feed');
  }

  /// Maps chapter feed entries to chapters. Exposed for testing via
  /// [parseChapterFeed].
  List<SChapter> parseChapterEntries(List<Map<String, dynamic>> entries) {
    return entries
        .where((e) {
          return _entryCategories(e).contains(chapterCategory);
        })
        .map((e) {
          final name = _blogText(e['title']) ?? '';
          final href = _alternateLink(e);
          if (name.isEmpty || href == null) return null;
          final published = _blogText(e['published'])?.trim();
          final updated = _blogText(e['updated'])?.trim();
          final dateText = preferChapterUpdatedDate
              ? (updated ?? published)
              : (published ?? updated);
          return SChapter(
            url: _relative(href),
            name: name,
            dateUpload: dateText == null ? null : DateTime.tryParse(dateText),
            chapterNumber: _chapterNumber(name),
          );
        })
        .nonNulls
        .toList();
  }

  /// Parses a raw chapter feed JSON document. Exposed for testing.
  List<SChapter> parseChapterFeed(String jsonBody) =>
      parseChapterEntries(_feedEntries(jsonBody));

  /// Hook for sites that rewrite names or append extra chapters scraped from
  /// the series page (keiyoushi Yokai).
  List<SChapter> postProcessChapters(
    String htmlBody,
    List<SChapter> chapters,
  ) => chapters;

  // ── Pages ──────────────────────────────────────────────────────────────────

  /// Reader-image container selector; skins override.
  String get pageListSelector => 'div.check-box div.separator';

  @override
  Future<List<MangaPage>> getPageList(SChapter chapter) async {
    final res = await client.get<String>('$baseUrl${chapter.url}');
    return parsePages(res.data ?? '');
  }

  /// Parses reader images from a chapter post. Exposed for testing.
  List<MangaPage> parsePages(String htmlBody) {
    final doc = html_parser.parse(htmlBody);
    final urls = <String>[];
    for (final separator in doc.querySelectorAll(pageListSelector)) {
      for (final img in separator.querySelectorAll('img[src]')) {
        final src = img.attributes['src']?.trim();
        if (src != null && src.isNotEmpty) urls.add(src);
      }
    }
    return List.generate(urls.length, (i) {
      return MangaPage(index: i, imageUrl: urls[i]);
    });
  }

  // ── Feed helpers ───────────────────────────────────────────────────────────

  List<Map<String, dynamic>> _feedEntries(String jsonBody) {
    final root = jsonDecode(jsonBody) as Map<String, dynamic>;
    final feed = root['feed'] as Map<String, dynamic>?;
    return (feed?['entry'] as List?)?.cast<Map<String, dynamic>>() ?? const [];
  }

  List<String> _entryCategories(Map<String, dynamic> entry) =>
      (entry['category'] as List?)
          ?.map((c) => (c as Map)['term'] as String? ?? '')
          .toList() ??
      const [];

  String? _alternateLink(Map<String, dynamic> entry) {
    final links = (entry['link'] as List?)?.cast<Map>() ?? const [];
    for (final link in links) {
      if (link['rel'] == 'alternate') return link['href'] as String?;
    }
    return null;
  }

  /// Blogger wraps scalars as `{"$t": "value"}`.
  String? _blogText(Object? node) =>
      node is Map ? node[r'$t'] as String? : null;

  String _ownText(Element el) => el.nodes
      .where((n) => n.nodeType == Node.TEXT_NODE)
      .map((n) => n.text ?? '')
      .join()
      .trim();

  String _relative(String url) =>
      url.startsWith(baseUrl) ? url.substring(baseUrl.length) : url;

  double _chapterNumber(String name) {
    final match = RegExp(r'(\d+(?:\.\d+)?)').firstMatch(name);
    return match == null ? -1 : (double.tryParse(match.group(1)!) ?? -1);
  }
}
