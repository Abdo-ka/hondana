import 'dart:math';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import 'package:mihonx/core/di/di_container.dart';
import 'package:mihonx/core/utils/native_screen.dart';
import 'package:mihonx/core/widgets/app_text.dart';
import 'package:mihonx/features/reader/domain/reader_preferences.dart';
import 'package:mihonx/features/reader/presentation/bloc/reader_bloc.dart';
import 'package:mihonx/features/reader/presentation/bloc/reader_event.dart';
import 'package:mihonx/features/reader/presentation/bloc/reader_item.dart';
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

/// What a tap zone does before reading direction is applied.
enum _NavAction { menu, prev, next }

/// Mihon's tap-zone geometries (ViewerNavigation subclasses), on normalized
/// screen coordinates. Anything outside a region opens the menu.
_NavAction _resolveNavTap({
  required ReaderNavLayout layout,
  required ReaderNavInvert invert,
  required Offset position,
  required Size size,
  required bool reversed,
  required bool webtoon,
}) {
  var x = position.dx / size.width;
  var y = position.dy / size.height;
  if (invert == ReaderNavInvert.horizontal || invert == ReaderNavInvert.both) {
    x = 1 - x;
  }
  if (invert == ReaderNavInvert.vertical || invert == ReaderNavInvert.both) {
    y = 1 - y;
  }
  // "Default" is per-viewer in Mihon: Right-and-left for paged, L-shaped for
  // long strip.
  final effective = layout == ReaderNavLayout.defaultLayout
      ? (webtoon ? ReaderNavLayout.lShaped : ReaderNavLayout.rightAndLeft)
      : layout;
  // Left/right zones are direction-aware; top/bottom (prev/next) are not.
  _NavAction left() => reversed ? _NavAction.next : _NavAction.prev;
  _NavAction right() => reversed ? _NavAction.prev : _NavAction.next;
  switch (effective) {
    case ReaderNavLayout.lShaped:
      if (y < 0.33) return _NavAction.prev;
      if (y > 0.66) return _NavAction.next;
      if (x < 0.33) return left();
      if (x > 0.66) return right();
      return _NavAction.menu;
    case ReaderNavLayout.kindlish:
      if (y < 0.33) return _NavAction.menu;
      return x < 0.33 ? _NavAction.prev : _NavAction.next;
    case ReaderNavLayout.edge:
      if (x < 0.33 || x > 0.66) return _NavAction.next;
      if (y > 0.66) return _NavAction.prev;
      return _NavAction.menu;
    case ReaderNavLayout.rightAndLeft:
      if (x < 0.33) return left();
      if (x > 0.66) return right();
      return _NavAction.menu;
    case ReaderNavLayout.disabled:
    case ReaderNavLayout.defaultLayout:
      return _NavAction.menu;
  }
}

class _ReaderView extends StatefulWidget {
  const _ReaderView();

  @override
  State<_ReaderView> createState() => _ReaderViewState();
}

class _ReaderViewState extends State<_ReaderView> {
  final ReaderPreferences _prefs = getIt<ReaderPreferences>();

  @override
  void initState() {
    super.initState();
    _applySystemUi(context.read<ReaderBloc>().state.showOverlay);
    _applyScreenPrefs();
    _prefs.addListener(_onPrefsChanged);
  }

  @override
  void dispose() {
    _prefs.removeListener(_onPrefsChanged);
    // Leaving the reader must always restore the regular system bars,
    // orientation, idle timer, and screen brightness.
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations(const []);
    NativeScreen.keepScreenOn(false);
    NativeScreen.setBrightness(null);
    super.dispose();
  }

  void _onPrefsChanged() {
    if (!mounted) return;
    _applySystemUi(context.read<ReaderBloc>().state.showOverlay);
    _applyScreenPrefs();
  }

  void _applyScreenPrefs() {
    NativeScreen.keepScreenOn(_prefs.keepScreenOn);
    // Positive custom brightness drives the real screen; negative dims via
    // the overlay in [_filtered]; 0/off restores the system value.
    NativeScreen.setBrightness(
      _prefs.customBrightness && _prefs.brightnessValue > 0
          ? _prefs.brightnessValue / 100
          : null,
    );
    SystemChrome.setPreferredOrientations(switch (_prefs.orientation) {
      ReaderOrientation.free => const [],
      ReaderOrientation.portrait => const [DeviceOrientation.portraitUp],
      ReaderOrientation.landscape => const [
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ],
    });
  }

