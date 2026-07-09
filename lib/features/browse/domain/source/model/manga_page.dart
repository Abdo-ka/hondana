/// A single reader page. Either [imageUrl] is set directly, or [url] points at a
/// page that must be resolved (via `HttpSource.getImageUrl`) to an image.
/// Named `MangaPage` to avoid clashing with Flutter's `Page`.
class MangaPage {
  const MangaPage({required this.index, this.url, this.imageUrl});

  final int index;
  final String? url;
  final String? imageUrl;

  MangaPage copyWith({int? index, String? url, String? imageUrl}) => MangaPage(
        index: index ?? this.index,
        url: url ?? this.url,
        imageUrl: imageUrl ?? this.imageUrl,
      );
}
