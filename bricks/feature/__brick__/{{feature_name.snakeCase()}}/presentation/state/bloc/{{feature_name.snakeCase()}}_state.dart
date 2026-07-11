import 'package:equatable/equatable.dart';

import 'package:hondana/core/core.dart';
import 'package:hondana/features/{{feature_name.snakeCase()}}/domain/entities/{{feature_name.snakeCase()}}_entity.dart';

/// Immutable state for the {{feature_name.titleCase()}} feature.
///
/// Each async action gets its own [BlocStatus] field (here, [loadStatus]).
class {{feature_name.pascalCase()}}State extends Equatable {
  const {{feature_name.pascalCase()}}State({
    this.items = const [],
    this.loadStatus = const BlocStatus.initial(),
  });

  /// The loaded {{feature_name.titleCase()}} entities.
  final List<{{feature_name.pascalCase()}}Entity> items;

  /// Status of the load action.
  final BlocStatus loadStatus;

  {{feature_name.pascalCase()}}State copyWith({
    List<{{feature_name.pascalCase()}}Entity>? items,
    BlocStatus? loadStatus,
  }) {
    return {{feature_name.pascalCase()}}State(
      items: items ?? this.items,
      loadStatus: loadStatus ?? this.loadStatus,
    );
  }

  @override
  List<Object?> get props => [items, loadStatus];
}
