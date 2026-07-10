import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:mihonx/core/extensions/context_ext.dart';
import 'package:mihonx/core/widgets/app_text.dart';
import 'package:mihonx/features/library/domain/library_preferences.dart';
import 'package:mihonx/features/library/presentation/bloc/library_bloc.dart';
import 'package:mihonx/features/library/presentation/bloc/library_event.dart';
import 'package:mihonx/features/library/presentation/bloc/library_state.dart';

/// Mihon-style library options: a bottom sheet with Filter / Sort / Display
/// tabs. Filters are tri-state (ignore → include → exclude).
class LibraryOptionsSheet extends StatelessWidget {
  const LibraryOptionsSheet({super.key});

  static Future<void> show(BuildContext context) {
    final bloc = context.read<LibraryBloc>();
    return showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (_) => BlocProvider.value(
        value: bloc,
        child: const LibraryOptionsSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const TabBar(
              tabs: [
                Tab(child: AppText.labelLarge('library.tab_filter')),
                Tab(child: AppText.labelLarge('library.tab_sort')),
                Tab(child: AppText.labelLarge('library.tab_display')),
              ],
            ),
            SizedBox(
              height: 260.h,
              child: const TabBarView(
                children: [_FilterTab(), _SortTab(), _DisplayTab()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterTab extends StatelessWidget {
  const _FilterTab();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LibraryBloc, LibraryState>(
      buildWhen: (a, b) =>
          a.filterUnread != b.filterUnread ||
          a.filterCompleted != b.filterCompleted ||
          a.filterDownloaded != b.filterDownloaded,
      builder: (context, state) => ListView(
        children: [
          _TriFilterTile(
            label: 'library.filter_downloaded',
            value: state.filterDownloaded,
            onTap: () => context
                .read<LibraryBloc>()
                .add(const LibraryFilterCycled(LibraryFilterKind.downloaded)),
          ),
          _TriFilterTile(
            label: 'library.filter_unread',
            value: state.filterUnread,
            onTap: () => context
                .read<LibraryBloc>()
                .add(const LibraryFilterCycled(LibraryFilterKind.unread)),
          ),
          _TriFilterTile(
            label: 'library.filter_completed',
            value: state.filterCompleted,
            onTap: () => context
                .read<LibraryBloc>()
                .add(const LibraryFilterCycled(LibraryFilterKind.completed)),
          ),
        ],
      ),
    );
  }
}

class _TriFilterTile extends StatelessWidget {
  const _TriFilterTile({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final TriFilter value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        switch (value) {
          TriFilter.ignore => Icons.check_box_outline_blank,
          TriFilter.include => Icons.check_box,
          TriFilter.exclude => Icons.indeterminate_check_box,
        },
        color: value == TriFilter.ignore
            ? context.colorScheme.onSurfaceVariant
            : context.colorScheme.primary,
      ),
      title: AppText.bodyMedium(label),
      onTap: onTap,
    );
  }
}

class _SortTab extends StatelessWidget {
  const _SortTab();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LibraryBloc, LibraryState>(
      buildWhen: (a, b) =>
          a.sortMode != b.sortMode || a.sortAscending != b.sortAscending,
      builder: (context, state) => ListView(
        children: LibrarySortMode.values
            .map(
              (m) => ListTile(
                leading: Icon(
                  state.sortMode == m
                      ? (state.sortAscending
                          ? Icons.arrow_upward
                          : Icons.arrow_downward)
                      : null,
                  color: context.colorScheme.primary,
                ),
                title: AppText.bodyMedium('library.sort_${m.name}'),
                onTap: () => context.read<LibraryBloc>().add(
                      LibrarySortChanged(
                        m,
                        state.sortMode == m ? !state.sortAscending : true,
                      ),
                    ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _DisplayTab extends StatelessWidget {
  const _DisplayTab();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LibraryBloc, LibraryState>(
      buildWhen: (a, b) => a.displayMode != b.displayMode,
      builder: (context, state) => ListView(
        children: LibraryDisplayMode.values
            .map(
              (m) => ListTile(
                leading: Icon(
                  state.displayMode == m
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  color: state.displayMode == m
                      ? context.colorScheme.primary
                      : context.colorScheme.onSurfaceVariant,
                ),
                title: AppText.bodyMedium('library.display_${m.name}'),
                onTap: () => context
                    .read<LibraryBloc>()
                    .add(LibraryDisplayModeChanged(m)),
              ),
            )
            .toList(),
      ),
    );
  }
}
