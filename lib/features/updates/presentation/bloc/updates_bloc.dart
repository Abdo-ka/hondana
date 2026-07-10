import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'package:mihonx/core/error/app_exception.dart';
import 'package:mihonx/core/state/bloc_status.dart';
import 'package:mihonx/features/library/data/library_update_service.dart';
import 'package:mihonx/features/updates/domain/updates_repository.dart';
import 'package:mihonx/features/updates/presentation/bloc/updates_event.dart';
import 'package:mihonx/features/updates/presentation/bloc/updates_state.dart';

@injectable
class UpdatesBloc extends Bloc<UpdatesEvent, UpdatesState> {
  UpdatesBloc(this._repo, this._updater) : super(const UpdatesState()) {
    on<UpdatesSubscribed>(_onSubscribe, transformer: restartable());
    on<UpdatesRefreshed>(_onRefresh, transformer: droppable());
  }

  final UpdatesRepository _repo;
  final LibraryUpdateService _updater;

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

  Future<void> _onRefresh(UpdatesRefreshed e, Emitter<UpdatesState> emit) async {
    emit(state.copyWith(refreshStatus: const BlocStatus.loading()));
    try {
      await _updater.refreshAll();
      emit(state.copyWith(refreshStatus: const BlocStatus.success()));
    } catch (err, st) {
      emit(state.copyWith(
        refreshStatus: BlocStatus.failure(AppException.from(err, st)),
      ));
    }
  }
}
