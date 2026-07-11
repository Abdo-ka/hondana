import 'package:injectable/injectable.dart';

import 'package:hondana/features/history/data/data_sources/history_local_datasource.dart';
import 'package:hondana/features/history/domain/entities/history_item.dart';
import 'package:hondana/features/history/domain/repositories/history_repository.dart';

/// Default [HistoryRepository] — delegates to the local (drift) data source.
/// Reading history is device-local, so there is no remote data source.
@LazySingleton(as: HistoryRepository)
class HistoryRepositoryImp implements HistoryRepository {
  HistoryRepositoryImp(this._local);

  final HistoryLocalDataSource _local;

  @override
  Future<void> upsert(int chapterId) => _local.upsert(chapterId);

  @override
  Stream<List<HistoryItem>> watchHistory() => _local.watchHistory();

  @override
  Future<void> remove(int historyId) => _local.remove(historyId);

  @override
  Future<void> clear() => _local.clear();
}
