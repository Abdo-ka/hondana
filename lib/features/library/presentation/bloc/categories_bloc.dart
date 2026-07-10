import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart' show immutable;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'package:mihonx/core/state/bloc_status.dart';
import 'package:mihonx/features/library/domain/category.dart';
import 'package:mihonx/features/library/domain/library_repository.dart';

sealed class CategoriesEvent {
  const CategoriesEvent();
}

final class CategoriesSubscribed extends CategoriesEvent {
  const CategoriesSubscribed();
}

final class CategoryCreated extends CategoriesEvent {
  const CategoryCreated(this.name);
  final String name;
}

final class CategoryRenamed extends CategoriesEvent {
  const CategoryRenamed(this.id, this.name);
  final int id;
  final String name;
}

final class CategoryDeleted extends CategoriesEvent {
  const CategoryDeleted(this.id);
  final int id;
}

@immutable
class CategoriesState extends Equatable {
  const CategoriesState({
    this.loadStatus = const BlocStatus.initial(),
    this.categories = const [],
  });

  final BlocStatus loadStatus;
  final List<Category> categories;

  @override
  List<Object?> get props => [loadStatus, categories];
}

@injectable
class CategoriesBloc extends Bloc<CategoriesEvent, CategoriesState> {
  CategoriesBloc(this._repo) : super(const CategoriesState()) {
    on<CategoriesSubscribed>(_onSubscribe, transformer: restartable());
    on<CategoryCreated>((e, emit) => _repo.createCategory(e.name.trim()));
    on<CategoryRenamed>((e, emit) => _repo.renameCategory(e.id, e.name.trim()));
    on<CategoryDeleted>((e, emit) => _repo.deleteCategory(e.id));
  }

  final LibraryRepository _repo;

  Future<void> _onSubscribe(
    CategoriesSubscribed e,
    Emitter<CategoriesState> emit,
  ) {
    return emit.forEach(
      _repo.watchCategories(),
      onData: (categories) => CategoriesState(
        loadStatus: categories.isEmpty
            ? const BlocStatus.empty()
            : const BlocStatus.success(),
        categories: categories,
      ),
    );
  }
}
