import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum LibraryDisplayMode { comfortableGrid, compactGrid, list }

enum LibrarySortMode { alphabetical, lastUpdate, unread, dateAdded }

/// Mihon-style tri-state filter: ignore / must match / must not match.
enum TriFilter { ignore, include, exclude }

extension TriFilterX on TriFilter {
  TriFilter get next => TriFilter.values[(index + 1) % TriFilter.values.length];
}

/// Chapter swipe actions on the manga details list (Mihon parity).
enum ChapterSwipeAction { disabled, bookmark, markRead, download }

/// Persisted library view preferences (display mode + sort + filters) plus
/// the Settings > Library screen (Mihon LibraryPreferences.kt parity).
@lazySingleton
class LibraryPreferences {
  LibraryPreferences(this._prefs);

  final SharedPreferences _prefs;

  static const _kDisplay = 'library.displayMode';
  static const _kSort = 'library.sortMode';
  static const _kAsc = 'library.sortAscending';
  static const _kFilterUnread = 'library.filter.unread';
  static const _kFilterCompleted = 'library.filter.completed';
  static const _kFilterDownloaded = 'library.filter.downloaded';
  static const _kDefaultCategory = 'library.defaultCategory';
  static const _kUpdateInterval = 'library.updateIntervalHours';
  static const _kUpdateWifiOnly = 'library.updateWifiOnly';
  static const _kUpdateInclude = 'library.updateIncludeCategories';
  static const _kUpdateExclude = 'library.updateExcludeCategories';
  static const _kRefreshMetadata = 'library.autoRefreshMetadata';
  static const _kSkipUnread = 'library.skipUpdateWithUnread';
  static const _kSkipUnstarted = 'library.skipUpdateUnstarted';
  static const _kSkipCompleted = 'library.skipUpdateCompleted';
  static const _kUpdatesBadge = 'library.showUpdatesBadge';
  static const _kSwipeLeft = 'library.chapterSwipeLeft';
  static const _kSwipeRight = 'library.chapterSwipeRight';
  static const _kLastAutoUpdate = 'library.lastAutoUpdate';

  Set<int> _ids(String key) => (_prefs.getStringList(key) ?? const [])
      .map(int.tryParse)
      .nonNulls
      .toSet();

  Future<void> _setIds(String key, Set<int> ids) =>
      _prefs.setStringList(key, ids.map((e) => '$e').toList());

  LibraryDisplayMode get displayMode =>
      LibraryDisplayMode.values[_prefs.getInt(_kDisplay) ?? 0];
  Future<void> setDisplayMode(LibraryDisplayMode m) =>
      _prefs.setInt(_kDisplay, m.index);

  LibrarySortMode get sortMode =>
      LibrarySortMode.values[_prefs.getInt(_kSort) ?? 0];
  Future<void> setSortMode(LibrarySortMode m) => _prefs.setInt(_kSort, m.index);

  bool get sortAscending => _prefs.getBool(_kAsc) ?? true;
  Future<void> setSortAscending(bool v) => _prefs.setBool(_kAsc, v);

  TriFilter get filterUnread =>
      TriFilter.values[_prefs.getInt(_kFilterUnread) ?? 0];
  Future<void> setFilterUnread(TriFilter f) =>
      _prefs.setInt(_kFilterUnread, f.index);

  TriFilter get filterCompleted =>
      TriFilter.values[_prefs.getInt(_kFilterCompleted) ?? 0];
  Future<void> setFilterCompleted(TriFilter f) =>
      _prefs.setInt(_kFilterCompleted, f.index);

  TriFilter get filterDownloaded =>
      TriFilter.values[_prefs.getInt(_kFilterDownloaded) ?? 0];
  Future<void> setFilterDownloaded(TriFilter f) =>
      _prefs.setInt(_kFilterDownloaded, f.index);

  // ── Settings > Library ─────────────────────────────────────────────────────

  /// Category assigned when adding to library: -1 = always ask (Mihon default).
  int get defaultCategoryId => _prefs.getInt(_kDefaultCategory) ?? -1;
  Future<void> setDefaultCategoryId(int v) =>
      _prefs.setInt(_kDefaultCategory, v);

  /// Global update interval in hours: 0 = off (Mihon default), 12/24/48/72/168.
  /// iOS has no guaranteed background scheduling — checked on app
  /// launch/resume instead (best effort, like Mihon's note for iOS ports).
  int get updateIntervalHours => _prefs.getInt(_kUpdateInterval) ?? 0;
  Future<void> setUpdateIntervalHours(int v) =>
      _prefs.setInt(_kUpdateInterval, v);

  bool get updateWifiOnly => _prefs.getBool(_kUpdateWifiOnly) ?? true;
  Future<void> setUpdateWifiOnly(bool v) => _prefs.setBool(_kUpdateWifiOnly, v);

  /// Tri-state category filter for global update: empty include = all
  /// (minus excluded).
  Set<int> get updateIncludeCategoryIds => _ids(_kUpdateInclude);
  Future<void> setUpdateIncludeCategoryIds(Set<int> ids) =>
      _setIds(_kUpdateInclude, ids);

  Set<int> get updateExcludeCategoryIds => _ids(_kUpdateExclude);
  Future<void> setUpdateExcludeCategoryIds(Set<int> ids) =>
      _setIds(_kUpdateExclude, ids);

  /// Also refresh cover/details during library update.
  bool get autoRefreshMetadata => _prefs.getBool(_kRefreshMetadata) ?? false;
  Future<void> setAutoRefreshMetadata(bool v) =>
      _prefs.setBool(_kRefreshMetadata, v);

  // Smart update (Mihon defaults: all on).
  bool get skipUpdateWithUnread => _prefs.getBool(_kSkipUnread) ?? true;
  Future<void> setSkipUpdateWithUnread(bool v) =>
      _prefs.setBool(_kSkipUnread, v);

  bool get skipUpdateUnstarted => _prefs.getBool(_kSkipUnstarted) ?? true;
  Future<void> setSkipUpdateUnstarted(bool v) =>
      _prefs.setBool(_kSkipUnstarted, v);

  bool get skipUpdateCompleted => _prefs.getBool(_kSkipCompleted) ?? true;
  Future<void> setSkipUpdateCompleted(bool v) =>
      _prefs.setBool(_kSkipCompleted, v);

  /// Unread-count badge on the Updates tab icon.
  bool get showUpdatesBadge => _prefs.getBool(_kUpdatesBadge) ?? true;
  Future<void> setShowUpdatesBadge(bool v) => _prefs.setBool(_kUpdatesBadge, v);

  ChapterSwipeAction get swipeLeftAction => ChapterSwipeAction
      .values[_prefs.getInt(_kSwipeLeft) ?? ChapterSwipeAction.bookmark.index];
  Future<void> setSwipeLeftAction(ChapterSwipeAction v) =>
      _prefs.setInt(_kSwipeLeft, v.index);

  ChapterSwipeAction get swipeRightAction => ChapterSwipeAction
      .values[_prefs.getInt(_kSwipeRight) ?? ChapterSwipeAction.markRead.index];
  Future<void> setSwipeRightAction(ChapterSwipeAction v) =>
      _prefs.setInt(_kSwipeRight, v.index);

  /// Millis since epoch of the last automatic global update.
  int get lastAutoUpdate => _prefs.getInt(_kLastAutoUpdate) ?? 0;
  Future<void> setLastAutoUpdate(int millis) =>
      _prefs.setInt(_kLastAutoUpdate, millis);
}
