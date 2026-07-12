import 'package:injectable/injectable.dart';

import 'package:hondana/features/updates/data/data_sources/updates_local_datasource.dart';
import 'package:hondana/features/updates/domain/entities/update_item.dart';
import 'package:hondana/features/updates/domain/repositories/updates_repository.dart';

/// Default [UpdatesRepository] — delegates to the local (drift) data source.
/// The Updates feed is derived from device-local data, so there is no remote
/// data source.
@LazySingleton(as: UpdatesRepository)
class UpdatesRepositoryImp implements UpdatesRepository {
  UpdatesRepositoryImp(this._local);

  final UpdatesLocalDataSource _local;

  @override
  Stream<List<UpdateItem>> watchUpdates() => _local.watchUpdates();
}
