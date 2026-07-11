import 'package:hondana/features/library/domain/category.dart';
import 'package:hondana/features/library/domain/library_manga.dart';

/// Reactive access to the persisted library. Streams update live as the DB
/// changes (drift `.watch()`), so mutations reflect without manual reloads.
abstract interface class LibraryRepository {
  /// Favorited manga, optionally scoped to [categoryId] (null = all).
  Stream<List<LibraryManga>> watchLibrary({int? categoryId});

  /// User categories, ordered by [Category.position].
  Stream<List<Category>> watchCategories();

  /// Number of favorited manga — used to gate empty-library UI.
  Future<int> favoriteCount();

  /// Removes from library (sets favorite = false; non-destructive).
  Future<void> removeFromLibrary(List<int> mangaIds);

  /// Marks every chapter of the given manga read/unread.
  Future<void> setRead(List<int> mangaIds, bool read);

  /// Adds a category, placing it after the current last one.
  Future<void> createCategory(String name);

  Future<void> renameCategory(int id, String name);

  Future<void> deleteCategory(int id);

  /// Replaces the category assignments of the given manga.
  Future<void> setMangaCategories(List<int> mangaIds, List<int> categoryIds);
}
