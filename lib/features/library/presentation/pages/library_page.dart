import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mihonx/core/core.dart';
import 'package:mihonx/core/di/di_container.dart';
import 'package:mihonx/features/library/presentation/bloc/library_bloc.dart';
import 'package:mihonx/features/library/presentation/bloc/library_event.dart';
import 'package:mihonx/features/library/presentation/bloc/library_state.dart';
import 'package:mihonx/features/library/presentation/widgets/library_body.dart';
import 'package:mihonx/features/library/presentation/widgets/library_options_sheet.dart';
import 'package:mihonx/features/library/presentation/widgets/library_selection_app_bar.dart';

@RoutePage()
class LibraryPage extends StatelessWidget {
  const LibraryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageLayoutBuilder(
      mobile: (context) => BlocProvider(
        create: (_) => getIt<LibraryBloc>()
          ..add(const LibraryCategoriesSubscribed())
          ..add(const LibrarySubscribed()),
        child: const _LibraryView(),
      ),
    );
  }
}

class _LibraryView extends StatelessWidget {
  const _LibraryView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LibraryBloc, LibraryState>(
      buildWhen: (a, b) =>
          a.isSelecting != b.isSelecting ||
          a.selectedIds.length != b.selectedIds.length,
      builder: (context, state) => AppScaffold(
        appBar: state.isSelecting
            ? LibrarySelectionAppBar(count: state.selectedIds.length)
            : AppAppBar(
                title: 'nav.library',
                showDefaultBackButton: false,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.tune),
                    onPressed: () => LibraryOptionsSheet.show(context),
                  ),
                ],
              ),
        body: const LibraryBody(),
      ),
    );
  }
}
