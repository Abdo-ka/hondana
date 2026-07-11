import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// App-level user settings, exposed as [ValueNotifier]s so the UI rebuilds on
/// change (ValueNotifier per the no-setState rule).
///
/// Each notifier is seeded from [SharedPreferences] at construction; setters
/// update the notifier first (immediate UI reaction) then persist.
@lazySingleton
class AppSettings {
  /// Seeds every notifier from persisted values, falling back to Mihon defaults.
  AppSettings(this._prefs)
    : themeModeNotifier = ValueNotifier(
        ThemeMode.values[_prefs.getInt(_kThemeMode) ?? 0],
      ),
      downloadedOnlyNotifier = ValueNotifier(
        _prefs.getBool(_kDownloadedOnly) ?? false,
      ),
      incognitoNotifier = ValueNotifier(_prefs.getBool(_kIncognito) ?? false),
      pureBlackNotifier = ValueNotifier(_prefs.getBool(_kPureBlack) ?? false),
      relativeTimestampsNotifier = ValueNotifier(
        _prefs.getBool(_kRelativeTimestamps) ?? true,
      ),
      dateFormatNotifier = ValueNotifier(_prefs.getString(_kDateFormat) ?? '');

  final SharedPreferences _prefs;
  static const _kThemeMode = 'app.themeMode';
  static const _kDownloadedOnly = 'app.downloadedOnly';
  static const _kIncognito = 'app.incognito';
  static const _kPureBlack = 'app.pureBlack';
  static const _kRelativeTimestamps = 'app.relativeTimestamps';
  static const _kDateFormat = 'app.dateFormat';

  /// Mihon's date format choices; '' = locale default.
  static const dateFormats = [
    '',
    'MM/dd/yy',
    'dd/MM/yy',
    'yyyy-MM-dd',
    'dd MMM yyyy',
    'MMM dd, yyyy',
  ];

  /// Light/dark/system theme selection.
  final ValueNotifier<ThemeMode> themeModeNotifier;

  /// Library shows only downloaded entries (Mihon's global toggle).
  final ValueNotifier<bool> downloadedOnlyNotifier;

  /// Reading leaves no history while on.
  final ValueNotifier<bool> incognitoNotifier;

  /// True-black dark theme (OLED).
  final ValueNotifier<bool> pureBlackNotifier;

  /// "Today" instead of a formatted date (Mihon default on).
  final ValueNotifier<bool> relativeTimestampsNotifier;

  /// One of [dateFormats]; '' = locale default.
  final ValueNotifier<String> dateFormatNotifier;

  ThemeMode get themeMode => themeModeNotifier.value;
  bool get downloadedOnly => downloadedOnlyNotifier.value;
  bool get incognito => incognitoNotifier.value;
  bool get pureBlack => pureBlackNotifier.value;
  bool get relativeTimestamps => relativeTimestampsNotifier.value;
  String get dateFormat => dateFormatNotifier.value;

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

  Future<void> setPureBlack(bool v) async {
    pureBlackNotifier.value = v;
    await _prefs.setBool(_kPureBlack, v);
  }

  Future<void> setRelativeTimestamps(bool v) async {
    relativeTimestampsNotifier.value = v;
    await _prefs.setBool(_kRelativeTimestamps, v);
  }

  Future<void> setDateFormat(String v) async {
    dateFormatNotifier.value = v;
    await _prefs.setString(_kDateFormat, v);
  }
}
