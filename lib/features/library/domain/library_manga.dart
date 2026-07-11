import 'package:hondana/features/library/domain/manga.dart';

/// A library grid entry: the manga plus the aggregate counts shown as badges.
class LibraryManga {
  const LibraryManga({
    required this.manga,
    this.unreadCount = 0,
    this.downloadCount = 0,
  });

  final Manga manga;

  /// Unread chapters — drives the unread badge and the unread sort/filter.
  final int unreadCount;

  /// Downloaded chapters — drives the download badge and the downloaded filter.
  final int downloadCount;
}
