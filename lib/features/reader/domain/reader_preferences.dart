import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Mihon's five viewer modes. `webtoonGaps` is "Long strip with gaps".
/// Order is persisted by index — append only.
enum ReadingMode {
  leftToRight,
  rightToLeft,
  vertical,
  webtoon,
  webtoonGaps;

  bool get isPaged =>
      this != ReadingMode.webtoon && this != ReadingMode.webtoonGaps;
  bool get isWebtoon => !isPaged;
  bool get isHorizontal =>
      this == ReadingMode.leftToRight || this == ReadingMode.rightToLeft;
  bool get isReversed => this == ReadingMode.rightToLeft;
}

/// Reader background (Mihon: Black | Gray | White | Automatic).
enum ReaderBackground { black, gray, white, automatic }

/// Tap-zone layouts (Mihon navigation modes).
enum ReaderNavLayout {
  defaultLayout,
  lShaped,
  kindlish,
  edge,
  rightAndLeft,
  disabled,
}

/// Tap-zone inversion.
enum ReaderNavInvert { none, horizontal, vertical, both }

/// Paged-mode scale type (Mihon minus Android-specific smart fit).
enum ReaderScaleType { fitScreen, stretch, fitWidth, fitHeight, originalSize }

/// Reader orientation lock.
enum ReaderOrientation { free, portrait, landscape }

/// Double-tap zoom animation speed (Mihon: 500 / 250 / 1 ms).
enum DoubleTapSpeed {
  normal(500),
  fast(250),
  none(1);

  const DoubleTapSpeed(this.milliseconds);
  final int milliseconds;
}

/// Color-filter blend modes (Mihon's six, all portable in Flutter).
enum ReaderBlendMode {
  defaultBlend,
  multiply,
  screen,
  overlay,
  lighten,
  darken,
}

/// All reader settings (Mihon ReaderPreferences.kt parity; defaults match).
/// Extends [ChangeNotifier] so the open reader re-reads settings live while
/// the in-reader sheet edits them.
@lazySingleton
class ReaderPreferences extends ChangeNotifier {
  ReaderPreferences(this._prefs);

  final SharedPreferences _prefs;

  static const _kMode = 'reader.mode';
  static const _kDoubleTapSpeed = 'reader.doubleTapSpeed';
  static const _kShowReadingMode = 'reader.showReadingMode';
  static const _kAnimateTransitions = 'reader.animatePageTransitions';
  static const _kOrientation = 'reader.orientation';
  static const _kBackground = 'reader.background';
  static const _kFullscreen = 'reader.fullscreen';
  static const _kKeepScreenOn = 'reader.keepScreenOn';
  static const _kShowPageNumber = 'reader.showPageNumber';
  static const _kSkipRead = 'reader.skipRead';
  static const _kSkipDuplicates = 'reader.skipDuplicates';
  static const _kAlwaysShowTransition = 'reader.alwaysShowTransition';
  static const _kNavLayoutPaged = 'reader.navLayoutPaged';
  static const _kNavInvertPaged = 'reader.navInvertPaged';
  static const _kScaleType = 'reader.scaleType';
  static const _kNavLayoutWebtoon = 'reader.navLayoutWebtoon';
  static const _kNavInvertWebtoon = 'reader.navInvertWebtoon';
  static const _kSidePadding = 'reader.webtoonSidePadding';
  static const _kDoubleTapZoomWebtoon = 'reader.doubleTapZoomWebtoon';
  static const _kCustomBrightness = 'reader.customBrightness';
  static const _kBrightnessValue = 'reader.brightnessValue';
  static const _kColorFilter = 'reader.colorFilter';
  static const _kFilterRed = 'reader.filterRed';
  static const _kFilterGreen = 'reader.filterGreen';
  static const _kFilterBlue = 'reader.filterBlue';
  static const _kFilterAlpha = 'reader.filterAlpha';
  static const _kFilterBlend = 'reader.filterBlend';
  static const _kGrayscale = 'reader.grayscale';
  static const _kInvertedColors = 'reader.invertedColors';

  T _enum<T extends Enum>(String key, List<T> values, T fallback) {
    final i = _prefs.getInt(key);
    return (i == null || i < 0 || i >= values.length) ? fallback : values[i];
  }

  Future<void> _set(String key, Object v) async {
    switch (v) {
      case final bool b:
        await _prefs.setBool(key, b);
      case final int i:
        await _prefs.setInt(key, i);
      case final Enum e:
        await _prefs.setInt(key, e.index);
      default:
        throw ArgumentError('Unsupported pref type: $v');
    }
    notifyListeners();
  }

  // ── Mode / behavior ────────────────────────────────────────────────────────

  ReadingMode get readingMode =>
      _enum(_kMode, ReadingMode.values, ReadingMode.rightToLeft);
  Future<void> setReadingMode(ReadingMode m) => _set(_kMode, m);

  DoubleTapSpeed get doubleTapSpeed =>
      _enum(_kDoubleTapSpeed, DoubleTapSpeed.values, DoubleTapSpeed.normal);
  Future<void> setDoubleTapSpeed(DoubleTapSpeed v) => _set(_kDoubleTapSpeed, v);

  /// Briefly show the current mode when the reader opens.
  bool get showReadingMode => _prefs.getBool(_kShowReadingMode) ?? true;
  Future<void> setShowReadingMode(bool v) => _set(_kShowReadingMode, v);

  bool get animatePageTransitions =>
      _prefs.getBool(_kAnimateTransitions) ?? true;
  Future<void> setAnimatePageTransitions(bool v) =>
      _set(_kAnimateTransitions, v);

  ReaderOrientation get orientation =>
      _enum(_kOrientation, ReaderOrientation.values, ReaderOrientation.free);
  Future<void> setOrientation(ReaderOrientation v) => _set(_kOrientation, v);

