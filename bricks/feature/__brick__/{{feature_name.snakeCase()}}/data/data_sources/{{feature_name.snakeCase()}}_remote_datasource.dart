import 'package:injectable/injectable.dart';

import 'package:hondana/features/{{feature_name.snakeCase()}}/domain/entities/{{feature_name.snakeCase()}}_entity.dart';

/// Remote data source for the {{feature_name.titleCase()}} feature (network / sources).
@injectable
class {{feature_name.pascalCase()}}RemoteDataSource {
  const {{feature_name.pascalCase()}}RemoteDataSource();

  /// Fetches {{feature_name.titleCase()}} entities from the network.
  Future<List<{{feature_name.pascalCase()}}Entity>> fetch{{feature_name.pascalCase()}}() async {
    // TODO: implement the remote fetch.
    return const [];
  }
}