  void _applySystemUi(bool showOverlay) {
    SystemChrome.setEnabledSystemUIMode(
      showOverlay || !_prefs.fullscreen
          ? SystemUiMode.edgeToEdge
          : SystemUiMode.immersiveSticky,
    );
  }

  Color _backgroundColor(BuildContext context) => switch (_prefs.background) {
    ReaderBackground.black => Colors.black,
    // Mihon's reader gray.
    ReaderBackground.gray => const Color(0xFF202125),
    ReaderBackground.white => Colors.white,
    ReaderBackground.automatic =>
      Theme.of(context).brightness == Brightness.dark
          ? Colors.black
          : Colors.white,
  };

  static const List<double> _grayscaleMatrix = [
    0.2126, 0.7152, 0.0722, 0, 0, //
    0.2126, 0.7152, 0.0722, 0, 0, //
    0.2126, 0.7152, 0.0722, 0, 0, //
    0, 0, 0, 1, 0,
  ];

  static const List<double> _invertMatrix = [
    -1, 0, 0, 0, 255, //
    0, -1, 0, 0, 255, //
    0, 0, -1, 0, 255, //
    0, 0, 0, 1, 0,
  ];

  static const Map<ReaderBlendMode, BlendMode> _blendModes = {
    ReaderBlendMode.defaultBlend: BlendMode.srcOver,
    ReaderBlendMode.multiply: BlendMode.multiply,
    ReaderBlendMode.screen: BlendMode.screen,
    ReaderBlendMode.overlay: BlendMode.overlay,
    ReaderBlendMode.lighten: BlendMode.lighten,
    ReaderBlendMode.darken: BlendMode.darken,
  };

  /// Mihon's custom filter stack: color filter, grayscale, inversion.
  Widget _filtered(Widget reader) {
    var result = reader;
    if (_prefs.colorFilter) {
      result = ColorFiltered(
        colorFilter: ColorFilter.mode(
          Color.fromARGB(
            _prefs.filterAlpha,
            _prefs.filterRed,
            _prefs.filterGreen,
            _prefs.filterBlue,
          ),
          _blendModes[_prefs.filterBlend]!,
        ),
        child: result,
      );
    }
    if (_prefs.grayscale) {
      result = ColorFiltered(
        colorFilter: const ColorFilter.matrix(_grayscaleMatrix),
        child: result,
      );
    }
    if (_prefs.invertedColors) {
      result = ColorFiltered(
        colorFilter: const ColorFilter.matrix(_invertMatrix),
        child: result,
      );
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ReaderBloc, ReaderState>(
      listenWhen: (a, b) => a.showOverlay != b.showOverlay,
      listener: (context, state) => _applySystemUi(state.showOverlay),
      child: ListenableBuilder(
        listenable: _prefs,
        builder: (context, _) {
          final dim = _prefs.customBrightness && _prefs.brightnessValue < 0
              ? -_prefs.brightnessValue / 100
              : 0.0;
          return Scaffold(
            backgroundColor: _backgroundColor(context),
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
                      child: _filtered(
                        state.readingMode.isPaged
                            ? const _PagedReader()
                            : const _WebtoonReader(),
                      ),
                    ),
                    if (dim > 0)
                      Positioned.fill(
                        child: IgnorePointer(
                          child: ColoredBox(
                            color: Colors.black.withValues(alpha: dim),
                          ),
                        ),
                      ),
                    // Mihon keeps a small page indicator visible at all times.
                    if (_prefs.showPageNumber)
                      const Positioned(
                        bottom: 4,
                        left: 0,
                        right: 0,
                        child: _PageIndicator(),
                      ),
                    if (_prefs.showReadingMode) const _ModeBanner(),
                    if (state.showOverlay) const ReaderTopBar(),
                    if (state.showOverlay) const ReaderBottomBar(),
                  ],
                ),
              ),
            ),
          );
        },
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
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

/// Mihon's "Show reading mode": briefly names the active mode when the
/// reader opens.
class _ModeBanner extends StatefulWidget {
  const _ModeBanner();

  @override
  State<_ModeBanner> createState() => _ModeBannerState();
}

