import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:hondana/core/core.dart';
import 'package:hondana/core/routing/app_router.gr.dart';
import 'package:hondana/core/utils/app_dates.dart';
import 'package:hondana/features/downloads/presentation/widgets/chapter_download_button.dart';
import 'package:hondana/features/library/presentation/widgets/manga_cover.dart';
import 'package:hondana/features/updates/domain/entities/update_item.dart';
import 'package:hondana/features/updates/presentation/state/bloc/updates_bloc.dart';
import 'package:hondana/features/updates/presentation/state/bloc/updates_state.dart';

/// Updates feed rows grouped under Mihon-style day headers
/// (Today / Yesterday / date).
class UpdatesList extends StatelessWidget {
  const UpdatesList({super.key});

  /// Interleaves day-label strings before each run of same-day items, yielding
  /// a flat list of `String` headers and [UpdateItem] rows for the list view.
  static List<Object> _grouped(List<UpdateItem> items) {
    return items.fold(<Object>[], (acc, item) {
      final label = _dayLabel(item.dateUpload);
      final previous = acc.whereType<UpdateItem>().lastOrNull;
      if (previous == null || _dayLabel(previous.dateUpload) != label) {
        acc.add(label);
      }
      acc.add(item);
      return acc;
    });
  }

  static String _dayLabel(DateTime? date) => formatAppDate(date);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UpdatesBloc, UpdatesState>(
      buildWhen: (a, b) => a.items != b.items,
      builder: (context, state) {
        final rows = _grouped(state.items);
        return ListView.builder(
          itemCount: rows.length,
          itemBuilder: (context, index) => rows[index] is String
              ? _DayHeader(label: rows[index] as String)
              : _UpdateTile(item: rows[index] as UpdateItem),
        );
      },
    );
  }
}

/// A day-group header (Today / Yesterday / formatted date).
class _DayHeader extends StatelessWidget {
  const _DayHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 4.h),
      child: AppText.titleSmall(label),
    );
  }
}

/// A single update row: cover, manga title, chapter name, per-row download
/// button; taps open the chapter in the reader. Read chapters render muted.
class _UpdateTile extends StatelessWidget {
  const _UpdateTile({required this.item});

  final UpdateItem item;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: SizedBox(
        width: 40.w,
        height: 56.h,
        child: MangaCover(
          url: item.thumbnailUrl,
          sourceId: item.sourceId,
          radius: 4.r,
        ),
      ),
      title: AppText.bodyMedium(
        item.mangaTitle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        color: item.read ? context.colorScheme.onSurfaceVariant : null,
      ),
      subtitle: AppText.bodySmall(
        item.chapterName,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        color: context.colorScheme.onSurfaceVariant,
      ),
      trailing: ChapterDownloadButton(
        chapterId: item.chapterId,
        mangaId: item.mangaId,
        mangaTitle: item.mangaTitle,
        chapterName: item.chapterName,
      ),
      onTap: () => context.router.push(ReaderRoute(chapterId: item.chapterId)),
    );
  }
}
