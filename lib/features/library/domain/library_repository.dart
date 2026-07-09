import 'package:mihonx/features/library/domain/category.dart';
import 'package:mihonx/features/library/domain/library_manga.dart';

/// Reactive access to the persisted library. Streams update live as the DB
/// changes (drift `.watch()`), so mutations reflect without manual reloads.
abstract interface class LibraryRepository {
  /// Favorited manga, optionally scoped to [categoryId] (null = all).
  Stream<List<LibraryManga>> watchLibrary({int? categoryId});

  Stream<List<Category>> watchCategories();

  Future<int> favoriteCount();

  /// Removes from library (sets favorite = false; non-destructive).
  Future<void> removeFromLibrary(List<int> mangaIds);

  /// Marks every chapter of the given manga read/unread.
  Future<void> setRead(List<int> mangaIds, bool read);

  /// Dev-only: inserts sample favorites when the library is empty so the UI is
  /// demoable before Browse/add-flow lands. Remove once real adds work.
  Future<void> seedDevDataIfEmpty();
}
