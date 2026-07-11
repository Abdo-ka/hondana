import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'package:hondana/core/state/bloc_status.dart';
import 'package:hondana/features/history/domain/history_repository.dart';
import 'package:hondana/features/history/presentation/bloc/history_event.dart';
import 'package:hondana/features/history/presentation/bloc/history_state.dart';

/// Drives the History page: subscribes to the repository stream and forwards
/// remove/clear intents.
@injectable
class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  HistoryBloc(this._repo) : super(const HistoryState()) {
    // restartable(): a new subscription cancels the previous stream watch.
    on<HistorySubscribed>(_onSubscribe, transformer: restartable());
    on<HistoryEntryRemoved>((e, emit) => _repo.remove(e.historyId));
    on<HistoryCleared>((e, emit) => _repo.clear());
  }

  final HistoryRepository _repo;

  /// Mirrors the repository stream into state, marking it empty vs. success.
  Future<void> _onSubscribe(HistorySubscribed e, Emitter<HistoryState> emit) {
    return emit.forEach(
      _repo.watchHistory(),
      onData: (items) => HistoryState(
        loadStatus: items.isEmpty
            ? const BlocStatus.empty()
            : const BlocStatus.success(),
        items: items,
      ),
    );
  }
}
