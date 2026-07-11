import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import 'package:mihonx/features/browse/domain/extension_info.dart';

/// Fetches the keiyoushi extension index and filters it to the app's policy:
/// Arabic + English + multi-language ("all"); 18+ entries excluded unless the
/// "Show NSFW sources" browse setting allows them.
@lazySingleton
class ExtensionsIndexRepository {
  ExtensionsIndexRepository() : _dio = Dio();

  final Dio _dio;

  static const indexUrl =
      'https://raw.githubusercontent.com/keiyoushi/extensions/repo/index.min.json';
  static const allowedLangs = {'ar', 'en', 'all'};

  Future<List<ExtensionInfo>> fetchAll({bool includeNsfw = false}) async {
    // GitHub serves the file as text/plain, so Dio won't JSON-decode it —
    // fetch the raw string and decode ourselves.
    final res = await _dio.get<String>(
      indexUrl,
      options: Options(responseType: ResponseType.plain),
    );
    final decoded = jsonDecode(res.data ?? '[]') as List<dynamic>;
    return filter(
      decoded.whereType<Map<String, dynamic>>().map(ExtensionInfo.fromJson),
      includeNsfw: includeNsfw,
    );
  }

  /// Pure filter — exposed for testing.
  static List<ExtensionInfo> filter(
    Iterable<ExtensionInfo> all, {
    bool includeNsfw = false,
  }) {
    final list = all
        .where((e) => (includeNsfw || !e.nsfw) && allowedLangs.contains(e.lang))
        .toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return list;
  }
}
