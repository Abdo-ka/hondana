/// A recent chapter for a favorited manga (the Updates feed).
///
/// Flattened join of a chapter row with its parent manga so the UI can render
/// a tile without a second lookup.
class UpdateItem {
  /// Creates an update row from joined chapter + manga columns.
  const UpdateItem({
    required this.chapterId,
    required this.mangaId,
    required this.sourceId,
    required this.mangaTitle,
    required this.chapterName,
    required this.read,
    this.thumbnailUrl,
    this.dateUpload,
  });

  final int chapterId;
  final int mangaId;
  final int sourceId;
  final String mangaTitle;
  final String chapterName;
  final bool read;
  final String? thumbnailUrl;
  final DateTime? dateUpload;
}

/// Read-side source for the Updates feed.
abstract interface class UpdatesRepository {
  /// Emits recent chapters of favorited manga, newest first.
  Stream<List<UpdateItem>> watchUpdates();
}
