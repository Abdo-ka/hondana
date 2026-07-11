/// A single reader page. Either [imageUrl] is set directly, or [url] points at a
/// page that must be resolved (via `HttpSource.getImageUrl`) to an image.
/// Named `MangaPage` to avoid clashing with Flutter's `Page`.
class MangaPage {
  const MangaPage({required this.index, this.url, this.imageUrl});

  /// Zero-based position within the chapter.
  final int index;

  /// Page URL to resolve when [imageUrl] is not yet known.
  final String? url;

  /// Direct image URL once resolved (or provided by the source upfront).
  final String? imageUrl;

  MangaPage copyWith({int? index, String? url, String? imageUrl}) => MangaPage(
    index: index ?? this.index,
    url: url ?? this.url,
    imageUrl: imageUrl ?? this.imageUrl,
  );
}
