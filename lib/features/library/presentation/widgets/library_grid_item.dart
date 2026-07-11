import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:hondana/core/extensions/context_ext.dart';
import 'package:hondana/core/routing/app_router.gr.dart';
import 'package:hondana/core/widgets/app_text.dart';
import 'package:hondana/features/library/domain/library_manga.dart';
import 'package:hondana/features/library/domain/library_preferences.dart';
import 'package:hondana/features/library/presentation/bloc/library_bloc.dart';
import 'package:hondana/features/library/presentation/bloc/library_event.dart';
import 'package:hondana/features/library/presentation/widgets/manga_cover.dart';
import 'package:hondana/features/library/presentation/widgets/unread_badge.dart';

/// Library grid cell, Mihon layouts:
/// - compact grid: title overlaid on a bottom gradient scrim
/// - comfortable grid: title on two lines below the cover
/// Badges (downloads + unread) joined at the cover's top-start corner;
/// selection tints the cover and outlines it in primary.
class LibraryGridItem extends StatelessWidget {
  const LibraryGridItem({
    required this.entry,
    required this.selected,
    required this.mode,
    super.key,
  });

  final LibraryManga entry;
  final bool selected;
  final LibraryDisplayMode mode;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _handleTap(context),
      onLongPress: () => context.read<LibraryBloc>().add(
        LibraryItemSelectionToggled(entry.manga.id),
      ),
      child: mode == LibraryDisplayMode.comfortableGrid
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _Cover(entry: entry, selected: selected),
                ),
                SizedBox(height: 4.h),
                AppText.labelMedium(
                  entry.manga.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            )
          : _Cover(
              entry: entry,
              selected: selected,
              overlayTitle: entry.manga.title,
            ),
    );
  }

  void _handleTap(BuildContext context) {
    final bloc = context.read<LibraryBloc>();
    if (bloc.state.isSelecting) {
      bloc.add(LibraryItemSelectionToggled(entry.manga.id));
      return;
    }
    context.router.push(
      MangaDetailsRoute(
        sourceId: entry.manga.source,
        initial: entry.manga.toSManga(),
      ),
    );
  }
}

/// Cover artwork with badges, optional overlaid title, and a selection tint.
class _Cover extends StatelessWidget {
  const _Cover({
    required this.entry,
    required this.selected,
    this.overlayTitle,
  });

  final LibraryManga entry;
  final bool selected;
  final String? overlayTitle;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        MangaCover(
          url: entry.manga.thumbnailUrl,
          sourceId: entry.manga.source,
          radius: 8,
        ),
        if (overlayTitle != null)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(8.w, 16.h, 8.w, 8.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(8.r),
                ),
                gradient: const LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  // Cover scrim is theme-invariant (over artwork).
                  colors: [Colors.black87, Colors.transparent],
                ),
              ),
              child: AppText.labelMedium(
                overlayTitle!,
                color: Colors.white,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        PositionedDirectional(
          top: 4.h,
          start: 4.w,
          child: CoverBadges(
            unread: entry.unreadCount,
            downloads: entry.downloadCount,
          ),
        ),
        if (selected)
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: context.colorScheme.primary.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                  color: context.colorScheme.primary,
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.check_circle,
                color: context.colorScheme.onPrimary,
              ),
            ),
          ),
      ],
    );
  }
}
