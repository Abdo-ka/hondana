import 'package:mihonx/features/browse/domain/source/source.dart';

/// Resolves a source id → [Source]. Phase 1 binds this to `StubSourceManager`
/// (LocalSource only); the iOS phase swaps in the extension-runtime-backed
/// implementation without touching any feature code.
abstract interface class SourceManager {
  Source? get(int id);
  CatalogueSource? getCatalogueSource(int id);
  List<Source> getSources();
  List<CatalogueSource> getCatalogueSources();
}
