import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum LibraryDisplayMode { comfortableGrid, compactGrid, list }

enum LibrarySortMode { alphabetical, lastUpdate, unread, dateAdded }

/// Mihon-style tri-state filter: ignore / must match / must not match.
enum TriFilter { ignore, include, exclude }

extension TriFilterX on TriFilter {
  TriFilter get next => TriFilter.values[(index + 1) % TriFilter.values.length];
}

/// Persisted library view preferences (display mode + sort + filters).
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
}
