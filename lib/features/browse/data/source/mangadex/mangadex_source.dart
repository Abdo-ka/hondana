import 'package:hondana/features/browse/data/source/http_source_base.dart';
import 'package:hondana/features/browse/domain/source/model/filter.dart';
import 'package:hondana/features/browse/domain/source/model/manga_page.dart';
import 'package:hondana/features/browse/domain/source/model/manga_status.dart';
import 'package:hondana/features/browse/domain/source/model/mangas_page.dart';
import 'package:hondana/features/browse/domain/source/model/s_chapter.dart';
import 'package:hondana/features/browse/domain/source/model/s_manga.dart';

/// Native-Dart MangaDex source over the public JSON API. SFW only: content
/// rating is pinned to safe + suggestive (erotica/pornographic excluded).
/// One instance per UI language (en/ar), mirroring keiyoushi's per-lang
/// sources and reusing their source ids so the extensions catalog and future
/// migrations line up.
///
/// NOTE: MangaDex (API, covers and at-home hosts) answers HTTP 400
/// "Unsupported Browser" to browser User-Agents coming from non-browser
/// clients — their API rules require clients to identify themselves. So this
/// source replaces the app-wide browser UA with a client UA everywhere.
class MangaDexSource extends HttpSourceBase {
  /// English MangaDex instance (keiyoushi `en` source id).
  MangaDexSource.en()
    : id = 2499283573021220255, // keiyoushi en source id
      lang = 'en' {
    client.options.headers['User-Agent'] = _clientUserAgent;
  }

  /// Arabic MangaDex instance (keiyoushi `ar` source id).
  MangaDexSource.ar()
    : id = 3339599426223341161, // keiyoushi ar source id
      lang = 'ar' {
    client.options.headers['User-Agent'] = _clientUserAgent;
  }

  static const _clientUserAgent = 'Hondana/1.0';

  @override
  Map<String, String> get imageHeaders => const {
    'User-Agent': _clientUserAgent,
  };

  /// [SManga.url] is the bare MangaDex UUID, not a site path.
  @override
  String mangaUrl(SManga manga) => '$baseUrl/title/${manga.url}';

  static const _api = 'https://api.mangadex.org';
  static const _covers = 'https://uploads.mangadex.org/covers';
  static const _pageSize = 24;

  /// MangaDex rejects listing requests where limit + offset exceeds 10 000.
  static const _maxOffset = 10000;

  /// Non-adult ratings only.
  static const _ratings = ['safe', 'suggestive'];

  @override
  final int id;
  @override
  final String lang;
  @override
  String get name => 'MangaDex';
  @override
  String get defaultBaseUrl => 'https://mangadex.org';
  @override
  bool get supportsLatest => true;

  @override
  FilterList getFilterList() => [];

  // ── Catalogue ──────────────────────────────────────────────────────────────

  Future<MangasPage> _mangaList(
    int page, {
    String? title,
    required List<MapEntry<String, String>> order,
  }) async {
    final offset = (page - 1) * _pageSize;
    if (offset >= _maxOffset) return MangasPage.empty;
    // Bare list keys: Dio's ListFormat.multiCompatible appends the `[]`.
    final params = <String, dynamic>{
      'limit': _pageSize,
      'offset': offset,
      'contentRating': _ratings,
      'includes': ['cover_art'],
      'availableTranslatedLanguage': [lang],
      'hasAvailableChapters': 'true',
      for (final o in order) 'order[${o.key}]': o.value,
    };
    if (title != null && title.isNotEmpty) params['title'] = title;

    final res = await client.get<Map<String, dynamic>>(
      '$_api/manga',
      queryParameters: params,
    );
    final data = (res.data?['data'] as List?) ?? const [];
    final total = (res.data?['total'] as num?)?.toInt() ?? 0;
    final mangas = data
        .whereType<Map<String, dynamic>>()
        .map(_parseManga)
        .toList();
    final next = offset + _pageSize;
    return MangasPage(
      mangas: mangas,
      hasNextPage: next < total && next < _maxOffset,
    );
  }

  @override
  Future<MangasPage> getPopularManga(int page) =>
      _mangaList(page, order: [const MapEntry('followedCount', 'desc')]);

  @override
  Future<MangasPage> getLatestUpdates(int page) => _mangaList(
    page,
    order: [const MapEntry('latestUploadedChapter', 'desc')],
  );

  @override
  Future<MangasPage> getSearchManga(
    int page,
    String query,
    FilterList filters,
  ) => _mangaList(
    page,
    title: query,
    order: [const MapEntry('relevance', 'desc')],
  );

  // ── Details ──────────────────────────────────────────────────────────────

