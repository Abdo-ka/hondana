import 'package:html/dom.dart';
import 'package:html/parser.dart' as html_parser;

import 'package:mihonx/features/browse/data/source/http_source_base.dart';
import 'package:mihonx/features/browse/domain/source/model/filter.dart';
import 'package:mihonx/features/browse/domain/source/model/manga_page.dart';
import 'package:mihonx/features/browse/domain/source/model/manga_status.dart';
import 'package:mihonx/features/browse/domain/source/model/mangas_page.dart';
import 'package:mihonx/features/browse/domain/source/model/s_chapter.dart';
import 'package:mihonx/features/browse/domain/source/model/s_manga.dart';

/// Dart port of keiyoushi's `TeamX` (Team X / olympustaff.com, Arabic).
/// Custom PHP site: `/series?page=N` listings, `/ajax/search?keyword=` search,
/// chapter cards with unix `data-date` timestamps and a paginated chapter
/// list, reader images under `div.image_list`. Live-verified 2026-07.
class TeamXSource extends HttpSourceBase {
  @override
  int get id => 4110737012647435874;
  @override
  String get name => 'Team X';
  @override
  String get lang => 'ar';
  @override
  String get defaultBaseUrl => 'https://olympustaff.com';
  @override
  bool get supportsLatest => true;

  @override
  FilterList getFilterList() => [];

  @override
  Map<String, String> get imageHeaders => {'Referer': '$baseUrl/'};

  static const _nextPageSelector = 'a[rel=next]';
  static const _thumbnailSuffix = 'thumbnail_';

  // ── Popular ────────────────────────────────────────────────────────────────

  @override
  Future<MangasPage> getPopularManga(int page) async {
    final res = await client.get<String>(
      '$baseUrl/series/${page > 1 ? '?page=$page' : ''}',
    );
    return parseBrowse(res.data ?? '');
  }

  /// Parses a `/series` archive page. Exposed for testing.
  MangasPage parseBrowse(String htmlBody) {
    final doc = html_parser.parse(htmlBody);
    final mangas = doc.querySelectorAll('div.listupd div.bsx').map((el) {
      final a = el.querySelector('a');
      final href = a?.attributes['href'];
      if (href == null) return null;
      final title = a!.attributes['title']?.trim() ?? '';
      if (title.isEmpty) return null;
      return SManga(
        url: _relative(href),
        title: title,
        thumbnailUrl: _imgSrc(el.querySelector('img')),
      );
    }).nonNulls.toList();
    return MangasPage(
      mangas: mangas,
      hasNextPage: doc.querySelector(_nextPageSelector) != null,
    );
  }

  // ── Latest ─────────────────────────────────────────────────────────────────

  /// Homepage repeats a title per released chapter; keiyoushi dedupes across
  /// pages with a session-scoped set.
  final Set<String> _latestTitlesSeen = {};

  @override
  Future<MangasPage> getLatestUpdates(int page) async {
    if (page == 1) _latestTitlesSeen.clear();
    final res =
        await client.get<String>(page > 1 ? '$baseUrl/?page=$page' : baseUrl);
    return parseLatest(res.data ?? '', seenTitles: _latestTitlesSeen);
  }

  /// Parses the homepage latest-chapters grid. Exposed for testing.
  MangasPage parseLatest(String htmlBody, {Set<String>? seenTitles}) {
    final seen = seenTitles ?? <String>{};
    final doc = html_parser.parse(htmlBody);
    final mangas = <SManga>[];
    for (final el in doc.querySelectorAll('div.last-chapter div.box')) {
      final link = el.querySelector('div.info a');
      final href = link?.attributes['href'];
      final title = link?.querySelector('h3')?.text.trim() ?? '';
      if (href == null || title.isEmpty) continue;
      if (!seen.add(title)) continue;
      mangas.add(SManga(
        url: _relative(href),
        title: title,
        thumbnailUrl: _imgSrc(el.querySelector('div.imgu img'))
            ?.replaceFirst(_thumbnailSuffix, ''),
      ));
    }
    return MangasPage(
      mangas: mangas,
      hasNextPage: doc.querySelector(_nextPageSelector) != null,
    );
  }

  // ── Search ─────────────────────────────────────────────────────────────────

  @override
  Future<MangasPage> getSearchManga(int page, String query, FilterList _) async {
    if (query.trim().isEmpty) {
      final res = await client.get<String>(
        '$baseUrl/series',
        queryParameters: {'page': '$page'},
      );
      return parseBrowse(res.data ?? '');
    }
    final res = await client.get<String>(
      '$baseUrl/ajax/search',
      queryParameters: {'keyword': query},
    );
    return parseSearch(res.data ?? '');
  }

  /// Parses the `/ajax/search` HTML fragment. Exposed for testing.
  MangasPage parseSearch(String htmlBody) {
    final doc = html_parser.parse(htmlBody);
    final mangas =
        doc.querySelectorAll('a.items-center, div.listupd div.bsx').map((el) {
      final a = el.localName == 'a' ? el : el.querySelector('a');
      final href = a?.attributes['href'];
      if (href == null) return null;
      final title = el.querySelector('h4')?.text.trim() ??
          a!.attributes['title']?.trim() ??
          '';
      if (title.isEmpty) return null;
      return SManga(
        url: _relative(href),
        title: title,
        thumbnailUrl:
            _imgSrc(el.querySelector('img'))?.replaceFirst(_thumbnailSuffix, ''),
      );
    }).nonNulls.toList();
    return MangasPage(mangas: mangas);
  }

  // ── Details ────────────────────────────────────────────────────────────────

