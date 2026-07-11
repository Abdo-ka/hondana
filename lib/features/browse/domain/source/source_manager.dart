import 'package:hondana/features/browse/domain/source/source.dart';

/// Resolves a source id → [Source]. Phase 1 binds this to `StubSourceManager`
/// (LocalSource only); the iOS phase swaps in the extension-runtime-backed
/// implementation without touching any feature code.
abstract interface class SourceManager {
  /// The source for [id], or null if none is registered.
  Source? get(int id);

  /// Like [get] but null unless the source is a [CatalogueSource].
  CatalogueSource? getCatalogueSource(int id);

  /// All registered sources.
  List<Source> getSources();

  /// The subset of [getSources] that are browsable catalogues.
  List<CatalogueSource> getCatalogueSources();
}
