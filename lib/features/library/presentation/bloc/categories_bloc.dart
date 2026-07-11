import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart' show immutable;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'package:hondana/core/state/bloc_status.dart';
import 'package:hondana/features/library/domain/category.dart';
import 'package:hondana/features/library/domain/library_repository.dart';

/// Base type for [CategoriesBloc] events.
sealed class CategoriesEvent {
  const CategoriesEvent();
}

/// Start watching the persisted category list; re-emits on every change.
final class CategoriesSubscribed extends CategoriesEvent {
  const CategoriesSubscribed();
}

/// Create a new category with the given (untrimmed) name.
final class CategoryCreated extends CategoriesEvent {
  const CategoryCreated(this.name);
  final String name;
}

/// Rename the category [id] to a new (untrimmed) name.
final class CategoryRenamed extends CategoriesEvent {
  const CategoryRenamed(this.id, this.name);
  final int id;
  final String name;
}

/// Delete the category [id].
final class CategoryDeleted extends CategoriesEvent {
  const CategoryDeleted(this.id);
  final int id;
}

/// State of the category-management screen: the load status and the list.
@immutable
class CategoriesState extends Equatable {
  const CategoriesState({
    this.loadStatus = const BlocStatus.initial(),
    this.categories = const [],
  });

  /// Status of the initial subscription; [BlocStatus.empty] when there are none.
  final BlocStatus loadStatus;
  final List<Category> categories;

  @override
  List<Object?> get props => [loadStatus, categories];
}

/// Manages the user's manga categories (create / rename / delete / list).
///
/// Mutations are fire-and-forget: they write through the repository, whose
/// [LibraryRepository.watchCategories] stream then re-emits the fresh list.
@injectable
class CategoriesBloc extends Bloc<CategoriesEvent, CategoriesState> {
  CategoriesBloc(this._repo) : super(const CategoriesState()) {
    on<CategoriesSubscribed>(_onSubscribe, transformer: restartable());
    on<CategoryCreated>((e, emit) => _repo.createCategory(e.name.trim()));
    on<CategoryRenamed>((e, emit) => _repo.renameCategory(e.id, e.name.trim()));
    on<CategoryDeleted>((e, emit) => _repo.deleteCategory(e.id));
  }

  final LibraryRepository _repo;

  /// Mirrors the category stream into state, marking [BlocStatus.empty] when
  /// there are no categories so the UI can show an empty placeholder.
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
