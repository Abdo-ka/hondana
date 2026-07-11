import 'package:injectable/injectable.dart';

import 'package:hondana/features/{{feature_name.snakeCase()}}/domain/entities/{{feature_name.snakeCase()}}_entity.dart';

/// Local data source for the {{feature_name.titleCase()}} feature (drift / preferences).
@injectable
class {{feature_name.pascalCase()}}LocalDataSource {
  const {{feature_name.pascalCase()}}LocalDataSource();

  /// Reads cached {{feature_name.titleCase()}} entities from local storage.
  Future<List<{{feature_name.pascalCase()}}Entity>> read{{feature_name.pascalCase()}}() async {
    // TODO: implement the local read.
    return const [];
  }
}
