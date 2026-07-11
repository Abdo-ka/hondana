import 'package:hondana/features/history/domain/entities/history_item.dart';

/// Storage boundary for reading history — implemented in the data layer by
/// `HistoryRepositoryImp` and consumed by `HistoryBloc`.
abstract interface class HistoryRepository {
  /// Records (or bumps) the read time for a chapter.
  Future<void> upsert(int chapterId);

  /// Reactive feed of history entries, newest first; emits on every change.
  Stream<List<HistoryItem>> watchHistory();

  /// Deletes a single history entry by its [HistoryItem.historyId].
  Future<void> remove(int historyId);

  /// Wipes all reading history.
  Future<void> clear();
}
