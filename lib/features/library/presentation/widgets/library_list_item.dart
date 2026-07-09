import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:mihonx/core/extensions/context_ext.dart';
import 'package:mihonx/core/widgets/app_text.dart';
import 'package:mihonx/features/library/domain/library_manga.dart';
import 'package:mihonx/features/library/presentation/bloc/library_bloc.dart';
import 'package:mihonx/features/library/presentation/bloc/library_event.dart';
import 'package:mihonx/features/library/presentation/widgets/manga_cover.dart';
import 'package:mihonx/features/library/presentation/widgets/unread_badge.dart';

/// Compact list row: thumbnail + title + unread badge.
class LibraryListItem extends StatelessWidget {
  const LibraryListItem({required this.entry, required this.selected, super.key});

  final LibraryManga entry;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      selected: selected,
      selectedTileColor: context.colorScheme.primary.withValues(alpha: 0.12),
      leading: SizedBox(
        width: 40.w,
        height: 56.h,
        child: MangaCover(url: entry.manga.thumbnailUrl, radius: 4),
      ),
      title: AppText.bodyMedium(
        entry.manga.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: entry.unreadCount > 0
          ? UnreadBadge(count: entry.unreadCount)
          : null,
      onTap: () => _handleTap(context),
      onLongPress: () => context
          .read<LibraryBloc>()
          .add(LibraryItemSelectionToggled(entry.manga.id)),
    );
  }

  void _handleTap(BuildContext context) {
    final bloc = context.read<LibraryBloc>();
    if (bloc.state.isSelecting) {
      bloc.add(LibraryItemSelectionToggled(entry.manga.id));
    }
    // TODO: open manga details when Task #4 lands.
  }
}
