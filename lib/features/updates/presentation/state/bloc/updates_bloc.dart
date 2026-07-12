import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'package:hondana/core/error/app_exception.dart';
import 'package:hondana/core/state/bloc_status.dart';
import 'package:hondana/services/library_update_service.dart';
import 'package:hondana/features/updates/domain/repositories/updates_repository.dart';
import 'package:hondana/features/updates/presentation/state/bloc/updates_event.dart';
import 'package:hondana/features/updates/presentation/state/bloc/updates_state.dart';

/// Drives the Updates feed: streams new chapters and triggers library syncs.
@injectable
class UpdatesBloc extends Bloc<UpdatesEvent, UpdatesState> {
  UpdatesBloc(this._repo, this._updater) : super(const UpdatesState()) {
    // restartable: a new subscription cancels the previous stream.
    on<UpdatesSubscribed>(_onSubscribe, transformer: restartable());
    // droppable: ignore refresh taps while one is already running.
    on<UpdatesRefreshed>(_onRefresh, transformer: droppable());
  }

  final UpdatesRepository _repo;
  final LibraryUpdateService _updater;

  /// Mirrors [UpdatesRepository.watchUpdates] into state, marking empty results.
  Future<void> _onSubscribe(UpdatesSubscribed e, Emitter<UpdatesState> emit) {
    return emit.forEach(
      _repo.watchUpdates(),
      onData: (items) => state.copyWith(
        loadStatus: items.isEmpty
            ? const BlocStatus.empty()
            : const BlocStatus.success(),
        items: items,
      ),
    );
  }

  /// Runs a full library update and reports its status; the stream then pushes
  /// any newly-fetched chapters on its own.
  Future<void> _onRefresh(
    UpdatesRefreshed e,
    Emitter<UpdatesState> emit,
  ) async {
    emit(state.copyWith(refreshStatus: const BlocStatus.loading()));
    try {
      await _updater.refreshAll();
      emit(state.copyWith(refreshStatus: const BlocStatus.success()));
    } catch (err, st) {
      emit(
        state.copyWith(
          refreshStatus: BlocStatus.failure(AppException.from(err, st)),
        ),
      );
    }
  }
}
