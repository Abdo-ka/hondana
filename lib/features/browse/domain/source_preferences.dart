import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persisted per-source enable state (disabled ids stored as a string list).
/// Notifies listeners on change so the Sources tab reflects toggles made in
/// the Extensions tab.
@lazySingleton
class SourcePreferences extends ChangeNotifier {
  SourcePreferences(this._prefs);

  final SharedPreferences _prefs;

  static const _kDisabled = 'sources.disabled';
  static const _kPinned = 'sources.pinned';

  Set<int> _idSet(String key) => (_prefs.getStringList(key) ?? const [])
      .map(int.tryParse)
      .nonNulls
      .toSet();

  Future<void> _save(String key, Set<int> ids) =>
      _prefs.setStringList(key, ids.map((e) => e.toString()).toList());

  /// Source ids the user has turned off.
  Set<int> get disabledIds => _idSet(_kDisabled);

  /// A source is enabled unless it appears in [disabledIds].
  bool isEnabled(int id) => !disabledIds.contains(id);

  /// Toggles a source on/off and notifies listeners.
  Future<void> setEnabled(int id, bool enabled) async {
    final set = disabledIds;
    enabled ? set.remove(id) : set.add(id);
    await _save(_kDisabled, set);
    notifyListeners();
  }

  /// Source ids pinned to the top of the Sources list.
  Set<int> get pinnedIds => _idSet(_kPinned);

  bool isPinned(int id) => pinnedIds.contains(id);

  /// Pins/unpins a source and notifies listeners.
  Future<void> setPinned(int id, bool pinned) async {
    final set = pinnedIds;
    pinned ? set.add(id) : set.remove(id);
    await _save(_kPinned, set);
    notifyListeners();
  }

  // ── Browse settings (Mihon: Settings > Browse) ────────────────────────────

  static const _kHideInLibrary = 'sources.hide_in_library';
  static const _kShowNsfw = 'sources.show_nsfw';

  /// Hide entries already in library from browse/search results. Default off.
  bool get hideInLibrary => _prefs.getBool(_kHideInLibrary) ?? false;

  Future<void> setHideInLibrary(bool value) async {
    await _prefs.setBool(_kHideInLibrary, value);
    notifyListeners();
  }

  /// Show NSFW (18+) sources in the sources and extensions lists. Default on.
  bool get showNsfwSources => _prefs.getBool(_kShowNsfw) ?? true;

  Future<void> setShowNsfwSources(bool value) async {
    await _prefs.setBool(_kShowNsfw, value);
    notifyListeners();
  }

  // ── Per-source base-URL overrides (sites hop domains frequently) ──────────

  static const _kUrls = 'sources.url_overrides';

  Map<String, String> get _urlMap {
    final raw = _prefs.getString(_kUrls);
    if (raw == null) return {};
    return Map<String, String>.from(jsonDecode(raw) as Map);
  }

  /// User-set base URL for a source, or null to use its stock URL.
  String? urlOverride(int id) => _urlMap['$id'];

  /// Null or empty [url] removes the override (source reverts to its stock URL).
  Future<void> setUrlOverride(int id, String? url) async {
    final map = _urlMap;
    if (url == null || url.isEmpty) {
      map.remove('$id');
    } else {
      map['$id'] = url;
    }
    await _prefs.setString(_kUrls, jsonEncode(map));
    notifyListeners();
  }
}
