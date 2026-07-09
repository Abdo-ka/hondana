import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:mihonx/core/state/status_builder.dart';
import 'package:mihonx/core/widgets/app_text.dart';
import 'package:mihonx/features/library/domain/library_preferences.dart';
import 'package:mihonx/features/library/presentation/bloc/library_bloc.dart';
import 'package:mihonx/features/library/presentation/bloc/library_event.dart';
import 'package:mihonx/features/library/presentation/bloc/library_state.dart';
import 'package:mihonx/features/library/presentation/widgets/library_grid_item.dart';
import 'package:mihonx/features/library/presentation/widgets/library_list_item.dart';

class LibraryBody extends StatelessWidget {
  const LibraryBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _CategoryTabs(),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async => context
                .read<LibraryBloc>()
                .add(const LibraryRefreshRequested()),
            child: StatusBuilder<LibraryBloc, LibraryState>(
              statusSelector: (s) => s.loadStatus,
              emptyMessage: 'library.empty',
              onSuccess: (context) => const _LibraryContent(),
            ),
          ),
        ),
      ],
    );
  }
}

class _CategoryTabs extends StatelessWidget {
  const _CategoryTabs();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LibraryBloc, LibraryState>(
      buildWhen: (a, b) =>
          a.categories != b.categories ||
          a.selectedCategoryId != b.selectedCategoryId,
      builder: (context, state) => state.categories.isEmpty
          ? const SizedBox.shrink()
          : SizedBox(
              height: 48.h,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: ChoiceChip(
                      label: const AppText.labelLarge('library.all'),
                      selected: state.selectedCategoryId == null,
                      onSelected: (_) => context
                          .read<LibraryBloc>()
                          .add(const LibraryCategorySelected(null)),
                    ),
                  ),
                  ...state.categories.map(
                    (c) => Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      child: ChoiceChip(
                        label: AppText.labelLarge(c.name),
                        selected: state.selectedCategoryId == c.id,
                        onSelected: (_) => context
                            .read<LibraryBloc>()
                            .add(LibraryCategorySelected(c.id)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _LibraryContent extends StatelessWidget {
  const _LibraryContent();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LibraryBloc, LibraryState>(
      buildWhen: (a, b) =>
          a.manga != b.manga ||
          a.displayMode != b.displayMode ||
          a.selectedIds != b.selectedIds,
      builder: (context, state) => state.displayMode == LibraryDisplayMode.list
          ? ListView.builder(
              itemCount: state.manga.length,
              itemBuilder: (context, index) => LibraryListItem(
                entry: state.manga[index],
                selected:
                    state.selectedIds.contains(state.manga[index].manga.id),
              ),
            )
          : GridView.builder(
              padding: EdgeInsets.all(8.w),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.62,
                crossAxisSpacing: 8.w,
                mainAxisSpacing: 8.w,
              ),
              itemCount: state.manga.length,
              itemBuilder: (context, index) => LibraryGridItem(
                entry: state.manga[index],
                selected:
                    state.selectedIds.contains(state.manga[index].manga.id),
              ),
            ),
    );
  }
}
