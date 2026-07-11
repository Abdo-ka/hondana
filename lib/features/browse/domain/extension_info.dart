import 'package:equatable/equatable.dart';

/// One entry of the keiyoushi extension repo index (catalog metadata only —
/// the referenced payloads are Android APKs, which cannot execute inside this
/// app or on iOS; native Dart sources provide the runnable implementations).
class ExtensionInfo extends Equatable {
  const ExtensionInfo({
    required this.name,
    required this.pkg,
    required this.lang,
    required this.version,
    required this.nsfw,
    required this.sourceIds,
  });

  /// Display name (the "Tachiyomi: " prefix is stripped on parse).
  final String name;

  /// Android package id — also the key used to build [iconUrl].
  final String pkg;

  /// Primary content language (e.g. `en`, `all`).
  final String lang;
  final String version;

  /// True when the extension is flagged 18+ in the index.
  final bool nsfw;

  /// Stable Tachiyomi source ids contained in this extension.
  final List<int> sourceIds;

  /// CDN url of the extension icon, derived from [pkg].
  String get iconUrl =>
      'https://raw.githubusercontent.com/keiyoushi/extensions/repo/icon/$pkg.png';

  /// Parses one index entry; missing/malformed fields fall back to safe
  /// defaults so a bad row never breaks the whole catalogue.
  factory ExtensionInfo.fromJson(Map<String, dynamic> json) => ExtensionInfo(
    // Index names carry a "Tachiyomi: " prefix — strip for display.
    name: (json['name'] as String? ?? '').replaceFirst(
      RegExp(r'^Tachiyomi:\s*'),
      '',
    ),
    pkg: json['pkg'] as String? ?? '',
    lang: json['lang'] as String? ?? '',
    version: json['version'] as String? ?? '',
    nsfw: (json['nsfw'] as num? ?? 0) != 0,
    sourceIds: ((json['sources'] as List?) ?? const [])
        .whereType<Map<String, dynamic>>()
        .map((s) => int.tryParse('${s['id']}'))
        .nonNulls
        .toList(),
  );

  @override
  List<Object?> get props => [pkg, version];
}
