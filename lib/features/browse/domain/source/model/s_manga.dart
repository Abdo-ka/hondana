import 'package:mihonx/features/browse/domain/source/model/manga_status.dart';

/// Source-level manga model (the wire/parse shape a [Source] returns), distinct
/// from the persisted library `Manga` row. `url` is the source-relative key.
class SManga {
  const SManga({
    required this.url,
    required this.title,
    this.artist,
    this.author,
    this.description,
    this.genre = const [],
    this.status = MangaStatus.unknown,
    this.thumbnailUrl,
    this.initialized = false,
  });

  final String url;
  final String title;
  final String? artist;
  final String? author;
  final String? description;
  final List<String> genre;
  final MangaStatus status;
  final String? thumbnailUrl;

  /// True once details have been fetched (avoids redundant network calls).
  final bool initialized;

  SManga copyWith({
    String? url,
    String? title,
    String? artist,
    String? author,
    String? description,
    List<String>? genre,
    MangaStatus? status,
    String? thumbnailUrl,
    bool? initialized,
  }) {
    return SManga(
      url: url ?? this.url,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      author: author ?? this.author,
      description: description ?? this.description,
      genre: genre ?? this.genre,
      status: status ?? this.status,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      initialized: initialized ?? this.initialized,
    );
  }
}
