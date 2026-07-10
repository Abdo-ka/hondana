import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// App-level user settings, exposed as [ValueNotifier]s so the UI rebuilds on
/// change (ValueNotifier per the no-setState rule).
@lazySingleton
class AppSettings {
  AppSettings(this._prefs)
      : themeModeNotifier = ValueNotifier(
          ThemeMode.values[_prefs.getInt(_kThemeMode) ?? 0],
        ),
        downloadedOnlyNotifier =
            ValueNotifier(_prefs.getBool(_kDownloadedOnly) ?? false),
        incognitoNotifier = ValueNotifier(_prefs.getBool(_kIncognito) ?? false);

  final SharedPreferences _prefs;
  static const _kThemeMode = 'app.themeMode';
  static const _kDownloadedOnly = 'app.downloadedOnly';
  static const _kIncognito = 'app.incognito';

  final ValueNotifier<ThemeMode> themeModeNotifier;

  /// Library shows only downloaded entries (Mihon's global toggle).
  final ValueNotifier<bool> downloadedOnlyNotifier;

  /// Reading leaves no history while on.
  final ValueNotifier<bool> incognitoNotifier;

  ThemeMode get themeMode => themeModeNotifier.value;
  bool get downloadedOnly => downloadedOnlyNotifier.value;
  bool get incognito => incognitoNotifier.value;

  Future<void> setThemeMode(ThemeMode mode) async {
    themeModeNotifier.value = mode;
    await _prefs.setInt(_kThemeMode, mode.index);
  }

  Future<void> setDownloadedOnly(bool v) async {
    downloadedOnlyNotifier.value = v;
    await _prefs.setBool(_kDownloadedOnly, v);
  }

  Future<void> setIncognito(bool v) async {
    incognitoNotifier.value = v;
    await _prefs.setBool(_kIncognito, v);
  }
}
