import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:hondana/core/core.dart';
import 'package:hondana/core/routing/app_router.gr.dart';
import 'package:hondana/core/utils/app_dates.dart';
import 'package:hondana/features/history/domain/entities/history_item.dart';
import 'package:hondana/features/history/presentation/state/bloc/history_bloc.dart';
import 'package:hondana/features/history/presentation/state/bloc/history_event.dart';
import 'package:hondana/features/history/presentation/state/bloc/history_state.dart';
import 'package:hondana/features/library/presentation/widgets/manga_cover.dart';

/// Reading-history rows grouped under Mihon-style day headers
/// (Today / Yesterday / date).
class HistoryList extends StatelessWidget {
  const HistoryList({super.key});

  /// Interleaves day-header strings between [HistoryItem]s whenever the day
  /// changes, producing a flat `[String, HistoryItem, HistoryItem, String, …]`
  /// list for a single [ListView].
  static List<Object> _grouped(List<HistoryItem> items) {
    return items.fold(<Object>[], (acc, item) {
      final label = _dayLabel(item.lastRead);
      final previous = acc.whereType<HistoryItem>().lastOrNull;
      if (previous == null || _dayLabel(previous.lastRead) != label) {
        acc.add(label);
      }
      acc.add(item);
      return acc;
    });
  }

  static String _dayLabel(DateTime? date) =>
      date == null ? '' : formatAppDate(date);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HistoryBloc, HistoryState>(
      buildWhen: (a, b) => a.items != b.items,
      builder: (context, state) {
        final rows = _grouped(state.items);
        return ListView.builder(
          itemCount: rows.length,
          itemBuilder: (context, index) => rows[index] is String
              ? Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 4.h),
                  child: AppText.titleSmall(rows[index] as String),
                )
              : _HistoryTile(item: rows[index] as HistoryItem),
        );
      },
    );
  }
}

/// A single history row: cover, manga title, chapter name, delete action; taps
/// resume reading the chapter.
class _HistoryTile extends StatelessWidget {
  const _HistoryTile({required this.item});

  final HistoryItem item;

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
      ),
      subtitle: AppText.bodySmall(
        item.chapterName,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline),
        onPressed: () => context.read<HistoryBloc>().add(
          HistoryEntryRemoved(item.historyId),
        ),
      ),
      onTap: () => context.router.push(ReaderRoute(chapterId: item.chapterId)),
    );
  }
}
