import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import 'package:mihonx/core/state/bloc_status.dart';
import 'package:mihonx/features/browse/domain/source/model/s_manga.dart';

class SourceSearchResult extends Equatable {
  const SourceSearchResult({
    required this.sourceId,
    required this.sourceName,
    this.status = const BlocStatus.loading(),
    this.manga = const [],
  });

  final int sourceId;
  final String sourceName;
  final BlocStatus status;
  final List<SManga> manga;

  SourceSearchResult copyWith({BlocStatus? status, List<SManga>? manga}) =>
      SourceSearchResult(
        sourceId: sourceId,
        sourceName: sourceName,
        status: status ?? this.status,
        manga: manga ?? this.manga,
      );

  @override
  List<Object?> get props => [sourceId, status, manga];
}

@immutable
class GlobalSearchState extends Equatable {
  const GlobalSearchState({this.query = '', this.results = const []});

  final String query;
  final List<SourceSearchResult> results;

  GlobalSearchState copyWith({
    String? query,
    List<SourceSearchResult>? results,
  }) =>
      GlobalSearchState(
        query: query ?? this.query,
        results: results ?? this.results,
      );

  @override
  List<Object?> get props => [query, results];
}
