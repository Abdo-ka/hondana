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

  Future<void> createCategory(String name);

  Future<void> renameCategory(int id, String name);

  Future<void> deleteCategory(int id);

  /// Replaces the category assignments of the given manga.
  Future<void> setMangaCategories(List<int> mangaIds, List<int> categoryIds);
}
