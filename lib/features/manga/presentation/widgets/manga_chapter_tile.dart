import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mihonx/core/database/app_database.dart';
import 'package:mihonx/core/extensions/context_ext.dart';
import 'package:mihonx/core/routing/app_router.gr.dart';
import 'package:mihonx/core/widgets/app_text.dart';
import 'package:mihonx/features/browse/data/source/local_source.dart';
import 'package:mihonx/features/downloads/presentation/widgets/chapter_download_button.dart';
import 'package:mihonx/features/manga/presentation/bloc/manga_details_bloc.dart';
import 'package:mihonx/features/manga/presentation/bloc/manga_details_event.dart';

/// A chapter row. Tap opens the reader; long-press toggles read; the trailing
/// button downloads / shows progress / deletes the download.
class MangaChapterTile extends StatelessWidget {
  const MangaChapterTile({required this.chapter, super.key});

  final ChapterData chapter;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      title: AppText.bodyMedium(
        chapter.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        color: chapter.read ? context.colorScheme.onSurfaceVariant : null,
      ),
      subtitle: AppText.bodySmall(
        _subtitle(),
        color: context.colorScheme.onSurfaceVariant,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (chapter.read)
            Icon(Icons.check, size: 18, color: context.colorScheme.primary),
          if (context.read<MangaDetailsBloc>().sourceId !=
              LocalSource.localSourceId)
            ChapterDownloadButton(
              chapterId: chapter.id,
              mangaId: chapter.mangaId,
              mangaTitle: context.read<MangaDetailsBloc>().state.title,
              chapterName: chapter.name,
            ),
        ],
      ),
      onTap: () => context.router.push(ReaderRoute(chapterId: chapter.id)),
      onLongPress: () => context
          .read<MangaDetailsBloc>()
          .add(MangaChapterReadToggled(chapter.id, !chapter.read)),
    );
  }

  String _subtitle() {
    final parts = <String>[];
    final date = chapter.dateUpload;
    if (date != null) parts.add(DateFormat.yMMMd().format(date));
    final scanlator = chapter.scanlator;
    if (scanlator != null && scanlator.isNotEmpty) parts.add(scanlator);
    return parts.join(' • ');
  }
}

