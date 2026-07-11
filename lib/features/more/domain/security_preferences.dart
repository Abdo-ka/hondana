import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Security & privacy settings (Mihon SecurityPreferences.kt parity where
/// portable to iOS).
@lazySingleton
class SecurityPreferences {
  SecurityPreferences(this._prefs);

  final SharedPreferences _prefs;

  static const _kRequireUnlock = 'security.requireUnlock';
  static const _kLockAfterMinutes = 'security.lockAfterMinutes';
  static const _kHideNotificationContent = 'security.hideNotificationContent';

  /// Face ID / Touch ID / passcode gate on app open.
  bool get requireUnlock => _prefs.getBool(_kRequireUnlock) ?? false;
  Future<void> setRequireUnlock(bool v) => _prefs.setBool(_kRequireUnlock, v);

  /// 0 = always, -1 = never, else minutes in background before re-lock.
  int get lockAfterMinutes => _prefs.getInt(_kLockAfterMinutes) ?? 0;
  Future<void> setLockAfterMinutes(int v) =>
      _prefs.setInt(_kLockAfterMinutes, v);

  /// Redact titles from download notifications and the Live Activity.
  bool get hideNotificationContent =>
      _prefs.getBool(_kHideNotificationContent) ?? false;
  Future<void> setHideNotificationContent(bool v) =>
      _prefs.setBool(_kHideNotificationContent, v);
}
