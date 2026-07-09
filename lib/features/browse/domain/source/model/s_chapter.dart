/// Source-level chapter model returned by [Source.getChapterList].
class SChapter {
  const SChapter({
    required this.url,
    required this.name,
    this.dateUpload,
    this.chapterNumber = -1,
    this.scanlator,
  });

  final String url;
  final String name;
  final DateTime? dateUpload;

  /// Parsed chapter number, or -1 when unknown.
  final double chapterNumber;
  final String? scanlator;
}
