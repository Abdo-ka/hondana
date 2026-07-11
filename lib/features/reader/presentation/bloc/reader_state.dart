import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import 'package:mihonx/core/state/bloc_status.dart';
import 'package:mihonx/features/reader/domain/reader_preferences.dart';
import 'package:mihonx/features/reader/presentation/bloc/reader_item.dart';

@immutable
class ReaderState extends Equatable {
  const ReaderState({
    this.status = const BlocStatus.loading(),
    this.items = const [],
    this.currentItem = 0,
    this.currentPage = 0,
    this.pageCount = 0,
    this.readingMode = ReadingMode.rightToLeft,
    this.showOverlay = true,
    this.chapterId,
    this.chapterName = '',
    this.imageHeaders = const {},
    this.mangaId,
    this.hasPrev = false,
    this.hasNext = false,
  });

  final BlocStatus status;

  /// Continuous list of pages and chapter transitions — grows as the next
  /// chapter is preloaded so both readers scroll/swipe across chapters.
  final List<ReaderItem> items;

  /// Index into [items] of what's on screen.
  final int currentItem;

  /// Page position within the *current chapter* (indicator + slider).
  final int currentPage;
  final int pageCount;
  final ReadingMode readingMode;
  final bool showOverlay;
  final int? chapterId;
  final String chapterName;
  final Map<String, String> imageHeaders;
  final int? mangaId;
  final bool hasPrev;
  final bool hasNext;

  ReaderState copyWith({
    BlocStatus? status,
    List<ReaderItem>? items,
    int? currentItem,
    int? currentPage,
    int? pageCount,
    ReadingMode? readingMode,
    bool? showOverlay,
    int? chapterId,
    String? chapterName,
    Map<String, String>? imageHeaders,
    int? mangaId,
    bool? hasPrev,
    bool? hasNext,
  }) {
    return ReaderState(
      status: status ?? this.status,
      items: items ?? this.items,
      currentItem: currentItem ?? this.currentItem,
      currentPage: currentPage ?? this.currentPage,
      pageCount: pageCount ?? this.pageCount,
      readingMode: readingMode ?? this.readingMode,
      showOverlay: showOverlay ?? this.showOverlay,
      chapterId: chapterId ?? this.chapterId,
      chapterName: chapterName ?? this.chapterName,
      imageHeaders: imageHeaders ?? this.imageHeaders,
      mangaId: mangaId ?? this.mangaId,
      hasPrev: hasPrev ?? this.hasPrev,
      hasNext: hasNext ?? this.hasNext,
    );
  }

  @override
  List<Object?> get props => [
        status,
        items,
        currentItem,
        currentPage,
        pageCount,
        readingMode,
        showOverlay,
        chapterId,
        chapterName,
        imageHeaders,
        mangaId,
        hasPrev,
        hasNext,
      ];
}
