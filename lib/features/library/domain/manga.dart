import 'package:mihonx/core/database/app_database.dart';
import 'package:mihonx/features/browse/domain/source/model/manga_status.dart';

/// Domain manga entity — presentation-facing view of a persisted [MangaData]
/// row (keeps drift types out of the UI). `genre` is exploded from the stored
/// comma-separated string.
class Manga {
  const Manga({
    required this.id,
    required this.source,
    required this.url,
    required this.title,
    this.author,
    this.artist,
    this.description,
    this.genre = const [],
    this.status = MangaStatus.unknown,
    this.thumbnailUrl,
    this.favorite = false,
    this.dateAdded,
    this.lastUpdate,
  });

  final int id;
  final int source;
  final String url;
  final String title;
  final String? author;
  final String? artist;
  final String? description;
  final List<String> genre;
  final MangaStatus status;
  final String? thumbnailUrl;
  final bool favorite;
  final DateTime? dateAdded;
  final DateTime? lastUpdate;

  factory Manga.fromData(MangaData d) => Manga(
        id: d.id,
        source: d.source,
        url: d.url,
        title: d.title,
        author: d.author,
        artist: d.artist,
        description: d.description,
        genre: (d.genre == null || d.genre!.trim().isEmpty)
            ? const []
            : d.genre!.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
        status: (d.status >= 0 && d.status < MangaStatus.values.length)
            ? MangaStatus.values[d.status]
            : MangaStatus.unknown,
        thumbnailUrl: d.thumbnailUrl,
        favorite: d.favorite,
        dateAdded: d.dateAdded,
        lastUpdate: d.lastUpdate,
      );
}
