import 'package:hondana/features/browse/domain/source/model/s_manga.dart';

/// One page of catalogue results plus whether more pages follow.
class MangasPage {
  const MangasPage({required this.mangas, this.hasNextPage = false});

  final List<SManga> mangas;

  /// Whether requesting the next page number will yield more results.
  final bool hasNextPage;

  /// Sentinel for "no results, no more pages".
  static const empty = MangasPage(mangas: [], hasNextPage: false);
}
