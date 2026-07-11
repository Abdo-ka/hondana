import 'package:html/parser.dart' as html_parser;

import 'package:hondana/features/browse/data/source/zeist/zeist_source.dart';
import 'package:hondana/features/browse/domain/source/model/s_chapter.dart';

/// Concrete ZeistManga sites, ported from keiyoushi `src/ar/*` overrides.
/// Source ids are the keiyoushi index ids so the extensions catalog marks
/// these as installed and future Mihon migrations line up.
class _ZeistSite extends ZeistSource {
  _ZeistSite({
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

/// Comic Verse — chapter feed label comes from a
/// `div.manga-widget[data-label]` widget instead of the `clwd.run` script.
class ComicVerseSource extends ZeistSource {
  @override
  int get id => 7487319247633385575;
  @override
  String get name => 'Comic Verse';
  @override
  String get lang => 'ar';
  @override
  String get defaultBaseUrl => 'https://arcomixverse.blogspot.com';

  @override
  String getChapterFeedUrl(String htmlBody) {
    final label = html_parser
        .parse(htmlBody)
        .querySelector('div.manga-widget[data-label]')
        ?.attributes['data-label'];
    if (label == null || label.isEmpty) {
      throw StateError('Failed to find chapter feed');
    }
    return '$baseUrl/feeds/posts/default/-/'
        '${Uri.encodeComponent(chapterCategory)}/${Uri.encodeComponent(label)}'
        '?alt=json';
  }
}

/// Manga Ai Land — chapters are labelled "فصل" (live-verified 2026-07).
class MangaAiLandSource extends ZeistSource {
  @override
  int get id => 7109397520501699498;
  @override
  String get name => 'Manga Ai Land';
  @override
  String get lang => 'ar';
  @override
  String get defaultBaseUrl => 'https://manga-ai-land.blogspot.com';

  @override
  String get chapterCategory => 'فصل';
}

/// XSano Manga — no popular widget; custom detail/reader selectors.
class XSanoMangaSource extends ZeistSource {
  @override
  int get id => 6170348197605244575;
  @override
  String get name => 'XSano Manga';
  @override
  String get lang => 'ar';
  @override
  String get defaultBaseUrl => 'https://www.xsano-manga.com';

  @override
  bool get useLatestForPopular => true;
  @override
  bool get supportsLatest => false;

  @override
  String get mangaDetailsSelector => 'main';
  @override
  String get mangaDetailsSelectorGenres => 'dl a[rel=tag]';
  @override
  String get mangaDetailsSelectorInfo => '#extra-info dl';
  @override
  String get mangaDetailsSelectorInfoTitle => 'dt';
  @override
  String get mangaDetailsSelectorInfoDescription => 'dd';
  @override
  String get pageListSelector => '#reader div.separator';
}

/// Yokai — prefers the entry `updated` date, normalizes chapter names to
/// "الفصل N" and appends the extra chapters listed in the download box.
class YokaiSource extends ZeistSource {
  @override
  int get id => 4337506350787725909;
  @override
  String get name => 'Yokai';
  @override
  String get lang => 'ar';
  @override
  String get defaultBaseUrl => 'https://yokai-team.blogspot.com';

  @override
  bool get preferChapterUpdatedDate => true;

  static final _arabicChapterRegex = RegExp(r'الفصل\s*(\d+(?:\.\d+)?)');
  static final _englishChapterRegex = RegExp(
    r'^Chapter\s*(\S+)',
    caseSensitive: false,
  );

  @override
  List<SChapter> postProcessChapters(String htmlBody, List<SChapter> chapters) {
    final renamed = chapters.map((chapter) {
      String? numberText;
      var name = chapter.name;
      final english = _englishChapterRegex.firstMatch(name);
      if (english != null) {
        numberText = english.group(1);
        name = 'الفصل $numberText';
      } else {
        numberText = _arabicChapterRegex.firstMatch(name)?.group(1);
      }
      final number = double.tryParse(numberText ?? '');
      return SChapter(
        url: chapter.url,
        name: name,
        dateUpload: chapter.dateUpload,
        chapterNumber: number ?? chapter.chapterNumber,
      );
    }).toList();

    final extras = html_parser
        .parse(htmlBody)
        .querySelectorAll('div#download > div.index-list > a')
        .map((a) {
          final href = a.attributes['href'];
          if (href == null || href.isEmpty) return null;
          final text = a.text.trim();
          return SChapter(
            url: href.startsWith(baseUrl)
                ? href.substring(baseUrl.length)
                : href,
            name: text,
            chapterNumber: double.tryParse(text.split(' ').first) ?? 1,
          );
        })
        .nonNulls;

    final seen = <String>{};
    return [
      ...renamed,
      ...extras,
    ].where((c) => seen.add(c.url.split('?').first)).toList();
  }
}

/// All registered ZeistManga sources (Arabic).
List<ZeistSource> zeistSources() => [
  ComicVerseSource(),
  _ZeistSite(
    id: 323105186892383931,
    name: 'Loner Translations',
    lang: 'ar',
    defaultBaseUrl: 'https://loner-tl.blogspot.com',
  ),
  MangaAiLandSource(),
  _ZeistSite(
    id: 743599002989616408,
    name: 'Manhatok',
    lang: 'ar',
    defaultBaseUrl: 'https://manhatok.blogspot.com',
  ),
  // Murim has no popular widget either (keiyoushi mirrors latest).
  _MurimSource(),
  _ZeistSite(
    id: 5634203247016722993,
    name: 'Orca Manga',
    lang: 'ar',
    defaultBaseUrl: 'https://infinity896.blogspot.com',
  ),
  XSanoMangaSource(),
  YokaiSource(),
];

class _MurimSource extends ZeistSource {
  @override
  int get id => 4966914277555229831;
  @override
  String get name => 'Murim';
  @override
  String get lang => 'ar';
  @override
  String get defaultBaseUrl => 'https://www.murim.site';

  @override
  bool get useLatestForPopular => true;
  @override
  bool get supportsLatest => false;
}
