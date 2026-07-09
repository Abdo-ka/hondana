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

/// Cover-forward grid cell with an overlaid title, unread badge, and selection
/// highlight. Long-press starts selection; tap toggles while selecting.
class LibraryGridItem extends StatelessWidget {
  const LibraryGridItem({required this.entry, required this.selected, super.key});

  final LibraryManga entry;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _handleTap(context),
      onLongPress: () => context
          .read<LibraryBloc>()
          .add(LibraryItemSelectionToggled(entry.manga.id)),
      child: Stack(
        fit: StackFit.expand,
        children: [
          MangaCover(url: entry.manga.thumbnailUrl),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(6.w, 14.h, 6.w, 6.h),
              decoration: const BoxDecoration(
                // ponytail: scrim + white text is theme-invariant over covers.
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black87, Colors.transparent],
                ),
              ),
              child: AppText.labelMedium(
                entry.manga.title,
                color: Colors.white,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          if (entry.unreadCount > 0)
            Positioned(
              top: 4.h,
              left: 4.w,
              child: UnreadBadge(count: entry.unreadCount),
            ),
          if (selected)
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: context.colorScheme.primary.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Icon(Icons.check_circle,
                    color: context.colorScheme.onPrimary),
              ),
            ),
        ],
      ),
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
