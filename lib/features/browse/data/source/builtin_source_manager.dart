import 'package:injectable/injectable.dart';

import 'package:hondana/features/browse/data/source/local_source.dart';
import 'package:hondana/features/browse/data/source/madara/madara_sites.dart';
import 'package:hondana/features/browse/data/source/mangadex/mangadex_source.dart';
import 'package:hondana/features/browse/domain/source/source.dart';
import 'package:hondana/features/browse/domain/source/source_manager.dart';

/// Registry of the built-in native-Dart sources. New ports (Madara /
/// MangaThemesia / ZeistManga theme sources, etc.) are added here. Source ids
/// mirror the keiyoushi index so the extensions catalog can mark ported
/// entries as installed.
@LazySingleton(as: SourceManager)
class BuiltinSourceManager implements SourceManager {
  BuiltinSourceManager()
    : _all = [
        LocalSource(),
        MangaDexSource.en(),
        MangaDexSource.ar(),
        ...madaraSources(),
      ];

  final List<Source> _all;

  @override
  Source? get(int id) => _all.where((s) => s.id == id).firstOrNull;

  @override
  CatalogueSource? getCatalogueSource(int id) {
    final s = get(id);
    return s is CatalogueSource ? s : null;
  }

  @override
  List<Source> getSources() => _all;

  @override
  List<CatalogueSource> getCatalogueSources() =>
      _all.whereType<CatalogueSource>().toList();
}