  // ── Display ────────────────────────────────────────────────────────────────

  ReaderBackground get background =>
      _enum(_kBackground, ReaderBackground.values, ReaderBackground.black);
  Future<void> setBackground(ReaderBackground v) => _set(_kBackground, v);

  bool get fullscreen => _prefs.getBool(_kFullscreen) ?? true;
  Future<void> setFullscreen(bool v) => _set(_kFullscreen, v);

  bool get keepScreenOn => _prefs.getBool(_kKeepScreenOn) ?? false;
  Future<void> setKeepScreenOn(bool v) => _set(_kKeepScreenOn, v);

  bool get showPageNumber => _prefs.getBool(_kShowPageNumber) ?? true;
  Future<void> setShowPageNumber(bool v) => _set(_kShowPageNumber, v);

  // ── Reading flow ───────────────────────────────────────────────────────────

  /// Skip chapters marked read when advancing to the next chapter.
  bool get skipRead => _prefs.getBool(_kSkipRead) ?? false;
  Future<void> setSkipRead(bool v) => _set(_kSkipRead, v);

  /// Skip chapters with the same number as the one just read.
  bool get skipDuplicates => _prefs.getBool(_kSkipDuplicates) ?? false;
  Future<void> setSkipDuplicates(bool v) => _set(_kSkipDuplicates, v);

  bool get alwaysShowTransition =>
      _prefs.getBool(_kAlwaysShowTransition) ?? true;
  Future<void> setAlwaysShowTransition(bool v) =>
      _set(_kAlwaysShowTransition, v);

  // ── Paged mode ─────────────────────────────────────────────────────────────

  ReaderNavLayout get navLayoutPaged => _enum(
    _kNavLayoutPaged,
    ReaderNavLayout.values,
    ReaderNavLayout.defaultLayout,
  );
  Future<void> setNavLayoutPaged(ReaderNavLayout v) =>
      _set(_kNavLayoutPaged, v);

  ReaderNavInvert get navInvertPaged =>
      _enum(_kNavInvertPaged, ReaderNavInvert.values, ReaderNavInvert.none);
  Future<void> setNavInvertPaged(ReaderNavInvert v) =>
      _set(_kNavInvertPaged, v);

  ReaderScaleType get scaleType =>
      _enum(_kScaleType, ReaderScaleType.values, ReaderScaleType.fitScreen);
  Future<void> setScaleType(ReaderScaleType v) => _set(_kScaleType, v);

  // ── Long strip (webtoon) mode ──────────────────────────────────────────────

  ReaderNavLayout get navLayoutWebtoon => _enum(
    _kNavLayoutWebtoon,
    ReaderNavLayout.values,
    ReaderNavLayout.defaultLayout,
  );
  Future<void> setNavLayoutWebtoon(ReaderNavLayout v) =>
      _set(_kNavLayoutWebtoon, v);

  ReaderNavInvert get navInvertWebtoon =>
      _enum(_kNavInvertWebtoon, ReaderNavInvert.values, ReaderNavInvert.none);
  Future<void> setNavInvertWebtoon(ReaderNavInvert v) =>
      _set(_kNavInvertWebtoon, v);

  /// 0–25 (% of screen width on each side).
  int get sidePadding => _prefs.getInt(_kSidePadding) ?? 0;
  Future<void> setSidePadding(int v) => _set(_kSidePadding, v.clamp(0, 25));

  bool get doubleTapZoomWebtoon =>
      _prefs.getBool(_kDoubleTapZoomWebtoon) ?? true;
  Future<void> setDoubleTapZoomWebtoon(bool v) =>
      _set(_kDoubleTapZoomWebtoon, v);

  // ── Custom filter (brightness / color) ─────────────────────────────────────

  bool get customBrightness => _prefs.getBool(_kCustomBrightness) ?? false;
  Future<void> setCustomBrightness(bool v) => _set(_kCustomBrightness, v);

  /// -75..100. Negative dims via a black overlay; positive sets screen
  /// brightness; 0 = system.
  int get brightnessValue => _prefs.getInt(_kBrightnessValue) ?? 0;
  Future<void> setBrightnessValue(int v) =>
      _set(_kBrightnessValue, v.clamp(-75, 100));

  bool get colorFilter => _prefs.getBool(_kColorFilter) ?? false;
  Future<void> setColorFilter(bool v) => _set(_kColorFilter, v);

  int get filterRed => _prefs.getInt(_kFilterRed) ?? 0;
  Future<void> setFilterRed(int v) => _set(_kFilterRed, v.clamp(0, 255));

  int get filterGreen => _prefs.getInt(_kFilterGreen) ?? 0;
  Future<void> setFilterGreen(int v) => _set(_kFilterGreen, v.clamp(0, 255));

  int get filterBlue => _prefs.getInt(_kFilterBlue) ?? 0;
  Future<void> setFilterBlue(int v) => _set(_kFilterBlue, v.clamp(0, 255));

  int get filterAlpha => _prefs.getInt(_kFilterAlpha) ?? 0;
  Future<void> setFilterAlpha(int v) => _set(_kFilterAlpha, v.clamp(0, 255));

  ReaderBlendMode get filterBlend => _enum(
    _kFilterBlend,
    ReaderBlendMode.values,
    ReaderBlendMode.defaultBlend,
  );
  Future<void> setFilterBlend(ReaderBlendMode v) => _set(_kFilterBlend, v);

  bool get grayscale => _prefs.getBool(_kGrayscale) ?? false;
  Future<void> setGrayscale(bool v) => _set(_kGrayscale, v);

  bool get invertedColors => _prefs.getBool(_kInvertedColors) ?? false;
  Future<void> setInvertedColors(bool v) => _set(_kInvertedColors, v);
}
