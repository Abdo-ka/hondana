import 'dart:math';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import 'package:mihonx/core/di/di_container.dart';
import 'package:mihonx/features/reader/domain/reader_preferences.dart';
import 'package:mihonx/features/reader/presentation/bloc/reader_bloc.dart';
import 'package:mihonx/features/reader/presentation/bloc/reader_event.dart';
import 'package:mihonx/features/reader/presentation/bloc/reader_state.dart';
import 'package:mihonx/features/reader/presentation/widgets/reader_image.dart';
import 'package:mihonx/features/reader/presentation/widgets/reader_overlay.dart';

@RoutePage()
class ReaderPage extends StatelessWidget {
  const ReaderPage({required this.chapterId, super.key});

  final int chapterId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<ReaderBloc>(param1: chapterId)..add(const ReaderStarted()),
      child: const _ReaderView(),
    );
  }
}

class _ReaderView extends StatefulWidget {
  const _ReaderView();

  @override
  State<_ReaderView> createState() => _ReaderViewState();
}

class _ReaderViewState extends State<_ReaderView> {
  @override
  void initState() {
    super.initState();
    _applySystemUi(context.read<ReaderBloc>().state.showOverlay);
  }

  @override
  void dispose() {
    // Leaving the reader must always restore the regular system bars.
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _applySystemUi(bool showOverlay) {
    SystemChrome.setEnabledSystemUIMode(
      showOverlay ? SystemUiMode.edgeToEdge : SystemUiMode.immersiveSticky,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ReaderBloc, ReaderState>(
      listenWhen: (a, b) => a.showOverlay != b.showOverlay,
      listener: (context, state) => _applySystemUi(state.showOverlay),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: BlocBuilder<ReaderBloc, ReaderState>(
          buildWhen: (a, b) =>
              a.status != b.status ||
              a.readingMode != b.readingMode ||
              a.showOverlay != b.showOverlay,
          builder: (context, state) => state.status.build(
            emptyMessage: 'manga.no_chapters',
            success: () => Stack(
              children: [
                Positioned.fill(
                  child: state.readingMode.isPaged
                      ? const _PagedReader()
                      : const _WebtoonReader(),
                ),
                // Mihon keeps a small page indicator visible at all times.
                const Positioned(
                  bottom: 4,
                  left: 0,
                  right: 0,
                  child: _PageIndicator(),
                ),
                if (state.showOverlay) const ReaderTopBar(),
                if (state.showOverlay) const ReaderBottomBar(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Always-visible "current / total" pill at the bottom of the screen.
class _PageIndicator extends StatelessWidget {
  const _PageIndicator();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReaderBloc, ReaderState>(
      buildWhen: (a, b) =>
          a.currentPage != b.currentPage || a.pageCount != b.pageCount,
      builder: (context, state) => state.pageCount == 0
          ? const SizedBox.shrink()
          : Center(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  child: Text(
                    '${state.currentPage + 1}/${state.pageCount}',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ),
            ),
    );
  }
}

class _PagedReader extends StatefulWidget {
  const _PagedReader();

  @override
  State<_PagedReader> createState() => _PagedReaderState();
}

class _PagedReaderState extends State<_PagedReader> {
  late final PageController _controller;
  // While a page is zoomed the PageView must not steal horizontal drags.
  final ValueNotifier<bool> _zoomed = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    _controller = PageController(
      initialPage: context.read<ReaderBloc>().state.currentPage,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _zoomed.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ReaderBloc, ReaderState>(
      listenWhen: (a, b) =>
          a.chapterId != b.chapterId || a.currentPage != b.currentPage,
      listener: (context, state) {
        if (!_controller.hasClients) return;
        if ((_controller.page?.round() ?? -1) != state.currentPage) {
          _controller.jumpToPage(state.currentPage);
        }
      },
      child: BlocBuilder<ReaderBloc, ReaderState>(
        buildWhen: (a, b) =>
            a.pages != b.pages ||
            a.readingMode != b.readingMode ||
            a.imageHeaders != b.imageHeaders,
        builder: (context, state) => GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapUp: (d) => _handleTap(context, d, state.readingMode),
          child: ValueListenableBuilder<bool>(
            valueListenable: _zoomed,
            builder: (context, zoomed, _) => PageView.builder(
              controller: _controller,
              physics: zoomed ? const NeverScrollableScrollPhysics() : null,
              scrollDirection: state.readingMode == ReadingMode.vertical
                  ? Axis.vertical
                  : Axis.horizontal,
              reverse: state.readingMode.isReversed,
              onPageChanged: (i) {
                _zoomed.value = false;
                context.read<ReaderBloc>().add(ReaderPageChanged(i));
              },
              itemCount: state.pages.length,
              itemBuilder: (context, index) => _ZoomablePage(
                onZoomChanged: (z) => _zoomed.value = z,
                child: Center(
                  child: ReaderImage(
                    url: state.pages[index].imageUrl ?? state.pages[index].url,
                    headers: state.imageHeaders,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleTap(BuildContext context, TapUpDetails d, ReadingMode mode) {
    final size = MediaQuery.sizeOf(context);
    final along =
        mode == ReadingMode.vertical ? d.localPosition.dy : d.localPosition.dx;
    final extent = mode == ReadingMode.vertical ? size.height : size.width;
    if (along < extent / 3) {
      mode.isReversed ? _page(1) : _page(-1);
    } else if (along > extent * 2 / 3) {
      mode.isReversed ? _page(-1) : _page(1);
    } else {
      context.read<ReaderBloc>().add(const ReaderOverlayToggled());
    }
  }

  void _page(int delta) => _controller.animateToPage(
        (_controller.page?.round() ?? 0) + delta,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
}

/// A single paged-reader page: pinch to zoom, double tap to toggle 2x zoom at
/// the tap point (Mihon default). Reports its zoom state so the enclosing
/// PageView can hand drag gestures to the zoomed image.
class _ZoomablePage extends StatefulWidget {
  const _ZoomablePage({required this.onZoomChanged, required this.child});

  final ValueChanged<bool> onZoomChanged;
  final Widget child;

  @override
  State<_ZoomablePage> createState() => _ZoomablePageState();
}

class _ZoomablePageState extends State<_ZoomablePage> {
  static const _zoomThreshold = 1.05;
  static const _doubleTapScale = 2.0;

  final TransformationController _transformation = TransformationController();
  Offset? _doubleTapPosition;

  bool get _isZoomed =>
      _transformation.value.getMaxScaleOnAxis() > _zoomThreshold;

  @override
  void dispose() {
    _transformation.dispose();
    super.dispose();
  }

  void _onDoubleTap() {
    if (_isZoomed) {
      _transformation.value = Matrix4.identity();
    } else {
      final p = _doubleTapPosition;
      if (p == null) return;
      // Zoom about the tap point: keep it fixed while scaling up.
      _transformation.value = Matrix4.identity()
        ..translateByDouble(
          -p.dx * (_doubleTapScale - 1),
          -p.dy * (_doubleTapScale - 1),
          0,
          1,
        )
        ..scaleByDouble(_doubleTapScale, _doubleTapScale, 1, 1);
    }
    widget.onZoomChanged(_isZoomed);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTapDown: (d) => _doubleTapPosition = d.localPosition,
      onDoubleTap: _onDoubleTap,
      child: InteractiveViewer(
        transformationController: _transformation,
        maxScale: 5,
        onInteractionEnd: (_) => widget.onZoomChanged(_isZoomed),
        child: widget.child,
      ),
    );
  }
}

class _WebtoonReader extends StatefulWidget {
  const _WebtoonReader();

  @override
  State<_WebtoonReader> createState() => _WebtoonReaderState();
}

class _WebtoonReaderState extends State<_WebtoonReader> {
  final ItemScrollController _scrollController = ItemScrollController();
  final ScrollOffsetController _offsetController = ScrollOffsetController();
  final ItemPositionsListener _positions = ItemPositionsListener.create();
  late int _currentIndex;
  // Suppresses position reports while an external seek jump is in flight so
  // stale positions cannot bounce currentPage back (and cannot mark pages
  // read from a transient index).
  bool _pendingJump = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = context.read<ReaderBloc>().state.currentPage;
    _positions.itemPositions.addListener(_onPositionsChanged);
  }

  @override
  void dispose() {
    _positions.itemPositions.removeListener(_onPositionsChanged);
    super.dispose();
  }

  void _onPositionsChanged() {
    final positions = _positions.itemPositions.value;
    if (positions.isEmpty || !mounted || _pendingJump) return;
    // Current page = the item whose leading edge last crossed the viewport
    // middle (Mihon's webtoon rule).
    final above = positions.where((p) => p.itemLeadingEdge <= 0.5);
    final index = above.isEmpty
        ? positions.map((p) => p.index).reduce(min)
        : above.map((p) => p.index).reduce(max);
    if (index == _currentIndex) return;
    _currentIndex = index;
    context.read<ReaderBloc>().add(ReaderPageChanged(index));
  }

  void _handleTap(TapUpDetails d) {
    final height = MediaQuery.sizeOf(context).height;
    final dy = d.localPosition.dy;
    if (dy < height / 3) {
      _scrollBy(-0.75 * height);
    } else if (dy > height * 2 / 3) {
      _scrollBy(0.75 * height);
    } else {
      context.read<ReaderBloc>().add(const ReaderOverlayToggled());
    }
  }

  void _scrollBy(double offset) => _offsetController.animateScroll(
        offset: offset,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );

  @override
  Widget build(BuildContext context) {
    return BlocListener<ReaderBloc, ReaderState>(
      listenWhen: (a, b) =>
          a.chapterId != b.chapterId || a.currentPage != b.currentPage,
      listener: (context, state) {
        // Jump only for external seeks (slider, chapter switch), never for
        // pages this widget itself reported while scrolling.
        if (state.currentPage == _currentIndex) return;
        _currentIndex = state.currentPage;
        _pendingJump = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _scrollController.isAttached) {
            _scrollController.jumpTo(index: _currentIndex);
          }
          // Let the jumped-to layout settle before reporting positions again.
          WidgetsBinding.instance
              .addPostFrameCallback((_) => _pendingJump = false);
        });
      },
      child: BlocBuilder<ReaderBloc, ReaderState>(
        buildWhen: (a, b) =>
            a.pages != b.pages || a.imageHeaders != b.imageHeaders,
        builder: (context, state) => GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapUp: _handleTap,
          child: ScrollablePositionedList.builder(
            itemScrollController: _scrollController,
            scrollOffsetController: _offsetController,
            itemPositionsListener: _positions,
            initialScrollIndex: _currentIndex,
            itemCount: state.pages.length,
            itemBuilder: (context, index) => ReaderImage(
              url: state.pages[index].imageUrl ?? state.pages[index].url,
              headers: state.imageHeaders,
              fit: BoxFit.fitWidth,
            ),
          ),
        ),
      ),
    );
  }
}