  @override
  Future<SManga> getMangaDetails(SManga manga) async {
    final res = await client.get<Map<String, dynamic>>(
      '$_api/manga/${manga.url}',
      queryParameters: {
        'includes': ['cover_art', 'author', 'artist'],
      },
    );
    final data = res.data?['data'] as Map<String, dynamic>?;
    if (data == null) return manga;
    return _parseManga(data).copyWith(initialized: true);
  }

  @override
  Future<List<SChapter>> getChapterList(SManga manga) async {
    final chapters = <SChapter>[];
    var offset = 0;
    while (true) {
      final res = await client.get<Map<String, dynamic>>(
        '$_api/manga/${manga.url}/feed',
        queryParameters: {
          'limit': 500,
          'offset': offset,
          'translatedLanguage': [lang],
          'contentRating': _ratings,
          'includes': ['scanlation_group'],
          'order[volume]': 'desc',
          'order[chapter]': 'desc',
        },
      );
      final data = (res.data?['data'] as List?) ?? const [];
      final total = (res.data?['total'] as num?)?.toInt() ?? 0;
      chapters.addAll(
        data.whereType<Map<String, dynamic>>().map(_parseChapter).nonNulls,
      );
      offset += 500;
      if (offset >= total || offset + 500 > _maxOffset || data.isEmpty) break;
    }
    return chapters;
  }

  @override
  Future<List<MangaPage>> getPageList(SChapter chapter) async {
    final res = await client.get<Map<String, dynamic>>(
      '$_api/at-home/server/${chapter.url}',
    );
    final base = res.data?['baseUrl'] as String?;
    final ch = res.data?['chapter'] as Map<String, dynamic>?;
    final hash = ch?['hash'] as String?;
    final files = (ch?['data'] as List?)?.whereType<String>().toList() ?? [];
    if (base == null || hash == null) return const [];
    return List.generate(
      files.length,
      (i) => MangaPage(index: i, imageUrl: '$base/data/$hash/${files[i]}'),
    );
  }

  // ── Parsing ──────────────────────────────────────────────────────────────

  SManga _parseManga(Map<String, dynamic> obj) {
    final attrs = (obj['attributes'] as Map<String, dynamic>?) ?? const {};
    final rels = (obj['relationships'] as List?) ?? const [];

    String? coverFile;
    String? author;
    for (final r in rels.whereType<Map<String, dynamic>>()) {
      final type = r['type'];
      final rAttrs = r['attributes'] as Map<String, dynamic>?;
      if (type == 'cover_art') coverFile = rAttrs?['fileName'] as String?;
      if (type == 'author') author ??= rAttrs?['name'] as String?;
    }

    return SManga(
      url: obj['id'] as String,
      title: _localized(attrs['title']) ?? 'Unknown',
      author: author,
      description: _localized(attrs['description']),
      genre: ((attrs['tags'] as List?) ?? const [])
          .whereType<Map<String, dynamic>>()
          .map((t) => _localized((t['attributes'] as Map?)?['name']))
          .whereType<String>()
          .toList(),
      status: _status(attrs['status'] as String?),
      thumbnailUrl: coverFile == null
          ? null
          : '$_covers/${obj['id']}/$coverFile.256.jpg',
    );
  }

  SChapter? _parseChapter(Map<String, dynamic> obj) {
    final attrs = (obj['attributes'] as Map<String, dynamic>?) ?? const {};
    // Skip externally-hosted chapters (no readable pages here).
    if (attrs['externalUrl'] != null) return null;
    final number = double.tryParse('${attrs['chapter'] ?? ''}') ?? -1;
    final volume = attrs['volume'];
    final title = attrs['title'] as String?;
    final rels = (obj['relationships'] as List?) ?? const [];
    String? group;
    for (final r in rels.whereType<Map<String, dynamic>>()) {
      if (r['type'] == 'scanlation_group') {
        group = (r['attributes'] as Map?)?['name'] as String?;
      }
    }
    final label = StringBuffer();
    if (volume != null) label.write('Vol. $volume ');
    label.write(number >= 0 ? 'Ch. ${attrs['chapter']}' : 'Oneshot');
    if (title != null && title.isNotEmpty) label.write(' - $title');
    return SChapter(
      url: obj['id'] as String,
      name: label.toString(),
      chapterNumber: number,
      scanlator: group,
      dateUpload: DateTime.tryParse('${attrs['publishAt'] ?? ''}'),
    );
  }

  String? _localized(Object? map) {
    if (map is! Map || map.isEmpty) return null;
    final v = map[lang] ?? map['en'] ?? map.values.first;
    return v is String ? v : null;
  }

  MangaStatus _status(String? s) => switch (s) {
    'ongoing' => MangaStatus.ongoing,
    'completed' => MangaStatus.completed,
    'hiatus' => MangaStatus.onHiatus,
    'cancelled' => MangaStatus.cancelled,
    _ => MangaStatus.unknown,
  };
}
