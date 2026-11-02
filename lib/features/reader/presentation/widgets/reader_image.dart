import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:hondana/core/network/app_http.dart';

/// Renders a reader page from a network URL (with source headers) or a local
/// file path. With [BoxFit.fitWidth] (webtoon) the widget reserves the image's
/// exact final height as soon as its aspect ratio is known, so late loads
/// never shift the scroll position.
class ReaderImage extends StatefulWidget {
  const ReaderImage({
    required this.url,
    this.headers = const {},
    this.fit = BoxFit.contain,
    this.reserveHeight = false,
    this.aspectRatios,
    super.key,
  });

  final String? url;
  final Map<String, String> headers;
  final BoxFit fit;

  /// Webtoon items live in an unbounded-height list where height stability
  /// matters; paged mode is always viewport-sized and must not reserve.
  final bool reserveHeight;

  /// Reader-session geometry, retained even when a page leaves the viewport.
  /// Stores only ratios, never decoded images.
  final Map<String, double>? aspectRatios;

  @override
  State<ReaderImage> createState() => _ReaderImageState();
}

class _ReaderImageState extends State<ReaderImage> {
  // ValueNotifier per the house no-setState rule.
  final ValueNotifier<double?> _aspect = ValueNotifier(null);
  ImageStream? _stream;
  ImageStreamListener? _listener;

  ImageProvider? _image;
  int? _decodeWidth;

  bool get _reservesHeight => widget.reserveHeight;
  double get _placeholderHeight => _reservesHeight ? 500.h : 320.h;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _configureImage();
  }

  @override
  void didUpdateWidget(ReaderImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url ||
        oldWidget.headers != widget.headers ||
        oldWidget.reserveHeight != widget.reserveHeight ||
        oldWidget.aspectRatios != widget.aspectRatios) {
      _image = null;
      _configureImage();
    }
  }

  void _configureImage() {
    final url = widget.url;
    final width = _reservesHeight
        ? (MediaQuery.sizeOf(context).width *
                  MediaQuery.devicePixelRatioOf(context))
              .ceil()
        : null;
    if (_image != null && width == _decodeWidth) return;
    _stopListening();
    _decodeWidth = width;
    _aspect.value = widget.aspectRatios?[url];
    _image = url == null || url.isEmpty
        ? null
        : ResizeImage.resizeIfNeeded(width, null, _provider(url));
    if (_image != null && _reservesHeight && _aspect.value == null) {
      _resolveAspect(url!);
    }
  }

  @override
  void dispose() {
    _stopListening();
    _aspect.dispose();
    super.dispose();
  }

  ImageProvider _provider(String url) => url.startsWith('http')
      // Geometry and rendering share the same resized provider/cache entry.
      ? CachedNetworkImageProvider(
          url,
          headers: widget.headers,
          cacheManager: AppImageCache.manager,
        )
      : FileImage(File(url));

  void _resolveAspect(String url) {
    final stream = _image!.resolve(ImageConfiguration.empty);
    final listener = ImageStreamListener(
      (info, _) {
        final aspect = info.image.width / info.image.height;
        info.dispose();
        widget.aspectRatios?[url] = aspect;
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
  Widget build(BuildContext context) => _image == null
      ? const SizedBox.shrink()
      : ValueListenableBuilder<double?>(
          valueListenable: _aspect,
          builder: (context, aspect, child) => _reservesHeight && aspect != null
              ? AspectRatio(aspectRatio: aspect, child: child)
              : ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: _reservesHeight ? _placeholderHeight : 0,
                  ),
                  child: child,
                ),
          child: Image(
            image: _image!,
            fit: widget.fit,
            // Width-sized decoding keeps long chapters inside the image cache
            // budget, avoiding repeated full-resolution decodes on backscroll.
            filterQuality: FilterQuality.low,
            frameBuilder: (context, child, frame, synchronous) =>
                synchronous || frame != null
                ? child
                : _ReaderImagePlaceholder(height: _placeholderHeight),
            errorBuilder: (context, error, stack) => _ReaderImagePlaceholder(
              height: _placeholderHeight,
              failed: true,
            ),
          ),
        );
}

class _ReaderImagePlaceholder extends StatelessWidget {
  const _ReaderImagePlaceholder({required this.height, this.failed = false});

  final double height;
  final bool failed;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: height,
    child: Center(
      child: failed
          ? Icon(
              Icons.broken_image_outlined,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            )
          : const CircularProgressIndicator.adaptive(),
    ),
  );
}
