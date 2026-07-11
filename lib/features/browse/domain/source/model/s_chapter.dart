/// Source-level chapter model returned by [Source.getChapterList].
class SChapter {
  const SChapter({
    required this.url,
    required this.name,
    this.dateUpload,
    this.chapterNumber = -1,
    this.scanlator,
  });

  /// Source-relative key identifying the chapter.
  final String url;
  final String name;

  /// Upload timestamp, or null when the source omits it.
  final DateTime? dateUpload;

  /// Parsed chapter number, or -1 when unknown.
  final double chapterNumber;

  /// Scanlation group credited for this chapter, if any.
  final String? scanlator;
}
