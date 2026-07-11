import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:hondana/core/core.dart';
import 'package:hondana/features/history/presentation/state/bloc/history_bloc.dart';
import 'package:hondana/features/history/presentation/state/bloc/history_event.dart';
import 'package:hondana/features/history/presentation/state/bloc/history_state.dart';
import 'package:hondana/features/history/presentation/widgets/history_list.dart';

/// Mobile layout for the History tab: an app bar with a "clear all" action and
/// the grouped history feed (load/empty/failure driven by [StatusBuilder]).
class HistoryPageMobile extends StatelessWidget {
  const HistoryPageMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppAppBar(
        title: 'nav.history',
        showDefaultBackButton: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined),
            onPressed: () =>
                context.read<HistoryBloc>().add(const HistoryCleared()),
          ),
        ],
      ),
      body: StatusBuilder<HistoryBloc, HistoryState>(
        statusSelector: (s) => s.loadStatus,
        emptyMessage: 'history.empty',
        onSuccess: (context) => const HistoryList(),
      ),
    );
  }
}
