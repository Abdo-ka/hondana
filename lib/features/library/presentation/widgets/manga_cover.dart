import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:mihonx/core/extensions/context_ext.dart';

/// Renders a cover from a network URL, a local file path, or a placeholder.
/// Fills its parent's constraints (use inside a sized box / Positioned.fill).
class MangaCover extends StatelessWidget {
  const MangaCover({required this.url, this.radius = 6, super.key});

  final String? url;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius.r),
      child: (url == null || url!.isEmpty)
          ? ColoredBox(
              color: context.colorScheme.surfaceContainerHighest,
              child: Icon(
                Icons.image_not_supported_outlined,
                color: context.colorScheme.outline,
              ),
            )
          : url!.startsWith('http')
              ? CachedNetworkImage(
                  imageUrl: url!,
                  fit: BoxFit.cover,
                  placeholder: (context, _) => ColoredBox(
                    color: context.colorScheme.surfaceContainerHighest,
                  ),
                  errorWidget: (context, _, _) => ColoredBox(
                    color: context.colorScheme.surfaceContainerHighest,
                    child: Icon(
                      Icons.broken_image_outlined,
                      color: context.colorScheme.outline,
                    ),
                  ),
                )
              : Image.file(
                  File(url!),
                  fit: BoxFit.cover,
                  errorBuilder: (context, _, _) => ColoredBox(
                    color: context.colorScheme.surfaceContainerHighest,
                  ),
                ),
    );
  }
}
