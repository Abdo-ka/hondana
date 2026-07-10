/// A recent chapter for a favorited manga (the Updates feed).
class UpdateItem {
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

abstract interface class UpdatesRepository {
  Stream<List<UpdateItem>> watchUpdates();
}
