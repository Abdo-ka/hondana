import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:mihonx/core/core.dart';
import 'package:mihonx/core/di/di_container.dart';
import 'package:mihonx/features/downloads/presentation/bloc/downloads_bloc.dart';
import 'package:mihonx/features/downloads/presentation/bloc/downloads_event.dart';
import 'package:mihonx/features/downloads/presentation/bloc/downloads_state.dart';

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

class _DownloadsView extends StatelessWidget {
  const _DownloadsView();

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppAppBar(
        title: 'downloads.title',
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined),
            onPressed: () => context
                .read<DownloadsBloc>()
                .add(const DownloadsClearFinished()),
          ),
        ],
      ),
      body: BlocBuilder<DownloadsBloc, DownloadsState>(
        buildWhen: (a, b) => a.queue != b.queue,
        builder: (context, state) => state.queue.isEmpty
            ? const AppEmptyIndicator(
                message: 'downloads.empty',
                icon: Icons.download_outlined,
              )
            : ListView.builder(
                itemCount: state.queue.length,
                itemBuilder: (context, index) =>
                    _DownloadTile(task: state.queue[index]),
              ),
      ),
    );
  }
}

class _DownloadTile extends StatelessWidget {
  const _DownloadTile({required this.task});

  final DownloadTask task;

  @override
  Widget build(BuildContext context) {
    return ListTile(
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
              'downloads.status_${task.status.name}',
              color: task.status == DownloadTaskStatus.failed
                  ? context.colorScheme.error
                  : context.colorScheme.onSurfaceVariant,
            ),
        ],
      ),
      trailing: switch (task.status) {
        DownloadTaskStatus.queued ||
        DownloadTaskStatus.downloading =>
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => context
                .read<DownloadsBloc>()
                .add(DownloadCancelRequested(task.chapterId)),
          ),
        DownloadTaskStatus.failed => IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context
                .read<DownloadsBloc>()
                .add(DownloadRetryRequested(task.chapterId)),
          ),
        _ => null,
      },
    );
  }
}
