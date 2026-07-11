import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:mihonx/core/core.dart';
import 'package:mihonx/core/di/di_container.dart';
import 'package:mihonx/core/routing/app_router.gr.dart';
import 'package:mihonx/core/utils/app_dates.dart';
import 'package:mihonx/features/history/domain/history_repository.dart';
import 'package:mihonx/features/history/presentation/bloc/history_bloc.dart';
import 'package:mihonx/features/history/presentation/bloc/history_event.dart';
import 'package:mihonx/features/history/presentation/bloc/history_state.dart';
import 'package:mihonx/features/library/presentation/widgets/manga_cover.dart';

@RoutePage()
class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageLayoutBuilder(
      mobile: (context) => BlocProvider(
        create: (_) => getIt<HistoryBloc>()..add(const HistorySubscribed()),
        child: const _HistoryView(),
      ),
    );
  }
}

class _HistoryView extends StatelessWidget {
  const _HistoryView();

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppAppBar(
        title: 'nav.history',
        showDefaultBackButton: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined),
            onPressed: () =>
                context.read<HistoryBloc>().add(const HistoryCleared()),
          ),
        ],
      ),
      body: StatusBuilder<HistoryBloc, HistoryState>(
        statusSelector: (s) => s.loadStatus,
        emptyMessage: 'history.empty',
        onSuccess: (context) => const _HistoryList(),
      ),
    );
  }
}

/// Rows grouped under Mihon-style day headers (Today / Yesterday / date).
class _HistoryList extends StatelessWidget {
  const _HistoryList();

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
          radius: 4,
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
        onPressed: () =>
            context.read<HistoryBloc>().add(HistoryEntryRemoved(item.historyId)),
      ),
      onTap: () => context.router.push(ReaderRoute(chapterId: item.chapterId)),
    );
  }
}
