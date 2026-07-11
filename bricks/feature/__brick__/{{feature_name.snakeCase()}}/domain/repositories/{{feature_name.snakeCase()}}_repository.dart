import 'package:hondana/features/{{feature_name.snakeCase()}}/domain/entities/{{feature_name.snakeCase()}}_entity.dart';

/// Contract for the {{feature_name.titleCase()}} feature's data access.
///
/// Implemented in the data layer by `{{feature_name.pascalCase()}}RepositoryImp`,
/// which delegates to the local and remote data sources.
abstract class {{feature_name.pascalCase()}}Repository {
  /// Loads the {{feature_name.titleCase()}} entities.
  Future<List<{{feature_name.pascalCase()}}Entity>> load{{feature_name.pascalCase()}}();
}
