import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'package:hondana/core/core.dart';
import 'package:hondana/features/{{feature_name.snakeCase()}}/domain/repositories/{{feature_name.snakeCase()}}_repository.dart';
import 'package:hondana/features/{{feature_name.snakeCase()}}/presentation/state/bloc/{{feature_name.snakeCase()}}_event.dart';
import 'package:hondana/features/{{feature_name.snakeCase()}}/presentation/state/bloc/{{feature_name.snakeCase()}}_state.dart';

/// Drives the {{feature_name.titleCase()}} feature: loads data through
/// [{{feature_name.pascalCase()}}Repository] and exposes it as [{{feature_name.pascalCase()}}State].
@injectable
class {{feature_name.pascalCase()}}Bloc
    extends Bloc<{{feature_name.pascalCase()}}Event, {{feature_name.pascalCase()}}State> {
  {{feature_name.pascalCase()}}Bloc(this._repository)
    : super(const {{feature_name.pascalCase()}}State()) {
    on<{{feature_name.pascalCase()}}Started>(_onStarted);
  }

  final {{feature_name.pascalCase()}}Repository _repository;

  Future<void> _onStarted(
    {{feature_name.pascalCase()}}Started event,
    Emitter<{{feature_name.pascalCase()}}State> emit,
  ) async {
    emit(state.copyWith(loadStatus: const BlocStatus.loading()));
    try {
      final items = await _repository.load{{feature_name.pascalCase()}}();
      emit(
        state.copyWith(
          items: items,
          loadStatus: items.isEmpty
              ? const BlocStatus.empty()
              : const BlocStatus.success(),
        ),
      );
    } catch (err, st) {
      emit(
        state.copyWith(loadStatus: BlocStatus.failure(AppException.from(err, st))),
      );
    }
  }
}
