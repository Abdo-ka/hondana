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

  Set<int> get disabledIds => _idSet(_kDisabled);

  bool isEnabled(int id) => !disabledIds.contains(id);

  Future<void> setEnabled(int id, bool enabled) async {
    final set = disabledIds;
    enabled ? set.remove(id) : set.add(id);
    await _save(_kDisabled, set);
    notifyListeners();
  }

  Set<int> get pinnedIds => _idSet(_kPinned);

  bool isPinned(int id) => pinnedIds.contains(id);

  Future<void> setPinned(int id, bool pinned) async {
    final set = pinnedIds;
    pinned ? set.add(id) : set.remove(id);
    await _save(_kPinned, set);
    notifyListeners();
  }

  // ── Per-source base-URL overrides (sites hop domains frequently) ──────────

  static const _kUrls = 'sources.url_overrides';

  Map<String, String> get _urlMap {
    final raw = _prefs.getString(_kUrls);
    if (raw == null) return {};
    return Map<String, String>.from(jsonDecode(raw) as Map);
  }

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
