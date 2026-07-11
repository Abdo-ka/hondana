import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import 'package:hondana/core/state/bloc_status.dart';
import 'package:hondana/features/browse/domain/source/model/s_manga.dart';

/// Which listing a source catalogue is showing: popular, latest, or search.
enum CatalogueMode { popular, latest, search }

/// State for a single source's browse screen: the current listing mode/query,
/// the accumulated pages, and separate statuses for the initial load and paging.
@immutable
class SourceCatalogueState extends Equatable {
  const SourceCatalogueState({
    this.loadStatus = const BlocStatus.initial(),
    this.loadMoreStatus = const BlocStatus.initial(),
    this.mode = CatalogueMode.popular,
    this.query = '',
    this.manga = const [],
    this.page = 1,
    this.hasNext = false,
  });

  /// Status of the initial / refreshed first-page load.
  final BlocStatus loadStatus;

  /// Status of the most recent load-more page fetch, kept separate so paging
  /// errors don't clobber the already-visible grid.
  final BlocStatus loadMoreStatus;
  final CatalogueMode mode;
  final String query;

  /// Accumulated visible entries across all loaded pages.
  final List<SManga> manga;

  /// Highest page number loaded so far.
  final int page;

  /// Whether the source reports another page after [page].
  final bool hasNext;

  SourceCatalogueState copyWith({
    BlocStatus? loadStatus,
    BlocStatus? loadMoreStatus,
    CatalogueMode? mode,
    String? query,
    List<SManga>? manga,
    int? page,
    bool? hasNext,
  }) {
    return SourceCatalogueState(
      loadStatus: loadStatus ?? this.loadStatus,
      loadMoreStatus: loadMoreStatus ?? this.loadMoreStatus,
      mode: mode ?? this.mode,
      query: query ?? this.query,
      manga: manga ?? this.manga,
      page: page ?? this.page,
      hasNext: hasNext ?? this.hasNext,
    );
  }

  @override
  List<Object?> get props => [
    loadStatus,
    loadMoreStatus,
    mode,
    query,
    manga,
    page,
    hasNext,
  ];
}
