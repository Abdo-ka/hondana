import 'package:mihonx/features/browse/domain/source/model/s_manga.dart';

/// One page of catalogue results plus whether more pages follow.
class MangasPage {
  const MangasPage({required this.mangas, this.hasNextPage = false});

  final List<SManga> mangas;
  final bool hasNextPage;

  static const empty = MangasPage(mangas: [], hasNextPage: false);
}
