import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:hondana/core/routing/app_router.gr.dart';
import 'package:hondana/core/widgets/app_text.dart';
import 'package:hondana/features/browse/domain/source/model/s_manga.dart';
import 'package:hondana/features/library/presentation/widgets/manga_cover.dart';

/// Paginating cover grid for source results. Reused by catalogue + search.
class SourceMangaGrid extends StatelessWidget {
  const SourceMangaGrid({
    required this.manga,
    required this.sourceId,
    required this.hasNext,
    required this.onLoadMore,
    super.key,
  });

  final List<SManga> manga;
  final int sourceId;
  final bool hasNext;
  final VoidCallback onLoadMore;

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (n) {
        if (hasNext && n.metrics.pixels >= n.metrics.maxScrollExtent - 600) {
          onLoadMore();
        }
        return false;
      },
      child: GridView.builder(
        padding: EdgeInsets.all(8.w),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 0.62,
          crossAxisSpacing: 8.w,
          mainAxisSpacing: 8.w,
        ),
        itemCount: manga.length,
        itemBuilder: (context, index) =>
            _SourceMangaCell(manga: manga[index], sourceId: sourceId),
      ),
    );
  }
}

/// A single grid cell: cover with a bottom gradient overlaying the title.
class _SourceMangaCell extends StatelessWidget {
  const _SourceMangaCell({required this.manga, required this.sourceId});

  final SManga manga;
  final int sourceId;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.router.push(
        MangaDetailsRoute(sourceId: sourceId, initial: manga),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          MangaCover(url: manga.thumbnailUrl, sourceId: sourceId),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(6.w, 14.h, 6.w, 6.h),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black87, Colors.transparent],
                ),
              ),
              child: AppText.labelMedium(
                manga.title,
                color: Colors.white,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
