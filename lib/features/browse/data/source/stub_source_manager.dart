import 'package:injectable/injectable.dart';

import 'package:mihonx/features/browse/data/source/local_source.dart';
import 'package:mihonx/features/browse/domain/source/source.dart';
import 'package:mihonx/features/browse/domain/source/source_manager.dart';

/// Phase-1 source registry: LocalSource only. The iOS phase replaces this with
/// an extension-runtime-backed manager bound to the same [SourceManager]
/// interface — no feature code changes.
@LazySingleton(as: SourceManager)
class StubSourceManager implements SourceManager {
  StubSourceManager() : _local = LocalSource();

  final LocalSource _local;

  List<Source> get _all => [_local];

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