class _ModeBannerState extends State<_ModeBanner> {
  final ValueNotifier<bool> _visible = ValueNotifier(true);

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(seconds: 2), () {
      if (mounted) _visible.value = false;
    });
  }

  @override
  void dispose() {
    _visible.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: IgnorePointer(
        child: ValueListenableBuilder<bool>(
          valueListenable: _visible,
          builder: (context, visible, child) => AnimatedOpacity(
            opacity: visible ? 1 : 0,
            duration: const Duration(milliseconds: 400),
            child: child,
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: BlocBuilder<ReaderBloc, ReaderState>(
                buildWhen: (a, b) => a.readingMode != b.readingMode,
                builder: (context, state) => AppText.bodyMedium(
                  'reader.mode_${state.readingMode.name}',
                  color: Colors.white,
                ),
              ),
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
  final ReaderPreferences _prefs = getIt<ReaderPreferences>();
  late final PageController _controller;
  // While a page is zoomed the PageView must not steal horizontal drags.
  final ValueNotifier<bool> _zoomed = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    _controller = PageController(
      initialPage: context.read<ReaderBloc>().state.currentItem,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _zoomed.dispose();
    super.dispose();
  }

  BoxFit get _fit => switch (_prefs.scaleType) {
    ReaderScaleType.fitScreen => BoxFit.contain,
    ReaderScaleType.stretch => BoxFit.fill,
    ReaderScaleType.fitWidth => BoxFit.fitWidth,
    ReaderScaleType.fitHeight => BoxFit.fitHeight,
    ReaderScaleType.originalSize => BoxFit.none,
  };

  @override
  Widget build(BuildContext context) {
    return BlocListener<ReaderBloc, ReaderState>(
      // Jump only on explicit seeks (slider, chapter buttons, chapter load).
      // Ordinary currentItem echoes of this widget's own page reports can
      // arrive late during a fast swipe run and would yank back to an old page.
      listenWhen: (a, b) => a.seek != b.seek,
      listener: (context, state) {
        if (!_controller.hasClients) return;
        if ((_controller.page?.round() ?? -1) != state.currentItem) {
          _controller.jumpToPage(state.currentItem);
        }
      },
      child: ListenableBuilder(
        listenable: _prefs,
        builder: (context, _) => BlocBuilder<ReaderBloc, ReaderState>(
          buildWhen: (a, b) =>
              a.items != b.items ||
              a.readingMode != b.readingMode ||
              a.imageHeaders != b.imageHeaders,
          builder: (context, state) => GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapUp: (d) => _handleTap(context, d, state.readingMode),
            child: ValueListenableBuilder<bool>(
              valueListenable: _zoomed,
              builder: (context, zoomed, _) => PageView.builder(
                controller: _controller,
                // Pre-builds the adjacent page so its image starts loading
                // before the swipe (Mihon preloads ahead).
                allowImplicitScrolling: true,
                physics: zoomed ? const NeverScrollableScrollPhysics() : null,
                scrollDirection: state.readingMode == ReadingMode.vertical
                    ? Axis.vertical
                    : Axis.horizontal,
                reverse: state.readingMode.isReversed,
                onPageChanged: (i) {
                  _zoomed.value = false;
                  context.read<ReaderBloc>().add(ReaderItemChanged(i));
                },
                itemCount: state.items.length,
                itemBuilder: (context, index) => switch (state.items[index]) {
                  final ReaderPageItem item => _ZoomablePage(
                    onZoomChanged: (z) => _zoomed.value = z,
                    child: SizedBox.expand(
                      child: ReaderImage(
                        url: item.page.imageUrl ?? item.page.url,
                        headers: state.imageHeaders,
                        fit: _fit,
                      ),
                    ),
                  ),
                  final ReaderTransitionItem item => Center(
                    child: _ChapterTransitionView(item: item),
                  ),
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleTap(BuildContext context, TapUpDetails d, ReadingMode mode) {
    final action = _resolveNavTap(
      layout: _prefs.navLayoutPaged,
      invert: _prefs.navInvertPaged,
      position: d.localPosition,
      size: MediaQuery.sizeOf(context),
      reversed: mode.isReversed,
      webtoon: false,
    );
    switch (action) {
      case _NavAction.prev:
        _page(-1);
      case _NavAction.next:
        _page(1);
      case _NavAction.menu:
        context.read<ReaderBloc>().add(const ReaderOverlayToggled());
    }
  }

  void _page(int delta) {
    final target = (_controller.page?.round() ?? 0) + delta;
    final count = context.read<ReaderBloc>().state.items.length;
    if (target < 0 || target >= count) return;
    if (_prefs.animatePageTransitions) {
      _controller.animateToPage(
        target,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    } else {
      _controller.jumpToPage(target);
    }
  }
}

/// A single paged-reader page: pinch to zoom, double tap to toggle 2x zoom at
/// the tap point (Mihon default, animated at the configured double-tap
/// speed). Reports its zoom state so the enclosing PageView can hand drag
/// gestures to the zoomed image.
class _ZoomablePage extends StatefulWidget {
  const _ZoomablePage({required this.onZoomChanged, required this.child});

  final ValueChanged<bool> onZoomChanged;
  final Widget child;

  @override
  State<_ZoomablePage> createState() => _ZoomablePageState();
}

class _ZoomablePageState extends State<_ZoomablePage>
    with SingleTickerProviderStateMixin {
  static const _zoomThreshold = 1.05;
  static const _doubleTapScale = 2.0;

  final TransformationController _transformation = TransformationController();
  late final AnimationController _animator = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  );
  late final CurvedAnimation _curve = CurvedAnimation(
    parent: _animator,
    curve: Curves.easeOut,
  );
  Matrix4Tween? _tween;
  Offset? _doubleTapPosition;

  bool get _isZoomed =>
      _transformation.value.getMaxScaleOnAxis() > _zoomThreshold;

  @override
  void initState() {
    super.initState();
    _animator.addListener(() {
      final tween = _tween;
      if (tween != null) _transformation.value = tween.evaluate(_curve);
    });
  }

  @override
  void dispose() {
    _curve.dispose();
    _animator.dispose();
    _transformation.dispose();
    super.dispose();
  }

  void _onDoubleTap() {
    final Matrix4 target;
    if (_isZoomed) {
      target = Matrix4.identity();
    } else {
      final p = _doubleTapPosition;
      if (p == null) return;
      // Zoom about the tap point: keep it fixed while scaling up.
      target = Matrix4.identity()
        ..translateByDouble(
          -p.dx * (_doubleTapScale - 1),
          -p.dy * (_doubleTapScale - 1),
          0,
          1,
        )
        ..scaleByDouble(_doubleTapScale, _doubleTapScale, 1, 1);
    }
    _animator.duration = Duration(
      milliseconds: getIt<ReaderPreferences>().doubleTapSpeed.milliseconds,
    );
    _tween = Matrix4Tween(begin: _transformation.value, end: target);
    _animator
        .forward(from: 0)
        .whenComplete(
          () =>
              widget.onZoomChanged(target.getMaxScaleOnAxis() > _zoomThreshold),
        );
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
  /// "Long strip with gaps" spacing between pages.
  static const double _pageGap = 16;

  final ReaderPreferences _prefs = getIt<ReaderPreferences>();
  final ItemScrollController _scrollController = ItemScrollController();
  final ScrollOffsetController _offsetController = ScrollOffsetController();
  final ItemPositionsListener _positions = ItemPositionsListener.create();

  /// Fresh bucket per mount: ScrollablePositionedList prefers a
  /// PageStorage-restored position over initialScrollIndex, so after a
  /// chapter switch remounts this widget it would reopen at the previous
  /// chapter's stale scroll position instead of the new chapter's page.
  final PageStorageBucket _storageBucket = PageStorageBucket();

  /// Transition-card height, captured once — immersive-mode toggles change
  /// MediaQuery size and would resize every card, shifting the scroll.
  late final double _transitionHeight = MediaQuery.sizeOf(context).height * 0.7;

  late int _currentIndex;
  // Suppresses position reports while an external seek jump is in flight so
  // stale positions cannot bounce currentItem back (and cannot mark pages
  // read from a transient index).
  bool _pendingJump = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = context.read<ReaderBloc>().state.currentItem;
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
    // Current item = the one whose leading edge last crossed the viewport
    // middle (Mihon's webtoon rule).
    final above = positions.where((p) => p.itemLeadingEdge <= 0.5);
    final index = above.isEmpty
        ? positions.map((p) => p.index).reduce(min)
        : above.map((p) => p.index).reduce(max);
    if (index == _currentIndex) return;
    _currentIndex = index;
    context.read<ReaderBloc>().add(ReaderItemChanged(index));
  }

  void _handleTap(TapUpDetails d) {
    final size = MediaQuery.sizeOf(context);
    final action = _resolveNavTap(
      layout: _prefs.navLayoutWebtoon,
      invert: _prefs.navInvertWebtoon,
      position: d.localPosition,
      size: size,
      reversed: false,
      webtoon: true,
    );
    switch (action) {
      case _NavAction.prev:
        _scrollBy(-0.75 * size.height);
      case _NavAction.next:
        _scrollBy(0.75 * size.height);
      case _NavAction.menu:
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
      // Jump only on explicit seeks (slider, chapter switch, chapter load).
      // Plain currentItem changes include late echoes of this widget's own
      // scroll reports — jumping on those yanks the reader to a stale page.
      listenWhen: (a, b) => a.seek != b.seek,
      listener: (context, state) {
        if (state.currentItem == _currentIndex) return;
        _currentIndex = state.currentItem;
        _pendingJump = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _scrollController.isAttached) {
            _scrollController.jumpTo(index: _currentIndex);
          }
          // Let the jumped-to layout settle before reporting positions again.
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => _pendingJump = false,
          );
        });
      },
      child: ListenableBuilder(
        listenable: _prefs,
        builder: (context, _) => BlocBuilder<ReaderBloc, ReaderState>(
          buildWhen: (a, b) =>
              a.items != b.items ||
              a.imageHeaders != b.imageHeaders ||
              a.readingMode != b.readingMode,
          builder: (context, state) {
            final gap = state.readingMode == ReadingMode.webtoonGaps
                ? _pageGap
                : 0.0;
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapUp: _handleTap,
              child: PageStorage(
                bucket: _storageBucket,
                child: ScrollablePositionedList.builder(
                  itemScrollController: _scrollController,
                  scrollOffsetController: _offsetController,
                  itemPositionsListener: _positions,
                  initialScrollIndex: _currentIndex,
                  padding: EdgeInsets.symmetric(
                    horizontal:
                        MediaQuery.sizeOf(context).width *
                        _prefs.sidePadding /
                        100,
                  ),
                  // Keep ~2 screens of items alive around the viewport: upcoming
                  // images preload before they're visible and recently passed
                  // ones keep their decoded size (no placeholder-height shifts).
                  minCacheExtent: MediaQuery.sizeOf(context).height * 2,
                  itemCount: state.items.length,
                  itemBuilder: (context, index) => switch (state.items[index]) {
                    final ReaderPageItem item => Padding(
                      padding: EdgeInsets.only(bottom: gap),
                      child: ReaderImage(
                        url: item.page.imageUrl ?? item.page.url,
                        headers: state.imageHeaders,
                        fit: BoxFit.fitWidth,
                        reserveHeight: true,
                      ),
                    ),
                    final ReaderTransitionItem item =>
                      // "Always show chapter transition" off collapses the card
                      // between loaded chapters; the trailing card (loading /
                      // no-next-chapter) always shows.
                      !_prefs.alwaysShowTransition &&
                              index < state.items.length - 1
                          ? const SizedBox.shrink()
                          : SizedBox(
                              height: _transitionHeight,
                              child: Center(
                                child: _ChapterTransitionView(item: item),
                              ),
                            ),
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Mihon's between-chapter card: what just finished, what comes next (or
/// that nothing does).
class _ChapterTransitionView extends StatelessWidget {
  const _ChapterTransitionView({required this.item});

  final ReaderTransitionItem item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppText.labelMedium('reader.finished', color: Colors.white70),
          AppText.bodyLarge(item.fromChapterName, color: Colors.white),
          const SizedBox(height: 24),
          if (item.toChapterName != null) ...[
            const AppText.labelMedium('reader.next', color: Colors.white70),
            AppText.bodyLarge(item.toChapterName!, color: Colors.white),
          ] else
            const AppText.bodyLarge(
              'reader.no_next_chapter',
              color: Colors.white,
            ),
        ],
      ),
    );
  }
}
