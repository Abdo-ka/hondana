import 'package:mihonx/features/library/domain/manga.dart';

/// A library grid entry: the manga plus the aggregate counts shown as badges.
class LibraryManga {
  const LibraryManga({
    required this.manga,
    this.unreadCount = 0,
    this.downloadCount = 0,
  });

  final Manga manga;
  final int unreadCount;
  final int downloadCount;
}
