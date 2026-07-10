import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:mihonx/core/network/app_http.dart';

/// Renders a reader page from a network URL (with source headers) or a local
/// file path.
class ReaderImage extends StatelessWidget {
  const ReaderImage({
    required this.url,
    this.headers = const {},
    this.fit = BoxFit.contain,
    super.key,
  });

  final String? url;
  final Map<String, String> headers;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return (url == null || url!.isEmpty)
        ? const SizedBox.shrink()
        : url!.startsWith('http')
            ? CachedNetworkImage(
                imageUrl: url!,
                httpHeaders: headers,
                cacheManager: AppImageCache.manager,
                fit: fit,
                placeholder: (context, _) => const SizedBox(
                  height: 320,
                  child: Center(child: CircularProgressIndicator.adaptive()),
                ),
                errorWidget: (context, _, _) => const SizedBox(
                  height: 320,
                  child: Icon(Icons.broken_image_outlined, color: Colors.white38),
                ),
              )
            : Image.file(
                File(url!),
                fit: fit,
                errorBuilder: (context, _, _) => const SizedBox(
                  height: 320,
                  child: Icon(Icons.broken_image_outlined, color: Colors.white38),
                ),
              );
  }
}
