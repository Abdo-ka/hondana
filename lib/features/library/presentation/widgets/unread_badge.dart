import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:hondana/core/extensions/context_ext.dart';
import 'package:hondana/core/widgets/app_text.dart';

/// Mihon-style joined cover badge: download count (tertiary) and unread count
/// (primary) fused into one rounded pill at the cover's top-start corner.
class CoverBadges extends StatelessWidget {
  const CoverBadges({required this.unread, this.downloads = 0, super.key});

  final int unread;
  final int downloads;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4.r),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (downloads > 0)
            Container(
              color: context.colorScheme.tertiary,
              padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
              child: AppText.labelSmall(
                '$downloads',
                color: context.colorScheme.onTertiary,
              ),
            ),
          if (unread > 0)
            Container(
              color: context.colorScheme.primary,
              padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
              child: AppText.labelSmall(
                '$unread',
                color: context.colorScheme.onPrimary,
              ),
            ),
        ],
      ),
    );
  }
}

/// Kept for compact call sites that only show one count.
class UnreadBadge extends StatelessWidget {
  const UnreadBadge({required this.count, this.color, super.key});

  final int count;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: color ?? context.colorScheme.primary,
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: AppText.labelSmall(
        '$count',
        color: color != null
            ? context.colorScheme.onSecondary
            : context.colorScheme.onPrimary,
      ),
    );
  }
}
