import 'package:injectable/injectable.dart';

import 'package:hondana/features/{{feature_name.snakeCase()}}/data/data_sources/{{feature_name.snakeCase()}}_local_datasource.dart';
import 'package:hondana/features/{{feature_name.snakeCase()}}/data/data_sources/{{feature_name.snakeCase()}}_remote_datasource.dart';
import 'package:hondana/features/{{feature_name.snakeCase()}}/domain/entities/{{feature_name.snakeCase()}}_entity.dart';
import 'package:hondana/features/{{feature_name.snakeCase()}}/domain/repositories/{{feature_name.snakeCase()}}_repository.dart';

/// Default [{{feature_name.pascalCase()}}Repository] — orchestrates the remote and
/// local data sources behind the domain contract.
@Injectable(as: {{feature_name.pascalCase()}}Repository)
class {{feature_name.pascalCase()}}RepositoryImp implements {{feature_name.pascalCase()}}Repository {
  {{feature_name.pascalCase()}}RepositoryImp({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  final {{feature_name.pascalCase()}}RemoteDataSource remoteDataSource;
  final {{feature_name.pascalCase()}}LocalDataSource localDataSource;

  @override
  Future<List<{{feature_name.pascalCase()}}Entity>> load{{feature_name.pascalCase()}}() =>
      remoteDataSource.fetch{{feature_name.pascalCase()}}();
}
