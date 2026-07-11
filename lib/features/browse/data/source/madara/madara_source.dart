import 'package:dio/dio.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart' as html_parser;

import 'package:hondana/features/browse/data/source/http_source_base.dart';
import 'package:hondana/features/browse/domain/source/model/filter.dart';
import 'package:hondana/features/browse/domain/source/model/manga_page.dart';
import 'package:hondana/features/browse/domain/source/model/manga_status.dart';
import 'package:hondana/features/browse/domain/source/model/mangas_page.dart';
import 'package:hondana/features/browse/domain/source/model/s_chapter.dart';
import 'package:hondana/features/browse/domain/source/model/s_manga.dart';

/// Dart port of keiyoushi's `Madara` multisrc theme — the WordPress "Madara"
/// manga theme that powers a large share of English + Arabic scanlation sites.
/// A concrete source is just a subclass supplying `id`, `name`, `lang`,
/// `baseUrl` (+ optional selector overrides).
///
/// Listings default to the page-based GET endpoints
/// (`/manga/page/N/?m_orderby=…`) like current keiyoushi; sites whose archive
/// only paginates through the `madara_load_more` admin-ajax action set
/// [useLoadMoreRequest] (keiyoushi's `LoadMoreStrategy.Always`).
abstract class MadaraSource extends HttpSourceBase {
  /// Path segment for the manga archive (some sites use `manga`, others differ).
  String get mangaSubString => 'manga';

  /// True for sites where archive pages 403/404 and only the
  /// `madara_load_more` admin-ajax endpoint serves listings.
  bool get useLoadMoreRequest => false;

  @override
  bool get supportsLatest => true;

  @override
  FilterList getFilterList() => [];

  @override
  Map<String, String> get imageHeaders => {'Referer': '$baseUrl/'};

  static const _ajaxHeaders = {'X-Requested-With': 'XMLHttpRequest'};

  // ── Catalogue ──────────────────────────────────────────────────────────────

  Future<MangasPage> _listing(
    int page, {
    required String orderby,
    String? metaKey,
    String? search,
  }) async {
    if (useLoadMoreRequest) {
      return _loadMore(
        page,
        orderby: orderby,
        metaKey: metaKey,
        search: search,
      );
    }
    final pagePath = page > 1 ? 'page/$page/' : '';
    final res = search == null
        ? await client.get<String>(
            '$baseUrl/$mangaSubString/$pagePath?m_orderby=$orderby',
          )
        : await client.get<String>(
            '$baseUrl/$pagePath',
            queryParameters: {'s': search, 'post_type': 'wp-manga'},
          );
    return _parseListing(res.data ?? '');
  }

