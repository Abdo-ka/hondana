import 'package:mihonx/features/browse/presentation/bloc/source_catalogue_state.dart';

sealed class SourceCatalogueEvent {
  const SourceCatalogueEvent();
}

final class CatalogueStarted extends SourceCatalogueEvent {
  const CatalogueStarted();
}

final class CatalogueModeChanged extends SourceCatalogueEvent {
  const CatalogueModeChanged(this.mode);
  final CatalogueMode mode;
}

final class CatalogueSearched extends SourceCatalogueEvent {
  const CatalogueSearched(this.query);
  final String query;
}

final class CatalogueLoadMore extends SourceCatalogueEvent {
  const CatalogueLoadMore();
}
