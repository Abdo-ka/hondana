import 'package:hondana/features/updates/domain/entities/update_item.dart';

/// Read-side source for the Updates feed — implemented in the data layer by
/// `UpdatesRepositoryImp`.
abstract interface class UpdatesRepository {
  /// Emits recent chapters of favorited manga, newest first.
  Stream<List<UpdateItem>> watchUpdates();
}
