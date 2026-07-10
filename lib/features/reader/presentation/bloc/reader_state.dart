import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import 'package:mihonx/core/state/bloc_status.dart';
import 'package:mihonx/features/browse/domain/source/model/manga_page.dart';
import 'package:mihonx/features/reader/domain/reader_preferences.dart';

@immutable
class ReaderState extends Equatable {
  const ReaderState({
    this.status = const BlocStatus.loading(),
    this.pages = const [],
    this.currentPage = 0,
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
  final List<MangaPage> pages;
  final int currentPage;
  final ReadingMode readingMode;
  final bool showOverlay;
  final int? chapterId;
  final String chapterName;
  final Map<String, String> imageHeaders;
  final int? mangaId;
  final bool hasPrev;
  final bool hasNext;

  int get pageCount => pages.length;

  ReaderState copyWith({
    BlocStatus? status,
    List<MangaPage>? pages,
    int? currentPage,
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
      pages: pages ?? this.pages,
      currentPage: currentPage ?? this.currentPage,
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
        pages,
        currentPage,
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