  Future<MangasPage> _loadMore(
    int page, {
    required String orderby,
    String? metaKey,
    String? search,
  }) async {
    final form = <String, String>{
      'action': 'madara_load_more',
      'page': '${page - 1}',
      'template': search == null
          ? 'madara-core/content/content-archive'
          : 'madara-core/content/content-search',
      'vars[paged]': '1',
      'vars[posts_per_page]': '20',
      'vars[post_type]': 'wp-manga',
      'vars[order]': 'desc',
      'vars[sidebar]': 'right',
      'vars[manga_archives_item_layout]': 'big_thumbnail',
      if (search == null) 'vars[orderby]': 'meta_value_num',
      if (search == null && metaKey != null) 'vars[meta_key]': metaKey,
      'vars[s]': ?search,
    };
    final res = await client.post<String>(
      '$baseUrl/wp-admin/admin-ajax.php',
      data: form,
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
        headers: _ajaxHeaders,
      ),
    );
    final mangas = _parseListing(res.data ?? '').mangas;
    return MangasPage(mangas: mangas, hasNextPage: mangas.isNotEmpty);
  }

  @override
  Future<MangasPage> getPopularManga(int page) =>
      _listing(page, orderby: 'views', metaKey: '_wp_manga_views');

  @override
  Future<MangasPage> getLatestUpdates(int page) =>
      _listing(page, orderby: 'latest', metaKey: '_latest_update');

  @override
  Future<MangasPage> getSearchManga(int page, String query, FilterList _) =>
      _listing(page, orderby: '', search: query);

  MangasPage _parseListing(String htmlBody) {
    final doc = html_parser.parse(htmlBody);
    final mangas = doc
        .querySelectorAll(
          'div.page-item-detail, div.c-tabs-item__content, div.manga',
        )
        .map(_parseListItem)
        .nonNulls
        .toList();
    final hasNext =
        doc.querySelector(
          'div.nav-previous a, a.nextpostslink, .nav-links a.next, '
          'link[rel=next], div.wp-pagenavi a.nextpostslink',
        ) !=
        null;
    return MangasPage(mangas: mangas, hasNextPage: hasNext);
  }

  /// Parses a Madara listing HTML fragment into manga. Exposed for testing.
  List<SManga> parsePopular(String htmlBody) => _parseListing(htmlBody).mangas;

  SManga? _parseListItem(Element el) {
    final a = el.querySelector('.post-title a') ?? el.querySelector('a');
    final href = a?.attributes['href'];
    final title = a?.text.trim() ?? '';
    if (href == null || title.isEmpty) return null;
    return SManga(
      url: _relative(href),
      title: title,
      thumbnailUrl: _imgSrc(el.querySelector('img')),
    );
  }

  // ── Details ──────────────────────────────────────────────────────────────

  @override
  Future<SManga> getMangaDetails(SManga manga) async {
    final res = await client.get<String>('$baseUrl${manga.url}');
    return parseDetails(res.data ?? '', manga);
  }

  /// Parses a manga detail page. Exposed for testing.
  SManga parseDetails(String htmlBody, SManga base) {
    final doc = html_parser.parse(htmlBody);
    final title = doc.querySelector('.post-title h1')?.text.trim();
    final author = doc.querySelector('.author-content a')?.text.trim();
    final artist = doc.querySelector('.artist-content a')?.text.trim();
    final description =
        doc
            .querySelector('.description-summary .summary__content')
            ?.text
            .trim() ??
        doc.querySelector('div.summary__content')?.text.trim();
    final statusText = doc
        .querySelectorAll('.post-content_item')
        .where((e) {
          final heading = (e.querySelector('.summary-heading')?.text ?? '')
              .toLowerCase();
          return heading.contains('status') || heading.contains('الحالة');
        })
        .map((e) => e.querySelector('.summary-content')?.text.trim() ?? '')
        .firstOrNull;
    final genres = doc
        .querySelectorAll('.genres-content a')
        .map((e) => e.text.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    return base.copyWith(
      title: title ?? base.title,
      author: author,
      artist: artist,
      description: description,
      genre: genres,
      status: _status(statusText),
      thumbnailUrl:
          _imgSrc(doc.querySelector('.summary_image img')) ?? base.thumbnailUrl,
      initialized: true,
    );
  }

  @override
  Future<List<SChapter>> getChapterList(SManga manga) async {
    final mangaUrl = manga.url.endsWith('/') ? manga.url : '${manga.url}/';
    // Tier 1: the current per-manga ajax endpoint.
    try {
      final res = await client.post<String>(
        '$baseUrl${mangaUrl}ajax/chapters/',
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          headers: _ajaxHeaders,
        ),
      );
      final chapters = parseChapters(res.data ?? '');
      if (chapters.isNotEmpty) return chapters;
    } on DioException {
      // Fall through to the manga page.
    }
    // Tier 2: chapters embedded in the manga page (old installs).
    final res = await client.get<String>('$baseUrl${manga.url}');
    final body = res.data ?? '';
    final chapters = parseChapters(body);
    if (chapters.isNotEmpty) return chapters;
    // Tier 3: legacy admin-ajax endpoint, post id scraped from the page.
    final postId = html_parser
        .parse(body)
        .querySelector('#manga-chapters-holder')
        ?.attributes['data-id'];
    if (postId == null) return const [];
    final legacy = await client.post<String>(
      '$baseUrl/wp-admin/admin-ajax.php',
      data: {'action': 'manga_get_chapters', 'manga': postId},
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
        headers: _ajaxHeaders,
      ),
    );
    return parseChapters(legacy.data ?? '');
  }

  /// Parses a chapter list HTML fragment. Exposed for testing.
  List<SChapter> parseChapters(String htmlBody) {
    final doc = html_parser.parse(htmlBody);
    return doc
        .querySelectorAll('li.wp-manga-chapter')
        .map((li) {
          final a = li.querySelector('a');
          final href = a?.attributes['href'] ?? '';
          final name = a?.text.trim() ?? '';
          final date = li.querySelector('.chapter-release-date')?.text.trim();
          return SChapter(
            url: _relative(href),
            name: name,
            dateUpload: parseChapterDate(date),
            chapterNumber: _chapterNumber(name),
          );
        })
        .where((c) => c.url.isNotEmpty)
        .toList();
  }

  @override
  Future<List<MangaPage>> getPageList(SChapter chapter) async {
    final res = await client.get<String>('$baseUrl${chapter.url}');
    final doc = html_parser.parse(res.data ?? '');
    final imgs = doc.querySelectorAll('.reading-content img, .page-break img');
    return List.generate(imgs.length, (i) {
      return MangaPage(index: i, imageUrl: _imgSrc(imgs[i]));
    });
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  String _relative(String url) =>
      url.startsWith(baseUrl) ? url.substring(baseUrl.length) : url;

  String? _imgSrc(Element? img) {
    if (img == null) return null;
    for (final attr in ['data-src', 'data-lazy-src', 'srcset', 'src']) {
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
    'january': 1,
    'february': 2,
    'march': 3,
    'april': 4,
    'may': 5,
    'june': 6,
    'july': 7,
    'august': 8,
    'september': 9,
    'october': 10,
    'november': 11,
    'december': 12,
    'يناير': 1,
    'فبراير': 2,
    'مارس': 3,
    'أبريل': 4,
    'ابريل': 4,
    'مايو': 5,
    'يونيو': 6,
    'يوليو': 7,
    'أغسطس': 8,
    'اغسطس': 8,
    'سبتمبر': 9,
    'أكتوبر': 10,
    'اكتوبر': 10,
    'نوفمبر': 11,
    'ديسمبر': 12,
  };

  /// Madara emits locale strings ("July 9, 2026", "9 يوليو، 2026") or
  /// relatives ("2 days ago", "منذ يومين"). Exposed for testing.
  DateTime? parseChapterDate(String? text) {
    if (text == null || text.isEmpty) return null;
    final iso = DateTime.tryParse(text);
    if (iso != null) return iso;

    final lower = text.toLowerCase();
    // Relative dates — a day-resolution approximation is enough for sorting.
    if (lower.contains('ago') || lower.contains('منذ')) {
      final n =
          int.tryParse(RegExp(r'(\d+)').firstMatch(lower)?.group(1) ?? '') ?? 1;
      final now = DateTime.now();
      if (lower.contains('min') || lower.contains('دقيق')) {
        return now.subtract(Duration(minutes: n));
      }
      if (lower.contains('hour') || lower.contains('ساع')) {
        return now.subtract(Duration(hours: n));
      }
      if (lower.contains('week') ||
          lower.contains('أسبوع') ||
          lower.contains('اسبوع')) {
        return now.subtract(Duration(days: 7 * n));
      }
      if (lower.contains('month') || lower.contains('شهر')) {
        return now.subtract(Duration(days: 30 * n));
      }
      if (lower.contains('year') ||
          lower.contains('سنة') ||
          lower.contains('عام')) {
        return now.subtract(Duration(days: 365 * n));
      }
      return now.subtract(Duration(days: n));
    }

    // "July 9, 2026" / "9 يوليو، 2026" / "9 July 2026".
    final numbers = RegExp(
      r'\d+',
    ).allMatches(lower).map((m) => int.parse(m.group(0)!)).toList();
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

  MangaStatus _status(String? s) {
    final t = (s ?? '').toLowerCase();
    if (t.contains('complet') || t.contains('مكتمل')) {
      return MangaStatus.completed;
    }
    if (t.contains('ongoing') || t.contains('مستمر')) {
      return MangaStatus.ongoing;
    }
    if (t.contains('hiatus') || t.contains('متوقف')) {
      return MangaStatus.onHiatus;
    }
    if (t.contains('cancel') || t.contains('ملغي')) {
      return MangaStatus.cancelled;
    }
    return MangaStatus.unknown;
  }
}
