/// Base event for [GlobalSearchBloc].
sealed class GlobalSearchEvent {
  const GlobalSearchEvent();
}

/// Triggered when the user submits a query to search across all enabled sources.
final class GlobalSearched extends GlobalSearchEvent {
  const GlobalSearched(this.query);
  final String query;
}
