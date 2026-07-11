import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:hondana/core/extensions/context_ext.dart';
import 'package:hondana/features/downloads/presentation/bloc/downloads_bloc.dart';
import 'package:hondana/features/downloads/presentation/bloc/downloads_event.dart';
import 'package:hondana/features/downloads/presentation/bloc/downloads_state.dart';

/// Per-chapter download control: download icon → determinate progress ring →
/// check (tap deletes). Requires a [DownloadsBloc] above it.
class ChapterDownloadButton extends StatelessWidget {
  const ChapterDownloadButton({
    required this.chapterId,
    required this.mangaId,
    required this.mangaTitle,
    required this.chapterName,
    super.key,
  });

  final int chapterId;
  final int mangaId;
  final String mangaTitle;
  final String chapterName;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DownloadsBloc, DownloadsState>(
      buildWhen: (a, b) =>
          a.taskFor(chapterId) != b.taskFor(chapterId) ||
          a.downloaded.contains(chapterId) != b.downloaded.contains(chapterId),
      builder: (context, state) {
        if (state.downloaded.contains(chapterId)) {
          return IconButton(
            icon: Icon(Icons.check_circle, color: context.colorScheme.primary),
            onPressed: () => context.read<DownloadsBloc>().add(
              DownloadDeleteRequested(mangaId: mangaId, chapterId: chapterId),
            ),
          );
        }
        final task = state.taskFor(chapterId);
        if (task != null && task.isActive) {
          return IconButton(
            // Determinate ring, not a loading spinner.
            icon: SizedBox(
              width: 20.r,
              height: 20.r,
              child: CircularProgressIndicator(
                strokeWidth: 2.r,
                value: task.status == DownloadTaskStatus.downloading
                    ? task.progress
                    : null,
              ),
            ),
            onPressed: () => context.read<DownloadsBloc>().add(
              DownloadCancelRequested(chapterId),
            ),
          );
        }
        return IconButton(
          icon: Icon(
            Icons.download_outlined,
            color: context.colorScheme.onSurfaceVariant,
          ),
          onPressed: () => context.read<DownloadsBloc>().add(
            DownloadEnqueued(
              chapterId: chapterId,
              mangaId: mangaId,
              mangaTitle: mangaTitle,
              chapterName: chapterName,
            ),
          ),
        );
      },
    );
  }
}
