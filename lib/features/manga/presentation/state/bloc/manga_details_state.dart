import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import 'package:hondana/core/database/app_database.dart';
import 'package:hondana/core/state/bloc_status.dart';
import 'package:hondana/features/browse/domain/source/model/s_manga.dart';
import 'package:hondana/features/library/domain/manga.dart';

/// Immutable state for [MangaDetailsBloc]: source seed, persisted manga row,
/// chapter list, per-op statuses, and the display sort direction.
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

  /// Status of the source details fetch.
  final BlocStatus detailsStatus;

  /// Status of the chapter list fetch.
  final BlocStatus chaptersStatus;

  /// Local row id, set once [resolveManga] completes.
  final int? mangaId;

  /// The persisted manga row; null until the DB watch emits.
  final Manga? manga;

  /// Canonical order as streamed from the repository: newest first.
  final List<ChapterData> chapters;

  /// Whether the list is shown newest-first (the default).
  final bool chaptersDescending;

  /// Whether the manga is in the library.
  bool get isFavorite => manga?.favorite ?? false;

  /// Persisted title, falling back to the source seed.
  String get title => manga?.title ?? source.title;

  /// Persisted cover url, falling back to the source seed.
  String? get thumbnailUrl => manga?.thumbnailUrl ?? source.thumbnailUrl;

  /// Display order — derived so DB re-emissions can't clobber the sort toggle.
  List<ChapterData> get orderedChapters =>
      chaptersDescending ? chapters : chapters.reversed.toList();

  /// Reading order (chapter 1 first) — the order downloads are queued in.
  List<ChapterData> get ascendingChapters => chapters.reversed.toList();

  /// Unread chapters in reading order (Mihon's "download next N/unread" pool).
  List<ChapterData> get unreadAscending =>
      ascendingChapters.where((c) => !c.read).toList();

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
