import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mihonx/core/widgets/app_text.dart';
import 'package:mihonx/features/library/presentation/bloc/library_bloc.dart';
import 'package:mihonx/features/library/presentation/bloc/library_event.dart';

/// Contextual app bar shown while items are selected.
class LibrarySelectionAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const LibrarySelectionAppBar({required this.count, super.key});

  final int count;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.close),
        onPressed: () =>
            context.read<LibraryBloc>().add(const LibrarySelectionCleared()),
      ),
      title: AppText.titleLarge('$count'),
      actions: [
        IconButton(
          tooltip: 'library.select_all'.tr(),
          icon: const Icon(Icons.select_all),
          onPressed: () =>
              context.read<LibraryBloc>().add(const LibrarySelectAllToggled()),
        ),
        IconButton(
          tooltip: 'library.mark_read'.tr(),
          icon: const Icon(Icons.done_all),
          onPressed: () => context
              .read<LibraryBloc>()
              .add(const LibrarySelectedMarkedRead(true)),
        ),
        IconButton(
          tooltip: 'library.mark_unread'.tr(),
          icon: const Icon(Icons.remove_done),
          onPressed: () => context
              .read<LibraryBloc>()
              .add(const LibrarySelectedMarkedRead(false)),
        ),
        IconButton(
          tooltip: 'library.remove'.tr(),
          icon: const Icon(Icons.delete_outline),
          onPressed: () =>
              context.read<LibraryBloc>().add(const LibrarySelectedRemoved()),
        ),
      ],
    );
  }
}
