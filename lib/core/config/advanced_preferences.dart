import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Advanced settings (Mihon SettingsAdvancedScreen parity where portable).
@lazySingleton
class AdvancedPreferences {
  AdvancedPreferences(this._prefs);

  final SharedPreferences _prefs;

  static const _kUserAgent = 'advanced.userAgent';
  static const _kClearCacheOnLaunch = 'advanced.clearCacheOnLaunch';
  static const _kUpdateTitlesFromSource = 'advanced.updateTitlesFromSource';

  /// Custom default User-Agent for source HTTP requests; null = built-in
  /// default. Takes effect on app restart (sources cache their headers).
  String? get userAgent => _prefs.getString(_kUserAgent);
  Future<void> setUserAgent(String? v) => (v == null || v.trim().isEmpty)
      ? _prefs.remove(_kUserAgent)
      : _prefs.setString(_kUserAgent, v.trim());

  /// Clear the chapter image cache every app launch.
  bool get clearCacheOnLaunch => _prefs.getBool(_kClearCacheOnLaunch) ?? false;
  Future<void> setClearCacheOnLaunch(bool v) =>
      _prefs.setBool(_kClearCacheOnLaunch, v);

  /// Library update also refreshes titles to match the source.
  bool get updateTitlesFromSource =>
      _prefs.getBool(_kUpdateTitlesFromSource) ?? false;
  Future<void> setUpdateTitlesFromSource(bool v) =>
      _prefs.setBool(_kUpdateTitlesFromSource, v);
}
