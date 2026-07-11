import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Download settings (Mihon parity — defaults match Mihon's
/// DownloadPreferences.kt).
@lazySingleton
class DownloadPreferences {
  DownloadPreferences(this._prefs);

  final SharedPreferences _prefs;

  static const _kWifiOnly = 'downloads.wifiOnly';
  static const _kRemoveAfterMarkedRead = 'downloads.removeAfterMarkedRead';
  static const _kRemoveAfterReadSlots = 'downloads.removeAfterReadSlots';
  static const _kRemoveBookmarked = 'downloads.removeBookmarked';
  static const _kRemoveExcludeCategories = 'downloads.removeExcludeCategories';
  static const _kDownloadNewChapters = 'downloads.downloadNewChapters';
  static const _kDownloadNewInclude = 'downloads.downloadNewInclude';
  static const _kDownloadNewExclude = 'downloads.downloadNewExclude';
  static const _kDownloadAhead = 'downloads.downloadAheadAmount';

  Set<int> _ids(String key) => (_prefs.getStringList(key) ?? const [])
      .map(int.tryParse)
      .nonNulls
      .toSet();

  Future<void> _setIds(String key, Set<int> ids) =>
      _prefs.setStringList(key, ids.map((e) => '$e').toList());

  /// "Only on Wi-Fi" — Mihon default is on.
  bool get wifiOnly => _prefs.getBool(_kWifiOnly) ?? true;
  Future<void> setWifiOnly(bool v) => _prefs.setBool(_kWifiOnly, v);

  /// Delete the download when its chapter is manually marked as read.
  bool get removeAfterMarkedRead =>
      _prefs.getBool(_kRemoveAfterMarkedRead) ?? false;
  Future<void> setRemoveAfterMarkedRead(bool v) =>
      _prefs.setBool(_kRemoveAfterMarkedRead, v);

  /// After reading, auto-delete the download this many chapters behind the
  /// one just read: -1 disabled, 0 = the chapter itself (last read),
  /// 1..4 = second-to-last .. fifth-to-last.
  int get removeAfterReadSlots => _prefs.getInt(_kRemoveAfterReadSlots) ?? -1;
  Future<void> setRemoveAfterReadSlots(int v) =>
      _prefs.setInt(_kRemoveAfterReadSlots, v);

  /// Allow auto-delete to remove bookmarked chapters.
  bool get removeBookmarked => _prefs.getBool(_kRemoveBookmarked) ?? false;
  Future<void> setRemoveBookmarked(bool v) =>
      _prefs.setBool(_kRemoveBookmarked, v);

  /// Categories whose entries are never auto-deleted.
  Set<int> get removeExcludeCategoryIds => _ids(_kRemoveExcludeCategories);
  Future<void> setRemoveExcludeCategoryIds(Set<int> ids) =>
      _setIds(_kRemoveExcludeCategories, ids);

  /// Auto-download newly found chapters during library updates.
  bool get downloadNewChapters =>
      _prefs.getBool(_kDownloadNewChapters) ?? false;
  Future<void> setDownloadNewChapters(bool v) =>
      _prefs.setBool(_kDownloadNewChapters, v);

  /// Tri-state category filter for auto-download: empty include set = all
  /// categories (minus excluded).
  Set<int> get downloadNewIncludeCategoryIds => _ids(_kDownloadNewInclude);
  Future<void> setDownloadNewIncludeCategoryIds(Set<int> ids) =>
      _setIds(_kDownloadNewInclude, ids);

  Set<int> get downloadNewExcludeCategoryIds => _ids(_kDownloadNewExclude);
  Future<void> setDownloadNewExcludeCategoryIds(Set<int> ids) =>
      _setIds(_kDownloadNewExclude, ids);

  /// "Auto download while reading": 0 disabled, else next 2/3/5/10 unread
  /// chapters. Mihon only downloads ahead when the current and next chapter
  /// are already downloaded.
  int get downloadAheadAmount => _prefs.getInt(_kDownloadAhead) ?? 0;
  Future<void> setDownloadAheadAmount(int v) =>
      _prefs.setInt(_kDownloadAhead, v);
}
