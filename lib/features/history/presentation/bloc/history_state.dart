import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import 'package:mihonx/core/state/bloc_status.dart';
import 'package:mihonx/features/history/domain/history_repository.dart';

@immutable
class HistoryState extends Equatable {
  const HistoryState({
    this.loadStatus = const BlocStatus.initial(),
    this.items = const [],
  });

  final BlocStatus loadStatus;
  final List<HistoryItem> items;

  @override
  List<Object?> get props => [loadStatus, items];
}
