sealed class GlobalSearchEvent {
  const GlobalSearchEvent();
}

final class GlobalSearched extends GlobalSearchEvent {
  const GlobalSearched(this.query);
  final String query;
}
