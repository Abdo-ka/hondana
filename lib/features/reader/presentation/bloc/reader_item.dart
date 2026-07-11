import 'package:equatable/equatable.dart';

import 'package:mihonx/features/browse/domain/source/model/manga_page.dart';

/// One entry in the reader's continuous item list: chapters flow into each
/// other separated by transition cards (Mihon's viewer model), so webtoon
/// scrolling and paged swiping continue straight into the next chapter.
sealed class ReaderItem extends Equatable {
  const ReaderItem();
}

final class ReaderPageItem extends ReaderItem {
  const ReaderPageItem({
    required this.chapterId,
    required this.chapterName,
    required this.pageIndex,
    required this.pageCount,
    required this.page,
  });

  final int chapterId;
  final String chapterName;

  /// Position within the owning chapter (0-based) — drives the page
  /// indicator and lastPageRead, not the global item index.
  final int pageIndex;
  final int pageCount;
  final MangaPage page;

  @override
  List<Object?> get props => [chapterId, pageIndex, pageCount, page.imageUrl];
}

/// "Finished: X / Next: Y" card between chapters; [toChapterName] == null
/// means there is no next chapter.
final class ReaderTransitionItem extends ReaderItem {
  const ReaderTransitionItem({
    required this.fromChapterId,
    required this.fromChapterName,
    this.toChapterName,
  });

  /// The chapter this card follows — reaching the card finishes it.
  final int fromChapterId;
  final String fromChapterName;
  final String? toChapterName;

  @override
  List<Object?> get props => [fromChapterId, fromChapterName, toChapterName];
}
