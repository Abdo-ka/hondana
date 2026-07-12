import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:hondana/core/core.dart';
import 'package:hondana/features/updates/presentation/state/bloc/updates_bloc.dart';
import 'package:hondana/features/updates/presentation/state/bloc/updates_event.dart';
import 'package:hondana/features/updates/presentation/state/bloc/updates_state.dart';
import 'package:hondana/features/updates/presentation/widgets/updates_list.dart';

/// Mobile layout for the Updates tab: an app bar with a manual refresh,
/// pull-to-refresh, and the grouped updates feed.
class UpdatesPageMobile extends StatelessWidget {
  const UpdatesPageMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppAppBar(
        title: 'nav.updates',
        showDefaultBackButton: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                context.read<UpdatesBloc>().add(const UpdatesRefreshed()),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async =>
            context.read<UpdatesBloc>().add(const UpdatesRefreshed()),
        child: StatusBuilder<UpdatesBloc, UpdatesState>(
          statusSelector: (s) => s.loadStatus,
          emptyMessage: 'updates.empty',
          onSuccess: (context) => const UpdatesList(),
        ),
      ),
    );
  }
}
