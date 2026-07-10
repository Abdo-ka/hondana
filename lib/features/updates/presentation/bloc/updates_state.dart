import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import 'package:mihonx/core/state/bloc_status.dart';
import 'package:mihonx/features/updates/domain/updates_repository.dart';

@immutable
class UpdatesState extends Equatable {
  const UpdatesState({
    this.loadStatus = const BlocStatus.initial(),
    this.refreshStatus = const BlocStatus.initial(),
    this.items = const [],
  });

  final BlocStatus loadStatus;
  final BlocStatus refreshStatus;
  final List<UpdateItem> items;

  UpdatesState copyWith({
    BlocStatus? loadStatus,
    BlocStatus? refreshStatus,
    List<UpdateItem>? items,
  }) =>
      UpdatesState(
        loadStatus: loadStatus ?? this.loadStatus,
        refreshStatus: refreshStatus ?? this.refreshStatus,
        items: items ?? this.items,
      );

  @override
  List<Object?> get props => [loadStatus, refreshStatus, items];
}
