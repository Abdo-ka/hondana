import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import 'package:hondana/core/state/bloc_status.dart';
import 'package:hondana/features/history/domain/history_repository.dart';

/// Immutable state for the History page: load status plus the current entries.
@immutable
class HistoryState extends Equatable {
  const HistoryState({
    this.loadStatus = const BlocStatus.initial(),
    this.items = const [],
  });

  /// Drives the [StatusBuilder]: initial / empty / success for the feed.
  final BlocStatus loadStatus;

  /// History entries, newest first.
  final List<HistoryItem> items;

  @override
  List<Object?> get props => [loadStatus, items];
}
