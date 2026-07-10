import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart' as html_parser;

import 'package:mihonx/features/browse/data/source/themesia/themesia_source.dart';
import 'package:mihonx/features/browse/domain/source/model/manga_page.dart';
import 'package:mihonx/features/browse/domain/source/model/s_chapter.dart';

/// Concrete MangaThemesia sites, ported from keiyoushi `src/ar/*` overrides.
/// Source ids are the keiyoushi index ids so the extensions catalog marks
/// these as installed and future Mihon migrations line up.
class _ThemesiaSite extends ThemesiaSource {
  _ThemesiaSite({
    required this.id,
    required this.name,
    required this.lang,
    required this.defaultBaseUrl,
  });

  @override
  final int id;
  @override
  final String name;
  @override
  final String lang;
  @override
  final String defaultBaseUrl;
}

/// Despair Manga — stock MangaThemesia markup. Public so fixture tests can
/// exercise the default engine selectors (live-verified 2026-07).
class DespairMangaSource extends ThemesiaSource {
  @override
  int get id => 886527590434722171;
  @override
  String get name => 'Despair Manga';
  @override
  String get lang => 'ar';
  @override
  String get defaultBaseUrl => 'https://despair-manga.net';
}

/// أريا مانجا (keiyoushi `AreaManga`) — custom "manga-card" skin plus a
/// `get_secure_chapter_images` admin-ajax endpoint for reader pages.
class AriaMangaSource extends ThemesiaSource {
  @override
  int get id => 8112280317896333809;
  @override
  String get name => 'أريا مانجا';
  @override
  String get lang => 'ar';
  @override
  String get defaultBaseUrl => 'https://ar.kenmanga.com';

  @override
  String get searchMangaSelector => '.listupd .manga-card-v';

  @override
  String listItemTitle(Element el, Element a) {
    final title = el.querySelector('.bigor .tt, h3 a')?.text.trim();
    if (title != null && title.isNotEmpty) return title;
    return super.listItemTitle(el, a);
  }

  @override
  String get seriesDetailsSelector => 'div.legendary-single-page';
  @override
  String get seriesTitleSelector => '.manga-title-large';
  @override
  String get seriesThumbnailSelector => '.manga-poster img';
  @override
  String get seriesDescriptionSelector => 'div.story-text';
  @override
  String get seriesGenreSelector => 'div.filter-tags a';

  @override
  String? infoValue(Element root, List<String> keys) {
    // Skin renders `.info-label` + value span rows instead of `.imptdt`.
    for (final label in root.querySelectorAll('.info-label')) {
      final text = label.text.toLowerCase();
      if (!keys.any((k) => text.contains(k.toLowerCase()))) continue;
      final value = label.nextElementSibling?.text.trim();
      if (value != null && value.isNotEmpty) return value;
    }
    return super.infoValue(root, keys);
  }

  @override
  String get chapterListSelector => '#chapters-list-container .ch-item';

  @override
  SChapter? chapterFromElement(Element el) {
    final chapter = super.chapterFromElement(el);
    if (chapter == null) return null;
    final name = el.querySelector('.chap-num')?.text.trim();
    if (name == null || name.isEmpty) return chapter;
    return SChapter(
      url: chapter.url,
      name: name.replaceAll(RegExp(r'\s+'), ' '),
      dateUpload: chapter.dateUpload,
      chapterNumber: chapter.chapterNumber,
    );
  }

  @override
  String? chapterDateText(Element el) =>
      el.querySelector('.chap-date')?.text.trim();

