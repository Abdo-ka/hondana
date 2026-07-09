import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum LibraryDisplayMode { comfortableGrid, compactGrid, list }

enum LibrarySortMode { alphabetical, lastUpdate, unread, dateAdded }

/// Persisted library view preferences (display mode + sort).
@lazySingleton
class LibraryPreferences {
  LibraryPreferences(this._prefs);

  final SharedPreferences _prefs;

  static const _kDisplay = 'library.displayMode';
  static const _kSort = 'library.sortMode';
  static const _kAsc = 'library.sortAscending';

  LibraryDisplayMode get displayMode =>
      LibraryDisplayMode.values[_prefs.getInt(_kDisplay) ?? 0];
  Future<void> setDisplayMode(LibraryDisplayMode m) =>
      _prefs.setInt(_kDisplay, m.index);

  LibrarySortMode get sortMode =>
      LibrarySortMode.values[_prefs.getInt(_kSort) ?? 0];
  Future<void> setSortMode(LibrarySortMode m) => _prefs.setInt(_kSort, m.index);

  bool get sortAscending => _prefs.getBool(_kAsc) ?? true;
  Future<void> setSortAscending(bool v) => _prefs.setBool(_kAsc, v);
}
