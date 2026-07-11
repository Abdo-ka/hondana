import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:hondana/core/core.dart';
import 'package:hondana/core/di/di_container.dart';
import 'package:hondana/features/downloads/presentation/bloc/downloads_bloc.dart';
import 'package:hondana/features/downloads/presentation/bloc/downloads_event.dart';
import 'package:hondana/features/downloads/presentation/bloc/downloads_state.dart';

/// Downloads screen — the reorderable download queue with a pause/resume FAB
/// and per-tile cancel/retry (Mihon's Download queue page).
@RoutePage()
class DownloadsPage extends StatelessWidget {
  const DownloadsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageLayoutBuilder(
      mobile: (context) => BlocProvider.value(
        value: getIt<DownloadsBloc>(),
        child: const _DownloadsView(),
      ),
    );
  }
}

/// Overflow-menu actions for the whole queue.
enum _QueueAction { cancelAll, clearFinished }

class _DownloadsView extends StatelessWidget {
  const _DownloadsView();

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppAppBar(
        title: 'downloads.title',
        actions: [
          PopupMenuButton<_QueueAction>(
            onSelected: (action) =>
                context.read<DownloadsBloc>().add(switch (action) {
                  _QueueAction.cancelAll => const DownloadsCancelAll(),
                  _QueueAction.clearFinished => const DownloadsClearFinished(),
                }),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: _QueueAction.cancelAll,
                child: Text('downloads.cancel_all'.tr()),
              ),
              PopupMenuItem(
                value: _QueueAction.clearFinished,
                child: Text('downloads.clear_finished'.tr()),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: const _PauseResumeFab(),
      body: BlocBuilder<DownloadsBloc, DownloadsState>(
        buildWhen: (a, b) => a.queue != b.queue,
        builder: (context, state) => state.queue.isEmpty
            ? const AppEmptyIndicator(
                message: 'downloads.empty',
                icon: Icons.download_outlined,
              )
            // Drag to reorder — the queue downloads top to bottom (Mihon).
            : ReorderableListView.builder(
                buildDefaultDragHandles: false,
                itemCount: state.queue.length,
                onReorderItem: (oldIndex, newIndex) => context
                    .read<DownloadsBloc>()
                    .add(DownloadsReordered(oldIndex, newIndex)),
                itemBuilder: (context, index) => _DownloadTile(
                  key: ValueKey(state.queue[index].chapterId),
                  task: state.queue[index],
                  index: index,
                ),
              ),
      ),
    );
  }
}

/// Mihon's queue FAB: pause while anything is active, resume while paused.
class _PauseResumeFab extends StatelessWidget {
  const _PauseResumeFab();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DownloadsBloc, DownloadsState>(
      buildWhen: (a, b) => a.paused != b.paused || a.hasActive != b.hasActive,
      builder: (context, state) {
        if (!state.hasActive && !state.paused) return const SizedBox.shrink();
        return FloatingActionButton.extended(
          onPressed: () =>
              context.read<DownloadsBloc>().add(const DownloadsPauseToggled()),
          icon: Icon(state.paused ? Icons.play_arrow : Icons.pause),
          label: AppText.labelLarge(
            state.paused ? 'downloads.resume' : 'downloads.pause',
          ),
        );
      },
    );
  }
}

/// One queue row: drag handle (active only), title/chapter, a progress bar
/// while downloading else a status line, and a cancel/retry trailing button.
class _DownloadTile extends StatelessWidget {
  const _DownloadTile({required this.task, required this.index, super.key});

  final DownloadTask task;
  final int index;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: task.isActive
          ? ReorderableDragStartListener(
              index: index,
              child: const Icon(Icons.drag_handle),
            )
          : null,
      title: AppText.bodyMedium(
        task.mangaTitle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText.bodySmall(
            task.chapterName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            color: context.colorScheme.onSurfaceVariant,
          ),
          if (task.status == DownloadTaskStatus.downloading) ...[
            SizedBox(height: 4.h),
            // Determinate progress bar — not a banned loading spinner.
            LinearProgressIndicator(value: task.progress),
          ] else
            AppText.labelSmall(
              task.status == DownloadTaskStatus.failed && task.error != null
                  ? '${'downloads.status_failed'.tr()} · ${task.error}'
                  : 'downloads.status_${task.status.name}',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              color: task.status == DownloadTaskStatus.failed
                  ? context.colorScheme.error
                  : context.colorScheme.onSurfaceVariant,
            ),
        ],
      ),
      trailing: switch (task.status) {
        DownloadTaskStatus.queued ||
        DownloadTaskStatus.downloading => IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.read<DownloadsBloc>().add(
            DownloadCancelRequested(task.chapterId),
          ),
        ),
        DownloadTaskStatus.failed => IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () => context.read<DownloadsBloc>().add(
            DownloadRetryRequested(task.chapterId),
          ),
        ),
        _ => null,
      },
    );
  }
}