  @override
  Future<List<MangaPage>> getPageList(SChapter chapter) async {
    final pageRes = await client.get<String>('$baseUrl${chapter.url}');
    final chapterId = html_parser
        .parse(pageRes.data ?? '')
        .querySelector('#comment_post_ID')
        ?.attributes['value'];
    if (chapterId == null || chapterId.isEmpty) {
      throw StateError('Chapter ID not found.');
    }
    final res = await client.post<String>(
      '$baseUrl/wp-admin/admin-ajax.php',
      data: {'action': 'get_secure_chapter_images', 'chapter_id': chapterId},
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
        headers: {'Referer': '$baseUrl${chapter.url}'},
      ),
    );
    return parseSecurePages(res.data ?? '');
  }

  /// Parses the `get_secure_chapter_images` JSON response. Exposed for testing.
  List<MangaPage> parseSecurePages(String jsonBody) {
    final map = jsonDecode(jsonBody) as Map<String, dynamic>;
    if (map['success'] != true) throw StateError('Failed to load chapter.');
    final data = map['data'] as Map<String, dynamic>? ?? const {};
    final status = data['status'] as String?;
    if (status == 'locked') {
      throw StateError('Chapter locked. Open in WebView to unlock.');
    }
    if (status != 'unlocked') return const [];
    final content = data['content'] as String? ?? '';
    final imgs = html_parser.parse(content).querySelectorAll('img');
    final urls =
        imgs.map(imgSrc).nonNulls.where((u) => u.isNotEmpty).toList();
    return List.generate(urls.length, (i) {
      return MangaPage(index: i, imageUrl: urls[i]);
    });
  }
}

/// Lava Scans (keiyoushi `LavaScans`) — "lux" skin. keiyoushi builds it on
/// MangaThemesiaAlt (rotating random slug prefixes); the slug-map machinery is
/// not ported, so stored manga URLs may break if the site rotates slugs.
class LavaScansSource extends ThemesiaSource {
  @override
  int get id => 3209001028102012989;
  @override
  String get name => 'Lava Scans';
  @override
  String get lang => 'ar';
  @override
  String get defaultBaseUrl => 'https://lavascans.com';

  @override
  String get searchMangaSelector => '.listupd .manga-card-v';

  @override
  String listItemTitle(Element el, Element a) {
    final title = el.querySelector('.bigor .tt, h3 a')?.text.trim();
    if (title != null && title.isNotEmpty) return title;
    return super.listItemTitle(el, a);
  }

  @override
  String get seriesDetailsSelector => 'div.lh-container';
  @override
  String get seriesTitleSelector => '.lh-title';
  @override
  String get seriesDescriptionSelector => '#manga-story';
  @override
  String get seriesGenreSelector => '.lh-genres a';
  @override
  String get seriesThumbnailSelector => '.lh-poster img';

  @override
  String? infoValue(Element root, List<String> keys) {
    // Status renders as a badge; author/artist fall back to the base rows.
    if (keys.contains('الحالة')) {
      final badge = root.querySelector('.status-badge-lux')?.text.trim();
      if (badge != null && badge.isNotEmpty) return badge;
    }
    return super.infoValue(root, keys);
  }

  /// Paid chapters (`.locked`) are hidden, matching keiyoushi's default.
  @override
  String get chapterListSelector =>
      '#chapters-list-container .ch-item:not(.locked)';

  @override
  SChapter? chapterFromElement(Element el) {
    final chapter = super.chapterFromElement(el);
    if (chapter == null) return null;
    final name = el.querySelector('.ch-num')?.text.trim();
    if (name == null || name.isEmpty) return chapter;
    return SChapter(
      url: chapter.url,
      name: name.replaceAll(RegExp(r'\s+'), ' '),
      dateUpload: chapter.dateUpload,
      chapterNumber: chapter.chapterNumber,
    );
  }

  @override
  String? chapterDateText(Element el) =>
      el.querySelector('.ch-date')?.text.trim();
}

/// All registered MangaThemesia sources (Arabic).
///
/// Hijala serves alternating scrambled left/right image halves on some
/// chapters (keiyoushi stitches them with a bitmap interceptor); those pages
/// are returned unstitched here.
List<ThemesiaSource> themesiaSources() => [
      AriaMangaSource(),
      _ThemesiaSite(
        id: 241593018172482505,
        name: 'Area Scans',
        lang: 'ar',
        defaultBaseUrl: 'https://ar.areascans.org',
      ),
      DespairMangaSource(),
      _ThemesiaSite(
        id: 917436262447415426,
        name: 'Hijala',
        lang: 'ar',
        defaultBaseUrl: 'https://hijala.com',
      ),
      LavaScansSource(),
    ];