  @override
  Future<SManga> getMangaDetails(SManga manga) async {
    final res = await client.get<String>('$baseUrl${manga.url}');
    return parseDetails(res.data ?? '', manga);
  }

  /// Parses a series page. Exposed for testing.
  SManga parseDetails(String htmlBody, SManga base) {
    final doc = html_parser.parse(htmlBody);
    final title = doc.querySelector('div.author-info-title h1')?.text.trim();
    var description = doc.querySelector('div.review-content')?.text.trim();
    if (description == null || description.isEmpty) {
      description = doc
          .querySelectorAll('div.review-content p')
          .map((e) => e.text.trim())
          .join(' ');
    }
    final genres = doc
        .querySelectorAll('div.review-author-info a')
        .map((e) => e.text.trim())
        .where((t) => t.isNotEmpty)
        .toList();
    final author = _infoRow(doc, 'الرسام');
    return base.copyWith(
      title: (title == null || title.isEmpty) ? base.title : title,
      description: description,
      genre: genres,
      thumbnailUrl: _imgSrc(doc.querySelector('div.text-right img')) ??
          base.thumbnailUrl,
      status: _status(_infoRow(doc, 'الحالة')),
      author: author == 'غير معروف' ? null : author,
      initialized: true,
    );
  }

  /// `.full-list-info > small:first-child:contains(label) + small` by hand.
  String? _infoRow(Document doc, String label) {
    for (final row in doc.querySelectorAll('.full-list-info')) {
      final smalls = row.querySelectorAll('small');
      if (smalls.length < 2) continue;
      if (!smalls.first.text.contains(label)) continue;
      final value = smalls[1].text.trim();
      if (value.isNotEmpty) return value;
    }
    return null;
  }

  MangaStatus _status(String? s) => switch (s) {
        'مستمرة' || 'قادم قريبًا' => MangaStatus.ongoing,
        'مكتمل' => MangaStatus.completed,
        'متوقف' => MangaStatus.onHiatus,
        'متروك' => MangaStatus.cancelled,
        _ => MangaStatus.unknown,
      };

  // ── Chapters ───────────────────────────────────────────────────────────────

  @override
  Future<List<SChapter>> getChapterList(SManga manga) async {
    final url = '$baseUrl${manga.url}';
    final res = await client.get<String>(url);
    final body = res.data ?? '';
    final chapters = parseChapters(body);
    final lastPage = lastChapterPage(body);
    if (lastPage <= 1) return chapters;
    final rest = await Future.wait([
      for (var page = 2; page <= lastPage; page++)
        client
            .get<String>(url, queryParameters: {'page': '$page'})
            .then((r) => parseChapters(r.data ?? '')),
    ]);
    return [...chapters, ...rest.expand((c) => c)];
  }

  /// Highest page number in the chapter-list pagination. Exposed for testing.
  int lastChapterPage(String htmlBody) {
    final doc = html_parser.parse(htmlBody);
    return doc
        .querySelectorAll('ul.pagination a.page-link')
        .map((e) => int.tryParse(e.text.trim()))
        .nonNulls
        .fold(1, (max, n) => n > max ? n : max);
  }

  /// Parses the chapter cards on a series page (locked chapters are skipped).
  /// Exposed for testing.
  List<SChapter> parseChapters(String htmlBody) {
    final doc = html_parser.parse(htmlBody);
    return doc.querySelectorAll('div.chapter-card').map((el) {
      if (el.querySelector('span.locked') != null) return null;
      final href = el.querySelector('a')?.attributes['href'];
      if (href == null) return null;
      final number = el.attributes['data-number']?.trim() ?? '';
      final title =
          el.querySelector('div.chapter-info div.chapter-title')?.text.trim();
      var name = 'الفصل $number';
      if (title != null &&
          title.isNotEmpty &&
          title != number &&
          title != 'الفصل $number' &&
          title != 'الفصل رقم $number') {
        name = '$name - $title';
      }
      final seconds = int.tryParse(el.attributes['data-date'] ?? '');
      return SChapter(
        url: _relative(href),
        // Trailing RLM keeps mixed-direction titles rendering correctly.
        name: '$name\u200F',
        dateUpload: seconds == null
            ? null
            : DateTime.fromMillisecondsSinceEpoch(seconds * 1000),
        chapterNumber: double.tryParse(number) ?? -1,
      );
    }).nonNulls.toList();
  }

  // ── Pages ──────────────────────────────────────────────────────────────────

  @override
  Future<List<MangaPage>> getPageList(SChapter chapter) async {
    final res = await client.get<String>('$baseUrl${chapter.url}');
    return parsePages(res.data ?? '');
  }

  /// Parses reader images (plain `img` or lazy `canvas[data-src]`). Exposed
  /// for testing.
  List<MangaPage> parsePages(String htmlBody) {
    final doc = html_parser.parse(htmlBody);
    final urls = doc
        .querySelectorAll(
            'div.image_list canvas[data-src], div.image_list img[src]')
        .map((el) => el.attributes['src'] ?? el.attributes['data-src'])
        .nonNulls
        .map((u) => u.startsWith('/') ? '$baseUrl$u' : u)
        .where((u) => u.isNotEmpty)
        .toList();
    return List.generate(urls.length, (i) {
      return MangaPage(index: i, imageUrl: urls[i]);
    });
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  String _relative(String url) =>
      url.startsWith(baseUrl) ? url.substring(baseUrl.length) : url;

  String? _imgSrc(Element? img) {
    if (img == null) return null;
    for (final attr in ['data-src', 'src']) {
      final v = img.attributes[attr]?.trim();
      if (v != null && v.isNotEmpty && !v.startsWith('data:')) return v;
    }
    return null;
  }
}
