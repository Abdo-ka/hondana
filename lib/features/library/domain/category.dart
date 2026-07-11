import 'package:hondana/core/database/app_database.dart';

/// A user library category. Id 0 is reserved for the implicit "Default" bucket.
class Category {
  const Category({required this.id, required this.name, this.position = 0});

  final int id;
  final String name;

  /// Sort order in the category tabs; lower shows first.
  final int position;

  /// Maps a persisted [CategoryData] row to the domain entity.
  factory Category.fromData(CategoryData d) =>
      Category(id: d.id, name: d.name, position: d.position);
}
