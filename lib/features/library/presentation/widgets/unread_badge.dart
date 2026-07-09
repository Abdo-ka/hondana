import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:mihonx/core/extensions/context_ext.dart';
import 'package:mihonx/core/widgets/app_text.dart';

/// Small count chip overlaid on a cover (unread chapters, download count).
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
