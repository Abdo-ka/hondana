import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:mihonx/core/network/app_http.dart';

/// Remembers each page's intrinsic aspect ratio across rebuilds. In webtoon
/// mode an item whose image is still loading (or was disposed offscreen and
/// reloads) would otherwise change height when the bytes arrive — and item
/// height changes near the viewport are exactly what makes continuous
/// scrolling "jump to a random page". Once a page has been decoded we can
/// reserve its final height immediately on every later build.
class _PageAspectCache {
  // ponytail: plain FIFO-capped map; an LRU only matters past ~600 open pages.
  static const _max = 600;
  static final _cache = <String, double>{};

  static double? get(String url) => _cache[url];

  static void set(String url, double aspect) {
    if (!_cache.containsKey(url) && _cache.length >= _max) {
      _cache.remove(_cache.keys.first);
    }
    _cache[url] = aspect;
  }
}

/// Renders a reader page from a network URL (with source headers) or a local
/// file path. With [BoxFit.fitWidth] (webtoon) the widget reserves the image's
/// exact final height as soon as its aspect ratio is known, so late loads
/// never shift the scroll position.
class ReaderImage extends StatefulWidget {
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
  State<ReaderImage> createState() => _ReaderImageState();
}

class _ReaderImageState extends State<ReaderImage> {
  // ValueNotifier per the house no-setState rule.
  final ValueNotifier<double?> _aspect = ValueNotifier(null);
  ImageStream? _stream;
  ImageStreamListener? _listener;

  /// Only webtoon items live in an unbounded-height list where height
  /// stability matters; paged mode is always viewport-sized.
  bool get _reservesHeight => widget.fit == BoxFit.fitWidth;

  @override
  void initState() {
    super.initState();
    _initAspect();
  }

  @override
  void didUpdateWidget(ReaderImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      _stopListening();
      _aspect.value = null;
      _initAspect();
    }
  }

  @override
  void dispose() {
    _stopListening();
    _aspect.dispose();
    super.dispose();
  }

  void _initAspect() {
    final url = widget.url;
    if (url == null || url.isEmpty || !_reservesHeight) return;
    _aspect.value = _PageAspectCache.get(url);
    if (_aspect.value == null) _resolveAspect(url);
  }

  ImageProvider _provider(String url) => url.startsWith('http')
      // Same provider identity as the CachedNetworkImage below, so this
      // resolves from the shared image cache instead of loading twice.
      ? CachedNetworkImageProvider(
          url,
          headers: widget.headers,
          cacheManager: AppImageCache.manager,
        )
      : FileImage(File(url));

  void _resolveAspect(String url) {
    final stream = _provider(url).resolve(ImageConfiguration.empty);
    final listener = ImageStreamListener(
      (info, _) {
        final aspect = info.image.width / info.image.height;
        info.dispose();
        _PageAspectCache.set(url, aspect);
        if (mounted && _aspect.value == null) _aspect.value = aspect;
      },
      onError: (_, _) {}, // The visible widget shows its own error state.
    );
    _stream = stream;
    _listener = listener;
    stream.addListener(listener);
  }

  void _stopListening() {
    final listener = _listener;
    if (listener != null) _stream?.removeListener(listener);
    _stream = null;
    _listener = null;
  }

  @override
  Widget build(BuildContext context) {
    final url = widget.url;
    if (url == null || url.isEmpty) return const SizedBox.shrink();
    // Before the aspect ratio is known, hold a stable placeholder box close
    // to a typical page so the eventual correction stays small. Fixed logical
    // px, not MediaQuery — immersive-mode toggles change the reported screen
    // size and would shift every still-loading item.
    final placeholderHeight = _reservesHeight ? 500.0 : 320.0;
    final image = url.startsWith('http')
        ? CachedNetworkImage(
            imageUrl: url,
            httpHeaders: widget.headers,
            cacheManager: AppImageCache.manager,
            fit: widget.fit,
            fadeInDuration: Duration.zero,
            fadeOutDuration: Duration.zero,
            placeholder: (context, _) => SizedBox(
              height: placeholderHeight,
              child: const Center(child: CircularProgressIndicator.adaptive()),
            ),
            errorWidget: (context, _, _) => SizedBox(
              height: placeholderHeight,
              child: const Icon(Icons.broken_image_outlined,
                  color: Colors.white38),
            ),
          )
        : Image.file(
            File(url),
            fit: widget.fit,
            errorBuilder: (context, _, _) => SizedBox(
              height: placeholderHeight,
              child: const Icon(Icons.broken_image_outlined,
                  color: Colors.white38),
            ),
          );
    if (!_reservesHeight) return image;
    return ValueListenableBuilder<double?>(
      valueListenable: _aspect,
      builder: (context, aspect, child) => aspect != null
          ? AspectRatio(aspectRatio: aspect, child: child)
          // Aspect not yet known: keep at least placeholder height. Without
          // this a local Image.file lays out at ~0 height until decoded,
          // collapsing a downloaded chapter into a stack of zero-height items.
          : ConstrainedBox(
              constraints: BoxConstraints(minHeight: placeholderHeight),
              child: child,
            ),
      child: image,
    );
  }
}
