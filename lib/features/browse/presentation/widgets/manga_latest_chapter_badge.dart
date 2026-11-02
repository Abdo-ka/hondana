import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:hondana/core/core.dart';

/// Latest chapter from the listing response, shown over a result cover.
class MangaLatestChapterBadge extends StatelessWidget {
  const MangaLatestChapterBadge({required this.chapter, super.key});

  /// Chapter label as supplied by the source listing.
  final String chapter;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: context.colorScheme.primaryContainer,
      borderRadius: BorderRadius.circular(4.r),
    ),
    child: Padding(
      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 3.h),
      child: AppText.labelSmall(
        'browse.latest_chapter'.tr(namedArgs: {'chapter': chapter}),
        color: context.colorScheme.onPrimaryContainer,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    ),
  );
}
