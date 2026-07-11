import 'package:hondana/features/browse/presentation/bloc/source_catalogue_state.dart';

/// Base event for [SourceCatalogueBloc].
sealed class SourceCatalogueEvent {
  const SourceCatalogueEvent();
}

/// Triggered to load (or reload) the first page for the current mode/query.
final class CatalogueStarted extends SourceCatalogueEvent {
  const CatalogueStarted();
}

/// Triggered when the user switches between popular / latest / search tabs.
final class CatalogueModeChanged extends SourceCatalogueEvent {
  const CatalogueModeChanged(this.mode);
  final CatalogueMode mode;
}

/// Triggered when the user submits a search query within this source.
final class CatalogueSearched extends SourceCatalogueEvent {
  const CatalogueSearched(this.query);
  final String query;
}

/// Triggered by scrolling near the end to fetch the next page.
final class CatalogueLoadMore extends SourceCatalogueEvent {
  const CatalogueLoadMore();
}
