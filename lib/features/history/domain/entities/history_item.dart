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

  /// Primary key of the underlying history row (used for removal).
  final int historyId;
  final int chapterId;
  final int mangaId;

  /// Extension/source the manga belongs to; drives thumbnail fetching.
  final int sourceId;
  final String mangaTitle;
  final String chapterName;
  final String mangaUrl;
  final String? thumbnailUrl;

  /// When the chapter was last read; null before the first read is recorded.
  final DateTime? lastRead;
}
