import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:hondana/core/core.dart';
import 'package:hondana/core/di/di_container.dart';
import 'package:hondana/core/routing/app_router.gr.dart';
import 'package:hondana/core/utils/app_dates.dart';
import 'package:hondana/features/downloads/presentation/bloc/downloads_bloc.dart';
import 'package:hondana/features/downloads/presentation/widgets/chapter_download_button.dart';
import 'package:hondana/features/library/presentation/widgets/manga_cover.dart';
import 'package:hondana/features/updates/domain/updates_repository.dart';
import 'package:hondana/features/updates/presentation/bloc/updates_bloc.dart';
import 'package:hondana/features/updates/presentation/bloc/updates_event.dart';
import 'package:hondana/features/updates/presentation/bloc/updates_state.dart';

/// The Updates tab: recent chapters across the user's favorited library.
///
/// Wires up the [UpdatesBloc] (subscribing on mount) alongside the shared
/// [DownloadsBloc] used by per-row download buttons.
@RoutePage()
class UpdatesPage extends StatelessWidget {
  const UpdatesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageLayoutBuilder(
      mobile: (context) => MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => getIt<UpdatesBloc>()..add(const UpdatesSubscribed()),
          ),
          BlocProvider.value(value: getIt<DownloadsBloc>()),
        ],
        child: const _UpdatesView(),
      ),
    );
  }
}

class _UpdatesView extends StatelessWidget {
  const _UpdatesView();

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppAppBar(
        title: 'nav.updates',
        showDefaultBackButton: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                context.read<UpdatesBloc>().add(const UpdatesRefreshed()),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async =>
            context.read<UpdatesBloc>().add(const UpdatesRefreshed()),
        child: StatusBuilder<UpdatesBloc, UpdatesState>(
          statusSelector: (s) => s.loadStatus,
          emptyMessage: 'updates.empty',
          onSuccess: (context) => const _UpdatesList(),
        ),
      ),
    );
  }
}

/// Rows grouped under Mihon-style day headers (Today / Yesterday / date).
class _UpdatesList extends StatelessWidget {
  const _UpdatesList();

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
          radius: 4,
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
