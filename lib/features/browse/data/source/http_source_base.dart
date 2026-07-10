import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import 'package:mihonx/core/network/app_http.dart';
import 'package:mihonx/features/browse/domain/source/model/manga_page.dart';
import 'package:mihonx/features/browse/domain/source/model/s_manga.dart';
import 'package:mihonx/features/browse/domain/source/source.dart';
import 'package:mihonx/features/browse/domain/source_preferences.dart';

/// Base for native-Dart network sources. Provides a configured [Dio] (browser
/// UA, array query encoding, OS-native TLS stack, WebView cookie replay) and a
/// default image-URL resolver. Concrete sources implement the
/// catalogue/detail/chapter/page parsing.
///
/// This is the porting target for keiyoushi sources: a subclass per source (or
/// a shared "theme" base per multisrc family — Madara, MangaThemesia, …).
abstract class HttpSourceBase implements HttpSource {
  HttpSourceBase()
      : client = Dio(
          BaseOptions(
            headers: const {'User-Agent': userAgent},
            listFormat: ListFormat.multiCompatible,
            connectTimeout: const Duration(seconds: 20),
            receiveTimeout: const Duration(seconds: 30),
            followRedirects: true,
            maxRedirects: 5,
            // Follow 3xx; only 4xx/5xx surface as errors.
            validateStatus: (status) => status != null && status < 400,
          ),
        ) {
    useNativeAdapter(client);
    final getIt = GetIt.instance;
    if (getIt.isRegistered<WebCookieStore>()) {
      client.interceptors.add(WebCookieInterceptor(getIt<WebCookieStore>()));
    }
  }

  static const String userAgent = appUserAgent;

  final Dio client;

  /// Stock site URL shipped with the source. [baseUrl] applies any user
  /// override on top — these sites hop domains frequently.
  String get defaultBaseUrl;

  @override
  String get baseUrl {
    final getIt = GetIt.instance;
    if (getIt.isRegistered<SourcePreferences>()) {
      final override = getIt<SourcePreferences>().urlOverride(id);
      if (override != null) return override;
    }
    return defaultBaseUrl;
  }

  /// Extra headers image requests must carry (referer, cookies). Overridden by
  /// sources that gate images behind a referer.
  Map<String, String> get imageHeaders => const {};

  /// Absolute website URL for a manga (WebView, sharing). Sources whose
  /// [SManga.url] is not a site path (e.g. MangaDex UUIDs) override this.
  String mangaUrl(SManga manga) => '$baseUrl${manga.url}';

  @override
  Future<String> getImageUrl(MangaPage page) async =>
      page.imageUrl ?? page.url ?? '';
}
