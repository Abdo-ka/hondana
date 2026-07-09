import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:mihonx/core/widgets/app_text.dart';
import 'package:mihonx/features/library/domain/library_preferences.dart';
import 'package:mihonx/features/library/presentation/bloc/library_bloc.dart';
import 'package:mihonx/features/library/presentation/bloc/library_event.dart';
import 'package:mihonx/features/library/presentation/bloc/library_state.dart';

/// Bottom sheet for display mode + sort. Carries the [LibraryBloc] across the
/// modal route via `BlocProvider.value`.
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
    return BlocBuilder<LibraryBloc, LibraryState>(
      buildWhen: (a, b) =>
          a.displayMode != b.displayMode ||
          a.sortMode != b.sortMode ||
          a.sortAscending != b.sortAscending,
      builder: (context, state) => SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppText.titleMedium('library.display'),
              SizedBox(height: 8.h),
              Wrap(
                spacing: 8.w,
                children: LibraryDisplayMode.values
                    .map((m) => ChoiceChip(
                          label: AppText.labelLarge('library.display_${m.name}'),
                          selected: state.displayMode == m,
                          onSelected: (_) => context
                              .read<LibraryBloc>()
                              .add(LibraryDisplayModeChanged(m)),
                        ))
                    .toList(),
              ),
              SizedBox(height: 16.h),
              const AppText.titleMedium('library.sort'),
              SizedBox(height: 4.h),
              ...LibrarySortMode.values.map(
                (m) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    state.sortMode == m
                        ? (state.sortAscending
                            ? Icons.arrow_upward
                            : Icons.arrow_downward)
                        : Icons.remove,
                    color: state.sortMode == m
                        ? Theme.of(context).colorScheme.primary
                        : Colors.transparent,
                  ),
                  title: AppText.bodyMedium('library.sort_${m.name}'),
                  onTap: () => context.read<LibraryBloc>().add(
                        LibrarySortChanged(
                          m,
                          state.sortMode == m ? !state.sortAscending : true,
                        ),
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
