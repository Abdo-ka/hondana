import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import 'package:hondana/core/state/bloc_status.dart';
import 'package:hondana/features/updates/domain/updates_repository.dart';

/// State for the Updates feed: the current items plus per-action statuses.
@immutable
class UpdatesState extends Equatable {
  const UpdatesState({
    this.loadStatus = const BlocStatus.initial(),
    this.refreshStatus = const BlocStatus.initial(),
    this.items = const [],
  });

  /// Status of the live stream subscription (drives empty/success UI).
  final BlocStatus loadStatus;

  /// Status of an in-flight manual refresh (library sync).
  final BlocStatus refreshStatus;

  /// The grouped-and-rendered update rows, newest first.
  final List<UpdateItem> items;

  UpdatesState copyWith({
    BlocStatus? loadStatus,
    BlocStatus? refreshStatus,
    List<UpdateItem>? items,
  }) => UpdatesState(
    loadStatus: loadStatus ?? this.loadStatus,
    refreshStatus: refreshStatus ?? this.refreshStatus,
    items: items ?? this.items,
  );

  @override
  List<Object?> get props => [loadStatus, refreshStatus, items];
}
