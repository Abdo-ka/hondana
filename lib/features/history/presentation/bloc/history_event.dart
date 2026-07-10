sealed class HistoryEvent {
  const HistoryEvent();
}

final class HistorySubscribed extends HistoryEvent {
  const HistorySubscribed();
}

final class HistoryEntryRemoved extends HistoryEvent {
  const HistoryEntryRemoved(this.historyId);
  final int historyId;
}

final class HistoryCleared extends HistoryEvent {
  const HistoryCleared();
}
