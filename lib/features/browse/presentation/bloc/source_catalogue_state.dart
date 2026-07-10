import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import 'package:mihonx/core/state/bloc_status.dart';
import 'package:mihonx/features/browse/domain/source/model/s_manga.dart';

enum CatalogueMode { popular, latest, search }

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

  final BlocStatus loadStatus;
  final BlocStatus loadMoreStatus;
  final CatalogueMode mode;
  final String query;
  final List<SManga> manga;
  final int page;
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
  List<Object?> get props =>
      [loadStatus, loadMoreStatus, mode, query, manga, page, hasNext];
}
