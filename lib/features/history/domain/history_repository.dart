/// A recently-read entry (join of history + chapter + manga) for the History
/// feed + resume.
class HistoryItem {
  const HistoryItem({
    required this.historyId,
    required this.chapterId,
    required this.mangaId,
    required this.sourceId,
    required this.mangaTitle,
    required this.chapterName,
    required this.mangaUrl,
    this.thumbnailUrl,
    this.lastRead,
  });

  final int historyId;
  final int chapterId;
  final int mangaId;
  final int sourceId;
  final String mangaTitle;
  final String chapterName;
  final String mangaUrl;
  final String? thumbnailUrl;
  final DateTime? lastRead;
}

abstract interface class HistoryRepository {
  /// Records (or bumps) the read time for a chapter.
  Future<void> upsert(int chapterId);

  Stream<List<HistoryItem>> watchHistory();

  Future<void> remove(int historyId);

  Future<void> clear();
}
