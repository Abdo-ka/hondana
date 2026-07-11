/// Base type for all [HistoryBloc] events.
sealed class HistoryEvent {
  const HistoryEvent();
}

/// Start watching the history stream (fired when the page opens).
final class HistorySubscribed extends HistoryEvent {
  const HistorySubscribed();
}

/// Delete a single history entry (swipe/trash action on a row).
final class HistoryEntryRemoved extends HistoryEvent {
  const HistoryEntryRemoved(this.historyId);
  final int historyId;
}

/// Wipe all reading history (app-bar clear action).
final class HistoryCleared extends HistoryEvent {
  const HistoryCleared();
}
