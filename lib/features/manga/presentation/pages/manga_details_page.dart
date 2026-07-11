import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:mihonx/core/core.dart';
import 'package:mihonx/core/di/di_container.dart';
import 'package:mihonx/core/routing/app_router.gr.dart';
import 'package:mihonx/features/browse/data/source/http_source_base.dart';
import 'package:mihonx/features/browse/data/source/local_source.dart';
import 'package:mihonx/features/browse/domain/source/model/s_manga.dart';
import 'package:mihonx/features/browse/domain/source/source_manager.dart';
import 'package:mihonx/features/downloads/presentation/bloc/downloads_bloc.dart';
import 'package:mihonx/features/downloads/presentation/bloc/downloads_event.dart';
import 'package:mihonx/features/manga/presentation/bloc/manga_details_bloc.dart';
import 'package:mihonx/features/manga/presentation/bloc/manga_details_event.dart';
import 'package:mihonx/features/manga/presentation/bloc/manga_details_state.dart';
import 'package:mihonx/features/manga/presentation/widgets/manga_chapter_tile.dart';
import 'package:mihonx/features/manga/presentation/widgets/manga_info_header.dart';

@RoutePage()
class MangaDetailsPage extends StatelessWidget {
  const MangaDetailsPage({
    required this.sourceId,
    required this.initial,
    super.key,
  });

  final int sourceId;
  final SManga initial;

  @override
  Widget build(BuildContext context) {
    return PageLayoutBuilder(
      mobile: (context) => MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) =>
                getIt<MangaDetailsBloc>(param1: sourceId, param2: initial)
                  ..add(const MangaDetailsStarted()),
          ),
          BlocProvider.value(value: getIt<DownloadsBloc>()),
        ],
        child: const _DetailsView(),
      ),
    );
  }
}

class _DetailsView extends StatelessWidget {
  const _DetailsView();

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      // App bar floats transparent over the backdrop cover (Mihon layout).
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(),
        actions: const [_MangaWebViewAction()],
      ),
      floatingActionButton: const _StartReadingFab(),
      body: const CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: MangaInfoHeader()),
          SliverToBoxAdapter(child: _ChaptersHeader()),
          _ChaptersSliver(),
          // Keep the FAB from covering the last chapter row.
          SliverToBoxAdapter(child: SizedBox(height: 76)),
        ],
      ),
    );
  }
}

/// Opens this manga's page on the source website — also solves the source's
/// Cloudflare challenge, since earned cookies are replayed onto requests.
class _MangaWebViewAction extends StatelessWidget {
  const _MangaWebViewAction();

  @override
  Widget build(BuildContext context) {
    final source =
        getIt<SourceManager>().get(context.read<MangaDetailsBloc>().sourceId);
    if (source is! HttpSourceBase) return const SizedBox.shrink();
    return IconButton(
      icon: const Icon(Icons.public),
      onPressed: () {
        final state = context.read<MangaDetailsBloc>().state;
        context.router.push(
          SourceWebViewRoute(
            initialUrl: source.mangaUrl(
              SManga(
                url: state.manga?.url ?? state.source.url,
                title: state.title,
              ),
            ),
            title: state.title,
          ),
        );
      },
    );
  }
}

class _StartReadingFab extends StatelessWidget {
  const _StartReadingFab();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MangaDetailsBloc, MangaDetailsState>(
      buildWhen: (a, b) => a.chapters != b.chapters,
      builder: (context, state) => state.chapters.isEmpty
          ? const SizedBox.shrink()
          : FloatingActionButton.extended(
              onPressed: () {
                final target = state.nextUnread;
                if (target != null) {
                  context.router.push(ReaderRoute(chapterId: target.id));
                }
              },
              icon: const Icon(Icons.play_arrow),
              label: AppText.labelLarge(
                state.chapters.any((c) => c.read)
                    ? 'manga.resume'
                    : 'manga.start_reading',
              ),
            ),
    );
  }
}

/// Mihon's toolbar download menu: next 1/5/10/25 unread, all unread, or all.
enum _DownloadChoice {
  next1(1),
  next5(5),
  next10(10),
  next25(25),
  unread(null),
  all(null);

  const _DownloadChoice(this.count);
  final int? count;
}

class _ChaptersHeader extends StatelessWidget {
  const _ChaptersHeader();

  /// Queues chapters in reading order (chapter 1 first); the bloc skips ones
  /// already downloaded or in flight.
  void _download(BuildContext context, _DownloadChoice choice) {
    final details = context.read<MangaDetailsBloc>().state;
    final downloads = context.read<DownloadsBloc>();
    final chapters = switch (choice) {
      _DownloadChoice.all => details.ascendingChapters,
      _DownloadChoice.unread => details.unreadAscending,
      _ => details.unreadAscending.take(choice.count!),
    };
    for (final chapter in chapters) {
      downloads.add(DownloadEnqueued(
        chapterId: chapter.id,
        mangaId: chapter.mangaId,
        mangaTitle: details.title,
        chapterName: chapter.name,
      ));
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('manga.download_queued'.tr())),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MangaDetailsBloc, MangaDetailsState>(
      buildWhen: (a, b) =>
          a.chapters.length != b.chapters.length ||
          a.chaptersDescending != b.chaptersDescending,
      builder: (context, state) => Padding(
        padding: EdgeInsets.fromLTRB(16.w, 8.h, 4.w, 0),
        child: Row(
          children: [
            Expanded(
              child: AppText.titleSmall('${state.chapters.length} · chapters'),
            ),
            if (context.read<MangaDetailsBloc>().sourceId !=
                LocalSource.localSourceId)
              PopupMenuButton<_DownloadChoice>(
                icon: const Icon(Icons.download),
                tooltip: 'manga.download'.tr(),
                onSelected: (choice) => _download(context, choice),
                itemBuilder: (context) => [
                  for (final choice in _DownloadChoice.values)
                    PopupMenuItem(
                      value: choice,
                      child: Text('manga.download_${choice.name}'.tr()),
                    ),
                ],
              ),
            IconButton(
              icon: Icon(
                state.chaptersDescending
                    ? Icons.arrow_downward
                    : Icons.arrow_upward,
              ),
              onPressed: () => context
                  .read<MangaDetailsBloc>()
                  .add(const MangaChapterSortToggled()),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChaptersSliver extends StatelessWidget {
  const _ChaptersSliver();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MangaDetailsBloc, MangaDetailsState>(
      buildWhen: (a, b) =>
          a.chapters != b.chapters ||
          a.chaptersStatus != b.chaptersStatus ||
          a.chaptersDescending != b.chaptersDescending,
      builder: (context, state) => state.chapters.isEmpty
          ? SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(24.w),
                child: state.chaptersStatus.build(
                  success: () => const SizedBox.shrink(),
                  emptyMessage: 'manga.no_chapters',
                ),
              ),
            )
          : SliverList.builder(
              itemCount: state.orderedChapters.length,
              itemBuilder: (context, index) =>
                  MangaChapterTile(chapter: state.orderedChapters[index]),
            ),
    );
  }
}
