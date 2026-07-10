import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart' show immutable;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'package:mihonx/core/error/app_exception.dart';
import 'package:mihonx/core/state/bloc_status.dart';
import 'package:mihonx/features/browse/data/extensions_index_repository.dart';
import 'package:mihonx/features/browse/domain/extension_info.dart';
import 'package:mihonx/features/browse/domain/source/source_manager.dart';

sealed class ExtensionsEvent {
  const ExtensionsEvent();
}

final class ExtensionsFetched extends ExtensionsEvent {
  const ExtensionsFetched();
}

final class ExtensionsSearchChanged extends ExtensionsEvent {
  const ExtensionsSearchChanged(this.query);
  final String query;
}

final class ExtensionsLangChanged extends ExtensionsEvent {
  const ExtensionsLangChanged(this.lang);

  /// 'ar' | 'en' | 'all' (multi-language), or null for no filter.
  final String? lang;
}

@immutable
class ExtensionsState extends Equatable {
  const ExtensionsState({
    this.loadStatus = const BlocStatus.initial(),
    this.all = const [],
    this.query = '',
    this.langFilter,
    this.implementedSourceIds = const {},
  });

  final BlocStatus loadStatus;
  final List<ExtensionInfo> all;
  final String query;

  /// 'ar' | 'en' | 'all', or null = every language.
  final String? langFilter;

  /// Source ids that have a native Dart implementation in this app.
  final Set<int> implementedSourceIds;

  List<ExtensionInfo> get filtered {
    Iterable<ExtensionInfo> list = all;
    if (langFilter != null) list = list.where((e) => e.lang == langFilter);
    if (query.isNotEmpty) {
      list = list
          .where((e) => e.name.toLowerCase().contains(query.toLowerCase()));
    }
    // Ported (usable) extensions first, Mihon's installed-first ordering.
    final result = list.toList()
      ..sort((a, b) {
        final ai = isImplemented(a) ? 0 : 1;
        final bi = isImplemented(b) ? 0 : 1;
        return ai != bi
            ? ai - bi
            : a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });
    return result;
  }

  bool isImplemented(ExtensionInfo e) =>
      e.sourceIds.any(implementedSourceIds.contains);

  ExtensionsState copyWith({
    BlocStatus? loadStatus,
    List<ExtensionInfo>? all,
    String? query,
    Object? langFilter = _unset,
    Set<int>? implementedSourceIds,
  }) =>
      ExtensionsState(
        loadStatus: loadStatus ?? this.loadStatus,
        all: all ?? this.all,
        query: query ?? this.query,
        langFilter:
            langFilter == _unset ? this.langFilter : langFilter as String?,
        implementedSourceIds: implementedSourceIds ?? this.implementedSourceIds,
      );

  static const _unset = Object();

  @override
  List<Object?> get props =>
      [loadStatus, all, query, langFilter, implementedSourceIds];
}

@injectable
class ExtensionsBloc extends Bloc<ExtensionsEvent, ExtensionsState> {
  ExtensionsBloc(this._repo, SourceManager sources)
      : super(ExtensionsState(
          implementedSourceIds: sources.getSources().map((s) => s.id).toSet(),
        )) {
    on<ExtensionsFetched>(_onFetch, transformer: restartable());
    on<ExtensionsSearchChanged>(
      (e, emit) => emit(state.copyWith(query: e.query)),
    );
    on<ExtensionsLangChanged>(
      (e, emit) => emit(state.copyWith(langFilter: e.lang)),
    );
  }

  final ExtensionsIndexRepository _repo;

  Future<void> _onFetch(
    ExtensionsFetched event,
    Emitter<ExtensionsState> emit,
  ) async {
    emit(state.copyWith(loadStatus: const BlocStatus.loading()));
    try {
      final all = await _repo.fetchAll();
      emit(state.copyWith(
        loadStatus:
            all.isEmpty ? const BlocStatus.empty() : const BlocStatus.success(),
        all: all,
      ));
    } catch (e, st) {
      emit(state.copyWith(
        loadStatus: BlocStatus.failure(AppException.from(e, st)),
      ));
    }
  }
}
