import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'package:mihonx/core/state/bloc_status.dart';
import 'package:mihonx/features/history/domain/history_repository.dart';
import 'package:mihonx/features/history/presentation/bloc/history_event.dart';
import 'package:mihonx/features/history/presentation/bloc/history_state.dart';

@injectable
class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  HistoryBloc(this._repo) : super(const HistoryState()) {
    on<HistorySubscribed>(_onSubscribe, transformer: restartable());
    on<HistoryEntryRemoved>((e, emit) => _repo.remove(e.historyId));
    on<HistoryCleared>((e, emit) => _repo.clear());
  }

  final HistoryRepository _repo;

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
