import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import 'package:hondana/core/state/bloc_status.dart';
import 'package:hondana/features/browse/domain/source/model/s_manga.dart';

/// One source's slice of a global search: its own [status] and [manga] so each
/// section can load, succeed, or fail independently of the others.
class SourceSearchResult extends Equatable {
  const SourceSearchResult({
    required this.sourceId,
    required this.sourceName,
    this.status = const BlocStatus.loading(),
    this.manga = const [],
  });

  final int sourceId;
  final String sourceName;

  /// Per-source async status: loading until this source's request resolves.
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

/// State for the global search screen: the active [query] and one
/// [SourceSearchResult] per enabled source, each updating as its request lands.
@immutable
class GlobalSearchState extends Equatable {
  const GlobalSearchState({this.query = '', this.results = const []});

  final String query;

  /// One section per enabled source, in source order.
  final List<SourceSearchResult> results;

  GlobalSearchState copyWith({
    String? query,
    List<SourceSearchResult>? results,
  }) => GlobalSearchState(
    query: query ?? this.query,
    results: results ?? this.results,
  );

  @override
  List<Object?> get props => [query, results];
}
