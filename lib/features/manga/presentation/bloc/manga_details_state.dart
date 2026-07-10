import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import 'package:mihonx/core/database/app_database.dart';
import 'package:mihonx/core/state/bloc_status.dart';
import 'package:mihonx/features/browse/domain/source/model/s_manga.dart';
import 'package:mihonx/features/library/domain/manga.dart';

@immutable
class MangaDetailsState extends Equatable {
  const MangaDetailsState({
    required this.source,
    this.detailsStatus = const BlocStatus.initial(),
    this.chaptersStatus = const BlocStatus.initial(),
    this.mangaId,
    this.manga,
    this.chapters = const [],
    this.chaptersDescending = true,
  });

  /// Initial source data — shows the header instantly before the DB resolves.
  final SManga source;
  final BlocStatus detailsStatus;
  final BlocStatus chaptersStatus;
  final int? mangaId;
  final Manga? manga;
  final List<ChapterData> chapters;
  final bool chaptersDescending;

  bool get isFavorite => manga?.favorite ?? false;
  String get title => manga?.title ?? source.title;
  String? get thumbnailUrl => manga?.thumbnailUrl ?? source.thumbnailUrl;

  List<ChapterData> get orderedChapters =>
      chaptersDescending ? chapters : chapters.reversed.toList();

  /// Target for "Start reading": the earliest unread chapter, else the first.
  ChapterData? get nextUnread {
    final ascending = chapters.reversed;
    return ascending.firstWhereOrNull((c) => !c.read) ?? ascending.firstOrNull;
  }

  MangaDetailsState copyWith({
    SManga? source,
    BlocStatus? detailsStatus,
    BlocStatus? chaptersStatus,
    int? mangaId,
    Manga? manga,
    List<ChapterData>? chapters,
    bool? chaptersDescending,
  }) {
    return MangaDetailsState(
      source: source ?? this.source,
      detailsStatus: detailsStatus ?? this.detailsStatus,
      chaptersStatus: chaptersStatus ?? this.chaptersStatus,
      mangaId: mangaId ?? this.mangaId,
      manga: manga ?? this.manga,
      chapters: chapters ?? this.chapters,
      chaptersDescending: chaptersDescending ?? this.chaptersDescending,
    );
  }

  @override
  List<Object?> get props => [
        source,
        detailsStatus,
        chaptersStatus,
        mangaId,
        manga,
        chapters,
        chaptersDescending,
      ];
}
