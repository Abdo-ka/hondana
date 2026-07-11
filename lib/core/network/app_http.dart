import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';
import 'package:native_dio_adapter/native_dio_adapter.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Browser-like User-Agent shared by source requests, image loads and the
/// bypass WebView — a consistent identity is what lets Cloudflare clearance
/// cookies obtained in the WebView keep working for Dio requests.
const String appUserAgent =
    'Mozilla/5.0 (iPhone; CPU iPhone OS 17_5 like Mac OS X) '
    'AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.5 Mobile/15E148 '
    'Safari/604.1';

/// Routes [dio] through the OS network stack (NSURLSession on iOS/macOS,
/// Cronet on Android). Dart's built-in HttpClient has a TLS fingerprint that
/// MangaDex (and some Cloudflare configurations) reject with an
/// "Unsupported Browser" HTTP 400; the OS stacks pass as real browsers.
void useNativeAdapter(Dio dio) {
  try {
    dio.httpClientAdapter = NativeAdapter();
  } catch (_) {
    // Test VM / unsupported platform: keep Dio's default adapter.
  }
}

/// package:http client on the OS network stack, for image loading.
http.Client createNativeHttpClient() {
  try {
    if (Platform.isIOS || Platform.isMacOS) {
      return CupertinoClient.defaultSessionConfiguration();
    }
    if (Platform.isAndroid) {
      return CronetClient.defaultCronetEngine();
    }
  } catch (_) {
    // Fall through to the default client.
  }
  return http.Client();
}

/// Cookies captured from the bypass WebView, replayed onto Dio and image
/// requests for the same host (Cloudflare cf_clearance et al).
@lazySingleton
class WebCookieStore {
  WebCookieStore(this._prefs);

  final SharedPreferences _prefs;
  static const _key = 'webview.cookies';

  Map<String, String> get _all {
    final raw = _prefs.getString(_key);
    if (raw == null) return const {};
    return Map<String, String>.from(jsonDecode(raw) as Map);
  }

  String? cookieHeaderFor(Uri uri) {
    final all = _all;
    final host = uri.host;
    if (all.containsKey(host)) return all[host];
    // Cookies saved for `example.com` also apply to `www.example.com`.
    for (final e in all.entries) {
      if (host.endsWith('.${e.key}') || e.key.endsWith('.$host')) {
        return e.value;
      }
    }
    return null;
  }

  Future<void> save(String host, String cookieHeader) async {
    final all = Map<String, String>.from(_all);
    if (cookieHeader.isEmpty) {
      all.remove(host);
    } else {
      all[host] = cookieHeader;
    }
    await _prefs.setString(_key, jsonEncode(all));
  }

  /// Settings > Advanced > Clear cookies: drops every replayed cookie.
  Future<void> clear() => _prefs.remove(_key);
}

/// Injects stored WebView cookies into outgoing Dio requests.
class WebCookieInterceptor extends Interceptor {
  const WebCookieInterceptor(this._store);

  final WebCookieStore _store;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final cookie = _store.cookieHeaderFor(options.uri);
    if (cookie != null && !options.headers.containsKey('Cookie')) {
      options.headers['Cookie'] = cookie;
    }
    handler.next(options);
  }
}

/// Image cache on the native network stack: MangaDex's cover CDN applies the
/// same TLS-fingerprint block as its API, so the default image pipeline 400s.
class AppImageCache {
  AppImageCache._();

  static final CacheManager manager = CacheManager(
    Config(
      'mihonxImages',
      fileService: HttpFileService(httpClient: _HeaderedClient()),
    ),
  );
}

/// Adds the shared UA + stored WebView cookies to every image request.
class _HeaderedClient extends http.BaseClient {
  _HeaderedClient() : _inner = createNativeHttpClient();

  final http.Client _inner;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers.putIfAbsent('User-Agent', () => appUserAgent);
    final cookie = _cookieStore?.cookieHeaderFor(request.url);
    if (cookie != null) request.headers.putIfAbsent('Cookie', () => cookie);
    return _inner.send(request);
  }

  WebCookieStore? get _cookieStore => cookieStoreResolver?.call();
}

/// Set at DI init; nullable so widget tests can run without a container.
WebCookieStore Function()? cookieStoreResolver;
